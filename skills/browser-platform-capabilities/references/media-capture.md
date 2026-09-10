# Photos, Scanning, and Audio Recording

## Photo Work Reporting: Default Path

For ordinary reports with photo attachments, prefer file capture to reduce
dependence on continuous camera access and embedding permissions. Adapt these
entry points to the app's form, validation, and upload flow:

```html
<label>Take a photo
  <input type="file" accept="image/*" capture="environment" />
</label>
<label>Choose a photo
  <input type="file" accept="image/*" />
</label>
```

The mobile operating system determines whether capture opens directly; desktop
browsers commonly show a file picker. Separate entries preserve photo-library
selection on mobile implementations where capture restricts it. Do not promise
that this path always opens a camera. Use getUserMedia when the requirement
needs a live preview, scanning overlay, or continuous capture.

Validate that the selected File is nonempty, within size limits, and in a
processable format. Show its real preview and allow replacement or removal.
Cancellation must preserve the existing photo and report fields. Reset
input.value after handling the selection to allow choosing the same file again.
Release object URLs on replacement or unmount. Distinguish selected, uploading,
upload failed, uploaded, and report submitted. A local Blob URL is not a
persistent attachment address.

Upload through the app's existing, verified attachment service or platform file
contract and save a durable file identifier. Do not invent SDK methods. Retain
the form on failure and avoid duplicate reports on retry. A required photo must
finish uploading before submission succeeds; validate files and business
permissions on the server as well.

Mobile photos may use HEIC, EXIF orientation, or large dimensions. Renaming an
extension is not conversion. Check decoding and preview behavior, and offer
reselection or an explicit conversion path when necessary. Bound compression
size and memory use while retaining business readability and correct
orientation. Avoid collecting unnecessary sensitive metadata.

**On-site capture requirements:** capture, filenames, EXIF, and canvas snapshots
do not establish trustworthy proof of authenticity, time, or place. If existing
photos are prohibited, do not silently substitute photo-library selection and
claim compliance. Explain the browser's proof limitations and block the
required step when capture is unavailable.

## Live Camera

- Detect secure context and `navigator.mediaDevices?.getUserMedia` on the client.
  From a user action, request
  `{ video: { facingMode: { ideal: 'environment' } }, audio: false }`.
  Rear-camera selection is a preference. Avoid exact constraints, excessive
  resolution, or microphone access unless required.
- Set `playsInline` and `muted` on the preview; handle play() failure. Wait for
  metadata and nonzero videoWidth / videoHeight before capturing a frame.
  Handle preview mirroring separately from saved orientation. Check that the
  resulting Blob is nonempty.
- Handle NotAllowedError (including policy failures), NotFoundError,
  NotReadableError, and OverconstrainedError. If constraints are unsuitable,
  relax them once within the user-initiated operation. Do not repeatedly
  prompt after denial.
- Provide cancellation. Ignored permission prompts can leave a request pending:
  allow the user to leave and use an operation identifier to reject stale
  results. Stop all tracks if a stream arrives after cancellation. A timeout
  message does not cancel the underlying permission request.
- Stop previous tracks and clear srcObject when switching cameras, leaving,
  or unmounting. Handle track ended events. Preserve the rest of the form.
- For iframe failures, check host camera permissions and sandbox restrictions.
  Child-app code alone cannot guarantee a fix. Retain file capture where
  applicable and verify it in the actual container.

## QR/Barcode Scanning

Identify the actual formats, such as QR, EAN, or Code 128. Check BarcodeDetector
and its supported formats. If insufficient, load a JS/WASM decoder covering the
required formats; verify current dependencies, size, and target platforms.
A decoder cannot bypass camera permissions.

Limit decoding frequency and stop or deduplicate after a successful scan so
one code cannot create repeated records. Reuse decoding for selected images.
Offer recapture or manual entry when permitted. Treat decoded content as
untrusted input: validate business format and length rather than automatically
following URLs, executing commands, or submitting changes.

## Audio Recording

Request `{ audio: true, video: false }` only when recording starts. Detect
MediaRecorder and use `MediaRecorder.isTypeSupported()` to choose a usable MIME
type. If no preferred format is supported, the browser default may be attempted,
but verify recorder.mimeType and the receiving service's format support.
Do not hardcode audio/webm across browsers or disguise formats with extensions.

Show recording state, duration, and a stop action; apply business limits on
duration and size. Collect nonempty dataavailable chunks and wait for the final
data event and stop event before creating the file. Handle recorder errors and
empty output. Stop microphone tracks and release resources when finished,
canceled, or leaving. Background or locked-screen recording is not guaranteed;
show interruptions explicitly. Offer audio upload or a text note if the
business workflow allows it.

## Official References

- [HTML capture](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/capture)
- [getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)
- [MediaRecorder MIME detection](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder/isTypeSupported_static)
- [MediaRecorder stop](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder/stop_event)
