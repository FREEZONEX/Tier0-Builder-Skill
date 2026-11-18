#!/usr/bin/env bash
# Upload Builder Skills or the App scaffold to the test Agent-Console.
#
#   console-upload.sh skill <name>... [--dry-run]
#   console-upload.sh scaffold [<ref>] [--dry-run]
#   console-upload.sh categories [--dry-run]
#
# Content comes only from origin/feature/cloud-new-architecture-migration
# (or the given scaffold ref), never from the working tree. After setting a
# new default template, scaffold moves enabled App categories from the old
# default to it; categories does only that step, from the newest older
# scaffold template to the current default. --dry-run packs, checks limits
# and calls only GET endpoints.
set -euo pipefail

BRANCH=feature/cloud-new-architecture-migration
KUBECONFIG_FILE=$HOME/Tier0-Aliyun-Dev/kubeconfig-liangyuqing-tier0-dev-ack.conf
KUBE_CONTEXT=tier0-dev-ack-liangyuqing
SCAFFOLD_REPO=${SCAFFOLD_REPO:-$HOME/Documents/Projects/Tier0-App-Scaffold}
SKILL_REPO=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)

MIB=$((1024 * 1024))

usage() {
  sed -n '4,6s/^# *//p' "$0" >&2
  exit 2
}

STEP=init
die() {
  echo "FAILED [$STEP]: $*" >&2
  exit 1
}
step() {
  STEP=$1
  echo "== $1"
}

# ---------------------------------------------------------------- arguments
DRY_RUN=0
ARGS=()
for a in "$@"; do
  case $a in
    --dry-run) DRY_RUN=1 ;;
    -h | --help) usage ;;
    *) ARGS+=("$a") ;;
  esac
done
[ ${#ARGS[@]} -ge 1 ] || usage
MODE=${ARGS[0]}
ARGS=("${ARGS[@]:1}")
case $MODE in
  skill) [ ${#ARGS[@]} -ge 1 ] || usage ;;
  scaffold) [ ${#ARGS[@]} -le 1 ] || usage ;;
  categories) [ ${#ARGS[@]} -eq 0 ] || usage ;;
  *) usage ;;
esac

WORK=$(mktemp -d)
PF_PID=
BASE=

cleanup() {
  local status=$?
  if [ -n "$PF_PID" ]; then
    kill "$PF_PID" 2>/dev/null || true
    wait "$PF_PID" 2>/dev/null || true
  fi
  rm -rf "$WORK"
  exit "$status"
}
trap cleanup EXIT

# ------------------------------------------------------------------ helpers
# api METHOD PATH [curl args...]: prints the envelope's data; dies otherwise.
api() {
  local method=$1 path=$2 code
  shift 2
  local args=(-sS -o "$WORK/body.json" -w '%{http_code}' -X "$method")
  [ "$method" = GET ] || args+=(-H "Origin: $BASE")
  code=$(curl "${args[@]}" "$@" "$BASE/api$path") || die "$method $path: curl failed"
  if [ "${code#2}" = "$code" ] || [ "$(jq -r '.code // empty' "$WORK/body.json")" != 0 ]; then
    die "$method $path: HTTP $code code=$(jq -r '.code // "?"' "$WORK/body.json" 2>/dev/null)" \
      "$(jq -r '.message // .msg // empty' "$WORK/body.json" 2>/dev/null)"
  fi
  jq '.data' "$WORK/body.json"
}

origin_sha() { # repo ref
  git -C "$1" fetch -q origin "$BRANCH" || die "git fetch origin $BRANCH in $1"
  git -C "$1" rev-parse --verify -q "$2^{commit}" || die "unknown ref $2 in $1"
}

connect() {
  step connect
  local port
  port=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
  kubectl --kubeconfig "$KUBECONFIG_FILE" --context "$KUBE_CONTEXT" -n default \
    port-forward svc/agent-console "$port:8095" >"$WORK/pf.log" 2>&1 &
  PF_PID=$!
  BASE=http://127.0.0.1:$port
  for _ in $(seq 30); do
    grep -q 'Forwarding from' "$WORK/pf.log" && break
    kill -0 "$PF_PID" 2>/dev/null || die "port-forward exited: $(cat "$WORK/pf.log")"
    sleep 0.5
  done
  grep -q 'Forwarding from' "$WORK/pf.log" || die "port-forward not ready"
  echo "port-forward svc/agent-console -> 127.0.0.1:$port"
}

# ------------------------------------------------------------------- skills
# compare_files LOCAL ONLINE: both "path sha256" lists; prints per file status
# and fails unless every file matches.
compare_files() {
  awk 'NR == FNR { mine[$1] = $2; next }
       { theirs[$1] = $2 }
       END {
         for (p in mine)
           printf "%-11s %s\n", !(p in theirs) ? "LOCAL-ONLY" : \
             (mine[p] == theirs[p] ? "MATCH" : "MISMATCH"), p
         for (p in theirs) if (!(p in mine)) printf "%-11s %s\n", "ONLINE-ONLY", p
       }' "$1" "$2" | sort -k2 >"$WORK/compare.txt"
  sed 's/^/  /' "$WORK/compare.txt"
  local ok total
  ok=$(grep -c '^MATCH ' "$WORK/compare.txt" || true)
  total=$(wc -l <"$WORK/compare.txt" | tr -d ' ')
  echo "  $ok/$total MATCH"
  [ "$ok" = "$total" ]
}

online_files() { # id seq out
  api GET "/skills/$1/versions/$2" | jq -r '.files[] | "\(.path) \(.sha256)"' >"$3"
}

run_skills() {
  step "pack skills"
  local sha name
  sha=$(origin_sha "$SKILL_REPO" "origin/$BRANCH")
  echo "Tier0-Builder-Skill origin/$BRANCH @ $sha"
  for name in "${ARGS[@]}"; do
    git -C "$SKILL_REPO" cat-file -e "$sha:skills/$name/SKILL.md" 2>/dev/null ||
      die "skills/$name/SKILL.md not found at $sha"
    git -C "$SKILL_REPO" archive --format=zip --prefix="$name/" \
      -o "$WORK/$name.zip" "$sha:skills/$name"
    : >"$WORK/$name.local"
    local count=0 total=0 mode type obj size path
    while IFS=$' \t' read -r mode type obj size path; do
      [ "$size" -le "$MIB" ] || die "$name/$path is $size bytes > 1MiB"
      count=$((count + 1))
      total=$((total + size))
      echo "$path $(git -C "$SKILL_REPO" cat-file blob "$obj" | shasum -a 256 | cut -d' ' -f1)" \
        >>"$WORK/$name.local"
    done < <(git -C "$SKILL_REPO" ls-tree -r -l "$sha:skills/$name")
    local zsize
    zsize=$(wc -c <"$WORK/$name.zip" | tr -d ' ')
    [ "$count" -le 128 ] || die "$name has $count files > 128"
    [ "$total" -le $((8 * MIB)) ] || die "$name content is $total bytes > 8MiB"
    [ "$zsize" -le $((8 * MIB)) ] || die "$name.zip is $zsize bytes > 8MiB"
    echo "$name: $count files, $total bytes, zip $zsize bytes"
  done

  connect

  step "list skills"
  api GET '/skills?page_size=100' >"$WORK/skills.json"

  local failed=0
  for name in "${ARGS[@]}"; do
    step "skill $name"
    local skill id seq enabled pinned
    skill=$(jq -c --arg n "$name" '.items[] | select(.name == $n)' "$WORK/skills.json")
    if [ -n "$skill" ]; then
      id=$(jq -r .id <<<"$skill")
      seq=$(jq -r .latest_seq <<<"$skill")
      enabled=$(jq -r .enabled <<<"$skill")
      pinned=$(jq -r '.pinned_version_id // empty' <<<"$skill")
      echo "online: id $id, latest seq $seq, enabled $enabled${pinned:+, PINNED to version $pinned}"
      [ "$enabled" = true ] || echo "  note: disabled; not served until enabled in Console"
      [ -z "$pinned" ] || echo "  note: pinned; a new version is not served until unpinned in Console"
    else
      echo "online: none (import creates it disabled)"
    fi

    if [ "$DRY_RUN" = 1 ]; then
      if [ -n "$skill" ]; then
        online_files "$id" "$seq" "$WORK/$name.online"
        echo "local vs online seq $seq:"
        if compare_files "$WORK/$name.local" "$WORK/$name.online"; then
          echo "would upload $name.zip: same content, no new version expected"
        else
          echo "would upload $name.zip: content differs, a new version expected"
        fi
      else
        echo "would upload $name.zip as a new skill"
      fi
      continue
    fi

    local result new_id new_seq risk
    result=$(api POST /skills/import -F "package=@$WORK/$name.zip;type=application/zip")
    new_id=$(jq -r .skill.id <<<"$result")
    new_seq=$(jq -r .version.seq <<<"$result")
    risk=$(jq -r '.risk // [] | length' <<<"$result")
    if [ -n "$skill" ] && [ "$new_seq" = "$seq" ]; then
      echo "uploaded: content unchanged, still seq $new_seq (no new version)"
    else
      echo "uploaded: id $new_id, new seq $new_seq"
    fi
    [ "$risk" = 0 ] || echo "  risk findings: $risk (see Console)"
    online_files "$new_id" "$new_seq" "$WORK/$name.online"
    echo "local vs online seq $new_seq:"
    compare_files "$WORK/$name.local" "$WORK/$name.online" || failed=1
  done
  STEP="verify skills"
  [ "$failed" = 0 ] || die "some files do not match"
}

# ----------------------------------------------------------------- scaffold
TEMPLATE='"template \(.id) \"\(.name)\" (v\(.scaffold_version) / \(.scaffold_ref))"'
CATEGORY='"category \(.id) \(.display_name | if type == "object" then ([.[]] | first) else . end) enabled \(.enabled) template_id \(.template_id)"'

# switch_categories OLD NEW: moves enabled App categories on template OLD to
# NEW (a dry run only lists them) and reports the rest unchanged. OLD is null
# when nothing should move; NEW is null in a dry run before upload.
switch_categories() {
  local old=$1 new=$2 ids id
  step "app categories"
  api GET /app-categories >"$WORK/categories.json"
  ids=$(jq -r --argjson o "$old" '.[] | select(.enabled and .template_id == $o) | .id' \
    "$WORK/categories.json")
  [ -n "$ids" ] || [ "$old" = null ] || echo "no enabled category on template $old"
  for id in $ids; do
    if [ "$DRY_RUN" = 1 ]; then
      echo "would switch $(jq -r --arg id "$id" ".[] | select(.id == \$id) | $CATEGORY" \
        "$WORK/categories.json") to ${new/#null/the new template}"
    else
      api PUT "/app-categories/$id" -H 'Content-Type: application/json' \
        --data "{\"template_id\": $new}" >/dev/null
      echo "switched category $id from template $old to $new"
    fi
  done
  if [ "$DRY_RUN" = 0 ] && [ -n "$ids" ]; then
    api GET /app-categories >"$WORK/categories.json"
    for id in $ids; do
      jq -e --arg id "$id" --argjson n "$new" '.[] | select(.id == $id and .template_id == $n)' \
        "$WORK/categories.json" >/dev/null || die "category $id is not on template $new"
    done
  fi
  jq -r --argjson o "$old" --argjson n "$new" --argjson dry "$DRY_RUN" "
    .[] | select(.template_id != \$n and (\$dry == 1 and .enabled and .template_id == \$o | not))
    | \"not changed: \" + $CATEGORY" "$WORK/categories.json"
}

run_scaffold() {
  step "pack scaffold"
  local ref sha zip version sref zsize
  ref=${ARGS[0]:-origin/$BRANCH}
  sha=$(origin_sha "$SCAFFOLD_REPO" "$ref")
  echo "Tier0-App-Scaffold $ref @ $sha"
  zip=$WORK/Tier0-App-Scaffold.zip
  git -C "$SCAFFOLD_REPO" archive --format=zip --prefix=Tier0-App-Scaffold/ -o "$zip" "$sha"
  version=$(unzip -p "$zip" Tier0-App-Scaffold/package.json | jq -r '.tier0Scaffold.version // empty')
  sref=$(unzip -p "$zip" Tier0-App-Scaffold/package.json | jq -r '.tier0Scaffold.ref // empty')
  [ -n "$version" ] && [ -n "$sref" ] || die "package.json has no tier0Scaffold version/ref"
  zsize=$(wc -c <"$zip" | tr -d ' ')
  [ "$zsize" -le $((500 * MIB)) ] || die "zip is $zsize bytes > 500MiB"
  echo "package: v$version / $sref, zip $zsize bytes"

  connect

  step "list templates"
  api GET /templates >"$WORK/templates.json"
  local default existing
  default=$(jq -r '.[] | select(.is_default) | .id' "$WORK/templates.json")
  default=${default:-null}
  echo "online default: $(jq -r --argjson d "$default" ".[] | select(.id == \$d) | $TEMPLATE" \
    "$WORK/templates.json")"
  existing=$(jq -r --argjson v "$version" --arg r "$sref" \
    '[.[] | select(.scaffold_version == $v and .scaffold_ref == $r)] | map(.id) | join(" ")' \
    "$WORK/templates.json")
  if [ -n "$existing" ]; then
    echo "v$version / $sref is already online as template $existing; not uploading"
    switch_categories null "$default"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    echo "would upload v$version / $sref as template \"v$version\", then set it default"
    switch_categories "$default" null
    return
  fi

  step "upload template"
  local id
  id=$(api POST /templates/upload -F "name=v$version" \
    -F "description=Scaffold v$version (${sha:0:7}, ref $sref)" \
    -F "file=@$zip;filename=Tier0-App-Scaffold-v$version.zip;type=application/zip" | jq -r .id)
  echo "uploaded: template $id"

  step "verify template"
  api GET /templates | jq -e --argjson id "$id" --argjson v "$version" --arg r "$sref" \
    '.[] | select(.id == $id and .scaffold_version == $v and .scaffold_ref == $r)' >/dev/null ||
    die "template $id does not report v$version / $sref; not setting default"

  step "set default"
  api POST "/templates/$id/set-default" >/dev/null
  api GET /templates | jq -e --argjson id "$id" '.[] | select(.id == $id and .is_default)' \
    >/dev/null || die "template $id is not default after set-default"
  echo "template $id (v$version / $sref) is default"
  switch_categories "$default" "$id"
}

run_categories() {
  connect
  step "list templates"
  api GET /templates >"$WORK/templates.json"
  local current previous
  current=$(jq -c '.[] | select(.is_default)' "$WORK/templates.json")
  [ -n "$current" ] || die "no default template"
  previous=$(jq -c --argjson v "$(jq .scaffold_version <<<"$current")" \
    '[.[] | select(.scaffold_version != null and .scaffold_version < $v)]
     | max_by([.scaffold_version, .created_at]) // empty' "$WORK/templates.json")
  echo "default: $(jq -r "$TEMPLATE" <<<"$current")"
  echo "previous scaffold: $([ -n "$previous" ] && jq -r "$TEMPLATE" <<<"$previous" || echo none)"
  switch_categories "$(jq -r '.id // "null"' <<<"${previous:-null}")" "$(jq -r .id <<<"$current")"
}

case $MODE in
  skill) run_skills ;;
  scaffold) run_scaffold ;;
  categories) run_categories ;;
esac
[ "$DRY_RUN" = 0 ] || echo "dry run: no write calls made"
