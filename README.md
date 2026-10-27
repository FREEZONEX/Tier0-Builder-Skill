# Tier0 Builder Skills

用于需求整理、工业企业应用构建、平台迁移、响应式设计和预览排障的 Agent Skills。每个技能包含 `SKILL.md`，以及配套的参考文档或脚本，可下载到本地供支持 Agent Skills 的 AI 编程工具使用。

本分支 `feature/cloud-new-architecture-migration` 对应 Tier0 云端新架构：目标脚手架为 Tier0-App-Scaffold 同名分支（v13，App 数据存于 Tier0 UNS collections），平台 SDK 为 npm 上的 `@tier0/sdk-v2` 0.3.0。SDK 的使用技能随 SDK 包安装（`node_modules/@tier0/sdk-v2/skills/`），不在本仓库维护。

## 快速安装到 Codex

在 Codex 对话中复制发送以下内容即可，无需自行寻找安装目录：

```text
请使用 skill-installer，从 https://github.com/FREEZONEX/Tier0-Builder-Skill 的 feature/cloud-new-architecture-migration 分支安装以下技能到本地用户技能目录：
skills/app-srs
skills/app-builder
skills/align-platform-app
skills/responsive-craft
skills/browser-platform-capabilities
skills/preview-runtime-stability
请保留每个技能的完整目录及配套文件；如果本地存在同名技能，先说明差异，不要直接覆盖。完成后列出安装位置和已安装技能。
```

只需要一个技能时，也可以发送具体目录链接。例如：

```text
请使用 skill-installer 安装 https://github.com/FREEZONEX/Tier0-Builder-Skill/tree/feature/cloud-new-architecture-migration/skills/responsive-craft 到本地。
```

安装完成后，在下一轮对话中使用技能；若技能列表未更新，重启 Codex。技能安装只添加本地工作指引，不会自动安装项目依赖、配置平台账号或部署应用。

## 可安装技能

| 技能 | 用途 |
| --- | --- |
| [app-srs](skills/app-srs/SKILL.md) | 将需求整理为应用规格说明，或更新已有规格 |
| [app-builder](skills/app-builder/SKILL.md) | 按需求和规格构建应用或扩展业务模块，建议与 app-srs 一起安装 |
| [align-platform-app](skills/align-platform-app/SKILL.md) | 将应用迁移或对齐到 Tier0 脚手架 |
| [responsive-craft](skills/responsive-craft/SKILL.md) | 设计和检查多视口布局、滚动及 sticky 行为 |
| [browser-platform-capabilities](skills/browser-platform-capabilities/SKILL.md) | 实现扫码、拍照、定位、录音、文件读取和剪贴板能力 |
| [preview-runtime-stability](skills/preview-runtime-stability/SKILL.md) | 排查依赖安装、预览启动、端口和 HMR 问题 |

## 手动安装

### 1. 下载仓库

安装了 Git 的用户可以在终端执行：

```sh
git clone -b feature/cloud-new-architecture-migration https://github.com/FREEZONEX/Tier0-Builder-Skill.git
cd Tier0-Builder-Skill
```

也可以在仓库页面切换到 `feature/cloud-new-architecture-migration` 分支后点击 **Code → Download ZIP**，解压后进入仓库目录。公开仓库的下载不需要 GitHub 登录。

### 2. 复制技能到工具识别的目录

Codex 支持以下本地技能目录：

- 用户级：`~/.agents/skills/`，供当前用户的多个项目使用。
- 项目级：目标项目根目录中的 `.agents/skills/`，仅供该项目使用。

在 macOS / Linux 的终端中，从刚下载的仓库目录执行以下命令，可安装全部 6 个技能到用户目录。已有同名目录或符号链接会被跳过：

```sh
(
  set -eu
  skill_dest="$HOME/.agents/skills"
  mkdir -p "$skill_dest"
  for skill_source in skills/*; do
    [ -f "$skill_source/SKILL.md" ] || continue
    skill_name="${skill_source##*/}"
    if [ -e "$skill_dest/$skill_name" ] || [ -L "$skill_dest/$skill_name" ]; then
      printf '跳过已存在的技能：%s\n' "$skill_name"
      continue
    fi
    cp -R "$skill_source" "$skill_dest/$skill_name"
    printf '已安装：%s\n' "$skill_dest/$skill_name"
  done
)
```

只安装一个技能时，将对应技能的**整个文件夹**复制到目标目录即可。Windows 用户也可以通过文件管理器，将文件夹复制到用户主目录下的 `.agents/skills/`。安装后的结构应为：

```text
.agents/skills/
└── responsive-craft/
    ├── SKILL.md
    ├── agents/
    └── references/
```

不要只复制 `SKILL.md`，也不要把整个仓库放成 `.agents/skills/Tier0-Builder-Skill/skills/...`。技能中的相对链接依赖完整目录结构。

其他支持 Agent Skills 的工具，请按其官方说明选择技能目录，并复制完整技能文件夹。上面的路径和调用方式以 Codex 为例；不同工具的加载规则可能不同。Codex 的目录和发现规则见 [OpenAI 官方技能文档](https://developers.openai.com/codex/skills/)。

## 检查安装并使用

在目标项目中打开 Codex，让它列出可用技能，确认出现 `app-srs`、`app-builder` 或你选择的技能。在支持技能选择的界面中选择技能，也可以直接写明技能名称和任务，例如：

```text
请使用 app-srs，把以下仓库管理需求整理为 specs/spec.md，本次只整理需求。
```

```text
请使用 responsive-craft，检查当前应用在手机、平板和桌面下的布局与滚动行为。
```

Codex CLI / IDE 扩展也支持通过 `/skills` 或 `$技能名` 选择技能，例如 `$responsive-craft`。

部分技能需要目标项目源码、Tier0 脚手架、SDK、浏览器工具或平台运行环境。安装技能不会授予这些资源的访问权限；缺少依赖时，按技能给出的检查结果补齐。预览排障脚本应只用于有权操作的目标应用环境。

## 更新与卸载

- **更新**：Git 下载的副本可以在仓库目录执行 `git pull --ff-only`；ZIP 下载的副本请重新下载。对比本地已安装技能，备份自己的修改，再用新版本的完整技能文件夹替换。上述安装命令会跳过已有目录，不会替你更新它们。
- **避免重复**：如果已经通过安装器安装过技能，使用安装器报告的路径更新，不要再向另一个技能目录安装同名副本。
- **卸载**：从实际安装目录移走对应的技能文件夹即可，不需要删除项目源码。
- **未发现技能**：检查是否存在 `<技能目录>/<技能名>/SKILL.md`、配套目录是否完整，然后重启 Codex 再检查。
