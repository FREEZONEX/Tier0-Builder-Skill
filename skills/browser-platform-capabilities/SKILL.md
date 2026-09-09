---
name: browser-platform-capabilities
description: >-
  Guide Builder when creating or extending apps that need QR/barcode scanning,
  photo capture, geolocation, audio recording, file reading, or clipboard access.
  Select compatible browser APIs, explain device and embedding limits, and
  implement real fallbacks for these six basic capabilities.
---

# Browser Platform Capabilities

Turn business requirements into usable browser interactions. Choose the path
with the broadest coverage and least permission overhead that still satisfies
the requirement. This skill provides generation guidance; it does not establish
that Tier0 has a unified capability SDK or has configured host permissions.
Do not invent platform APIs.

## Scope and References

Cover only these six basic capabilities: QR/barcode scanning, photo capture,
geolocation, audio recording, file reading, and clipboard access. Inclusion in
this catalog does not guarantee native support or permission in every browser.

Read the relevant rows in [Compatibility and Defaults](references/compatibility.md).
For photos, scanning, or recording, also read the relevant section of
[Media Capture](references/media-capture.md).

## Selection and Implementation

- Identify the required user action and target device, browser, and container
  (tab, PWA, iframe, or WebView). When unspecified, favor desktop and mobile
  browser coverage. Clarify only when a missing condition changes whether a
  required action is feasible; continue independent work meanwhile.
- Access `window` and `navigator` in the client lifecycle, not during SSR module
  initialization. Detect API availability without prompting, then request
  capture or permissions from the corresponding user action. Do not request
  every permission at startup as a support test.
- Check secure-context requirements. In an iframe, also check host headers,
  `allow`, sandbox, origin, and whether the API permits embedding. A child page
  cannot remove host restrictions. Explain missing configuration and retain
  an applicable fallback without bypassing platform authentication.
- API presence means an operation can be attempted. Distinguish unsupported,
  context-blocked, awaiting permission, denied, canceled, unavailable, running,
  successful, and failed states. Permission queries are supplementary: some
  browsers do not recognize every descriptor. `NotAllowedError` alone does not
  prove that the user denied permission.
- Report success only after the operation completes. Cancellation preserves
  existing form values; failure preserves input and offers a retry or an
  appropriate alternative. If no fallback meets the business requirement,
  block that action with a clear explanation. Never fabricate capture results.
- Preserve business meaning when falling back: an existing photo is not
  verified on-site capture, and a manually selected location is not a measured
  position. Label the source when the distinction matters.
- Release media tracks, event listeners, and object URLs on cancellation,
  replacement, or unmount. Recheck availability as the page resumes; do not
  treat one successful call as permanent support.

## User Communication

Explain only conditions relevant to the current app, in the user's language.
For example: "On a phone, take or choose a photo; on a computer, upload one.
Your report stays available if the camera cannot be opened." If live capture
is mandatory, explain that an unsupported device cannot complete that step.

Place necessary guidance beside the affected action or failure state. Keep the
full compatibility matrix and implementation details out of ordinary product
UI. In the delivery report, identify the selected path, fallback, required host
configuration, and platforms actually checked.

## Verification

Check success, cancellation, denial or lack of support, retry, and cleanup for
the implemented capability. Failed mandatory capture must prevent submission
while preserving the rest of the form. For embedded apps, check the actual
iframe and an independently accessible page when available.

A successful build or mocked API test does not prove real-device compatibility.
Report unavailable device checks as untested. Consult official documentation
before promising exact version support; a reference date is not a continuing
guarantee.
