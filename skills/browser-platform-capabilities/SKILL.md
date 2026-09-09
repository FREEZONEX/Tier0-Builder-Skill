---
name: browser-platform-capabilities
description: >-
  Guide Builder when creating or extending apps that use browser-native platform
  capabilities: photo work reporting (拍照报工), QR/barcode scanning, location,
  audio recording, local files, clipboard, wake lock, screen sharing, notifications,
  sensors, or hardware connections. Select compatible APIs, explain device and
  embedding limits, and implement real fallbacks. Use for browser capability
  selection and integration, not ordinary backend CRUD or platform messaging alone.
---

# Browser Platform Capabilities

将业务需求转成可用的浏览器交互。优先选择目标设备覆盖最广、权限负担最小且满足业务要求的路径。本技能是生成指导，不代表 Tier0 已提供统一能力 SDK、已配置宿主权限或已部署任何集成服务；不要编造这些接口。

## 能力分层

1. **跨平台基础目录**：扫码、拍照、定位、录音、文件选择读取、剪贴板入口、页面内提醒、屏幕常亮。基础目录表示默认考虑这些业务能力，不表示所有浏览器都原生支持、无需权限或无需降级。
2. **按端增强**：桌面 Chromium 的文件原地写入、目录读写、串口、HID、多屏管理；桌面浏览器的屏幕共享；桌面 Chromium 与 Android Chrome 的 BLE、USB；Android Chrome 的 NFC；iOS / Android 的运动与方向传感器。具体浏览器、系统、硬件和嵌入条件仍需检测。系统通知拆分为桌面通知、移动端 Service Worker 通知和 iOS 主屏幕 Web Push。
3. **受控集成**：局域网访问、外设连接及写入。兼容性可用并不授权对任意目标、设备或指令开放调用。

## 选择与实现

- 从需求确定必须完成的动作，以及设备、浏览器、普通标签页 / PWA / iframe / WebView。用户未限定端时，基础流程默认兼顾桌面和移动浏览器；不要为一般能力选择阻塞生成。只有缺少目标设备或协议会改变必需功能是否可实现时，才澄清该条件，同时推进独立工作。
- 查阅 [兼容性与默认路径](references/compatibility.md) 中相关行。涉及照片、扫码或录音，继续读 [媒体采集](references/media-capture.md)。涉及增强 API、通知或外部目标，读 [增强与受控集成](references/controlled-integrations.md)。只读相关部分。
- 在客户端生命周期中访问 `window` / `navigator`，避免 SSR 导入阶段执行。先做无提示的 API 检测，再由用户点击发起采集、权限或设备选择；不要用启动时申请所有权限来判断支持情况。
- 对受保护 API 检查安全上下文。iframe 还要核验宿主响应头、`allow`、sandbox、origin 及 API 是否允许嵌入。子页面不能自行解除宿主限制；报告所缺配置并保留可用替代入口。不要修改平台鉴权或绕过宿主来“修复”权限。
- API 存在仅代表可尝试。分别处理未支持、上下文阻止、等待授权、已拒绝、已取消、设备不可用、执行中、成功和失败；权限查询仅作辅助，浏览器可能不支持某个 permission descriptor。不要把所有 `NotAllowedError` 都判定为用户拒绝。
- 只有操作实际完成才显示成功。取消选择保持原表单；失败保留输入并提供手动重试或替代路径。没有满足业务要求的替代方案时明确阻止该动作，不能伪造照片、坐标、扫描结果或设备回执。
- 降级不能改变业务含义而不说明：上传旧照片不是已验证现场拍摄；手填位置不是定位结果；文件下载不是覆盖原文件；指令发出不是设备已执行。
- 退出、取消或组件卸载时释放媒体轨道、连接、监听器、对象 URL 和常亮锁。页面恢复后按当前业务状态重新检测，不永久缓存一次成功为“永远可用”。

## 向用户说明

只解释影响当前应用使用的条件，沿用用户语言。例如：“手机可拍照或选择照片，电脑可上传照片；相机不可用时仍可保留报工内容。”若必须实时拍摄，应明确不支持的设备不能提交，而不是承诺上传照片也满足要求。

把必要说明放在相应操作入口、失败状态或设置页；不要把全部兼容性表或内部技术过程塞进产品 UI。交付说明写明所选路径、降级行为、需要宿主配合的条件，以及实际验证过的端。

## 验证边界

验证所实现能力的成功、取消、拒绝 / 不支持、重试及退出清理；必填采集失败时应阻止提交，其他表单内容应保留。涉及 iframe 时分别检查实际嵌入页和有权限访问的独立页面；通知分别验证订阅与送达，设备写入分别验证传输与协议回执。

构建成功或模拟 API 通过不代表真机可用。无法使用目标设备时记录未实测项，不声称全平台兼容。精确版本承诺前查官方资料；参考文件的日期不是自动续期的兼容性保证。
