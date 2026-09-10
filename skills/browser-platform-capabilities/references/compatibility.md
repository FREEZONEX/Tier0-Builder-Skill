# Compatibility and Defaults

Sources checked: 2026-09-09. These are default implementation candidates, not
guarantees for every browser version, operating system, enterprise policy, or
WebView. Confirm availability through feature detection and actual calls,
not user-agent checks alone.

| Capability | Default path and detection | Fallback and limits |
| --- | --- | --- |
| QR/barcode scanning | Camera stream plus decoding. Check `BarcodeDetector` and whether `getSupportedFormats()` covers the required formats. | Load a suitable, verified JS/WASM decoder when native decoding is insufficient. Offer image decoding or manual entry if allowed by the workflow. Do not depend on BarcodeDetector alone. |
| Photo capture | For individual photos, prefer `input[type=file]` with `accept="image/*"`; add `capture="environment"` to the capture entry. Use `navigator.mediaDevices?.getUserMedia` for live previews. | Keep a separate photo picker without capture. The capture attribute does not guarantee a camera or rear-camera launch. See the media reference. |
| Geolocation | `navigator.geolocation.getCurrentPosition`, subject to HTTPS and permission. Set suitable timeout and maximumAge values. | Distinguish denial, timeout, and unavailable position. Allow manual location selection only when the workflow permits it, and label its source. Retain accuracy and capture time. Never present an IP estimate, factory default, or stale position as a fresh measurement; do not promise indoor precision. |
| Audio recording | Microphone stream plus `MediaRecorder`; detect the class and supported MIME types. | Do not hardcode WebM. Offer audio upload or a text note if acceptable. Explain when no usable format is available. See the media reference. |
| File reading | `input[type=file]` plus File / Blob, read according to the content type. | Read only user-selected files. The accept attribute is a picker hint: still validate content and size. Selection does not mean upload has completed. |
| Clipboard | Copy from a user action using `navigator.clipboard?.writeText`; implement explicit reading or paste events only as needed. | Detect and authorize reading and writing separately. Do not read automatically. On failure, offer selectable text and manual copy/paste. Avoid relying on deprecated execCommand or promising arbitrary format support. |

## File Reading

Use `text()`, `arrayBuffer()`, or FileReader as appropriate for the existing
stack. Bound file size and parsing work; prefer streaming or chunking for large
inputs where supported. Handle empty files, unexpected encoding, malformed
content, read failures, and cancellation without discarding existing form data.
For text-based imports, show validation errors before applying records. Render
file content as data rather than executing it or injecting untrusted HTML.

Reset the file input after handling a selection so the same file can be chosen
again. Release preview object URLs on replacement or unmount. If persistence
is required by the app, use its verified attachment contract and distinguish
local reading from upload and business submission.

## Clipboard

Invoke protected clipboard methods directly from the relevant user interaction;
unrelated asynchronous work before the call may lose transient activation.
Check secure context and iframe policy where applicable. A visible, editable
paste field can provide a fallback without programmatic clipboard reading.
Show "Copied" only after writeText resolves, and preserve editable content
when a read or write fails. Format-specific clipboard handling needs separate
support checks; text support does not establish image support.

## Official References

- [HTML capture](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/capture)
- [getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)
- [Permissions Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Permissions_Policy)
- [BarcodeDetector](https://developer.mozilla.org/en-US/docs/Web/API/BarcodeDetector)
- [Geolocation](https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API)
- [File API](https://developer.mozilla.org/en-US/docs/Web/API/File_API)
- [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
