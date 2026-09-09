# 兼容性与默认路径

资料核对日期：2026-09-09。以下是生成方案的默认候选范围，不是对所有版本、Chromium 衍生浏览器、操作系统、企业策略或 WebView 的保证。用 API 检测和真实调用确认可用性，不能仅凭 UA 开关功能。iOS 上的浏览器品牌不等于桌面同品牌的硬件 API 支持。

## 跨平台基础目录

| 能力 | 默认路径与检测 | 降级与关键边界 |
| --- | --- | --- |
| 拍照 | 单张采集优先 `input[type=file]` + `accept="image/*"`，拍照入口附 `capture="environment"`；实时取景才用 `navigator.mediaDevices?.getUserMedia` | 单独保留无 capture 的照片选择入口；capture 不保证打开相机或后摄。详见媒体参考 |
| 扫码 | 相机流 + 解码；检测 `BarcodeDetector` 及 `getSupportedFormats()` 是否覆盖目标码制 | 原生解码不足时按需加载经过验证的 JS/WASM 解码器；图片解码和手输条码作为业务允许的替代。不要仅靠 BarcodeDetector |
| 定位 | `navigator.geolocation.getCurrentPosition`；HTTPS、用户权限；设业务合理的 timeout / maximumAge | 拒绝、超时、不可用分别处理；允许手动选地点时标明来源。保留 accuracy 和采集时间；不能把 IP、默认工厂位置或旧值当实时 GPS，不承诺室内精度 |
| 录音 | 麦克风流 + `MediaRecorder`；检测类和 MIME 支持 | 不固定 WebM；允许上传音频或文本备注时提供替代。无可用格式时说明限制；详见媒体参考 |
| 文件选择读取 | `input[type=file]` + File / Blob，按数据类型读取 | 文件范围由用户选择；accept 只是选择提示，仍校验实际内容和大小；不声称有任意路径访问权，不把浏览器选择等同上传成功 |
| 剪贴板入口 | 点击复制调用 `navigator.clipboard?.writeText`，按需实现读取或 paste 事件 | read 与 write 分开检测和授权；不自动读取。失败给可选文本及手动复制 / 粘贴入口；不默认用废弃 execCommand，不承诺任意格式 |
| 页面内提醒 | 现有 toast、状态栏或内联消息，必要时用 aria-live | 不需要系统通知权限；页面关闭后不能继续提醒。关键待办保留在业务列表，不能只短暂闪现 |
| 屏幕常亮 | `navigator.wakeLock?.request('screen')`，仅在活动可见页面按需申请 | 处理 release；回到可见且用户仍启用时再申请。低电量、系统策略或旧浏览器可能拒绝；显示未启用，不能用循环视频假装常亮，不保证后台运行 |

## 按端增强目录

所有增强入口均须检测接口、实际权限和失败结果；不满足条件时提供替代或明确错误。

| 能力 | 默认候选端 / API | 约束与替代 |
| --- | --- | --- |
| 文件原地写入 | 桌面 Chromium，`showOpenFilePicker` / `showSaveFilePicker`、handle.createWritable | 用户选择并授权目标；下载导出只能作为另存副本，不能报原文件已更新 |
| 目录读写 | 桌面 Chromium，`showDirectoryPicker` | 只处理选中目录范围，读 / 写授权分开；上传若干文件或导出包替代。OPFS 存储不等于访问用户目录 |
| 串口 | 桌面 Chromium，`navigator.serial` | 明确波特率、协议和设备筛选；移动端不按原生 Web Serial 支持承诺 |
| HID | 桌面 Chromium，`navigator.hid` | 需要设备报告协议，部分用途受保护；普通键盘模拟扫码枪优先输入框接收，不必 WebHID |
| 多屏管理 | 桌面 Chromium，`window.getScreenDetails` | 需要 window-management 权限；打开窗口仍受弹窗限制；无权限保留单屏布局 |
| 屏幕共享 | 支持的桌面浏览器，`navigator.mediaDevices?.getDisplayMedia` | 用户每次选择共享面；不能静默选择屏幕，系统音频随浏览器 / 系统 / 共享面不同；移动端不默认支持 |
| BLE | 支持的桌面 Chromium + Android Chrome，`navigator.bluetooth` | 指 BLE GATT，不是经典蓝牙通用通信；桌面 Linux 等系统存在额外限制，不以 Chromium 名称保证可用 |
| USB | 支持的桌面 Chromium + Android Chrome，`navigator.usb` | 需要可访问的设备接口、驱动及协议，受保护类别不能通用访问；USB 连接不等于设备兼容 |
| NFC | Android Chrome，`NDEFReader` | 仅支持范围内的 NDEF 标签；不承诺门禁卡、银行卡、底层任意 NFC 或 iOS Web NFC |
| 运动与方向 | 支持的 iOS / Android 浏览器，DeviceMotionEvent / DeviceOrientationEvent | 检测可选 requestPermission 并在手势中调用；事件存在不代表有有效数据，设置等待上限；无数据提供手动控制，不承诺罗盘精度或后台采样 |
| 系统通知 | 按桌面、移动 SW、iOS 主屏幕三条路径实现 | 不使用单一 notificationSupported 标记。见增强参考 |

## 官方资料入口

- [HTML capture](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/capture)、[getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)、[Permissions Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Permissions_Policy)
- [BarcodeDetector](https://developer.mozilla.org/en-US/docs/Web/API/BarcodeDetector)、[Geolocation](https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API)、[File API](https://developer.mozilla.org/en-US/docs/Web/API/File_API)
- [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)、[Screen Wake Lock](https://developer.mozilla.org/en-US/docs/Web/API/Screen_Wake_Lock_API)
- [File System Access](https://developer.chrome.com/docs/capabilities/web-apis/file-system-access)、[Window Management](https://developer.chrome.com/docs/capabilities/web-apis/window-management)、[屏幕共享](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getDisplayMedia)
- [Web Serial](https://developer.chrome.com/docs/capabilities/serial)、[WebHID](https://developer.chrome.com/docs/capabilities/hid)、[Web Bluetooth](https://developer.chrome.com/docs/capabilities/bluetooth)、[WebUSB](https://developer.chrome.com/docs/capabilities/usb)、[Web NFC](https://developer.chrome.com/docs/capabilities/nfc)
- [传感器权限](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent/requestPermission_static)
