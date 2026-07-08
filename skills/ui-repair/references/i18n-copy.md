# Product Language And Copy

Use this reference when product copy, localization, or mixed-language UI matters.

## Locale Decision

Choose one default product language for the finished app surface:

1. Explicit user request wins.
2. Otherwise use the current conversation language.
3. Otherwise use the dominant language in `specs/spec.md`, PRD, or supplied
   requirement text.
4. Otherwise follow the dominant language already used by the existing app.

Do not infer that every app must be English because code identifiers are
English. Do not infer that every app must be Chinese because earlier examples
were Chinese.

## Rules

- Keep visible product UI in one language unless bilingual output was explicitly
  requested.
- Do not mix Chinese page content with English buttons, dialog actions, loading
  text, error text, sidebar labels, or accessibility labels.
- Do not add a global i18n framework, message catalog, locale switcher, or
  runtime dictionary unless the user explicitly asks for multi-locale support.
- Translate human-facing copy, not machine identifiers such as API paths, env
  vars, TypeScript names, enum keys, or database identifiers.
- Match `html lang`, page metadata, overlay defaults, toast copy, validation
  copy, and shell labels to the chosen product language.
- Keep copy short, operational, and domain-specific.

## Audit Checklist

Check these surfaces before finishing:

- page titles, descriptions, breadcrumbs, and metadata
- login/session copy and app shell labels
- sidebar labels, badges, and empty states
- buttons, menus, tooltips, icon-button labels, and `aria-label`
- dialogs, drawers, confirm text, footer actions, and close labels
- loading, empty, validation, error, pending, and toast messages
- table headers, filters, statuses, and action labels

Useful searches:

```bash
rg -n 'Application|Workspace|Loading|Save|Cancel|Confirm|Back home|Sign in|Overview|Monitor|Review|Station' src
rg -n --hidden --glob '!node_modules/**' --glob '!dist/**' --glob '!.git/**' '[\p{Han}]' .
```
