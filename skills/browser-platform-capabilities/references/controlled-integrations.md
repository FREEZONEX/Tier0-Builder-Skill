# 增强能力与受控集成

## 系统通知分路径

| 路径 | 条件与实现 | 失败与边界 |
| --- | --- | --- |
| 桌面页面通知 | 检测 Notification，HTTPS，在明确的“启用通知”操作后请求权限；支持的桌面可使用页面 Notification | 页面通知不是后台推送服务；denied 时展示设置指引或页面内提醒，不反复请求 |
| 移动端 Service Worker 通知 | 检测 navigator.serviceWorker、ServiceWorkerRegistration 的 showNotification；取得活动 registration，再显示通知 | 不默认用 new Notification()，多数移动浏览器不能这样构造；有 SW 不等于有推送订阅或后台定时能力 |
| iOS / iPadOS 主屏幕 Web Push | 支持版本（16.4 起）的主屏幕 Web App，通过用户手势授权；核验安装方式、PushManager、SW、订阅和真实推送服务 | 普通标签页不能据此承诺接收推送；提示从主屏幕打开并验证，不能只检测 Notification 就显示“支持” |

分别维护通知接口可用、授权状态、SW 就绪、Push 接口可用、订阅状态和最近实际送达结果。后台推送还需要真实服务端订阅存储和推送发送链路；未配置时只交付已实现的页面提醒，不伪造订阅成功。不要新建一套无必要的推送系统：先核对已有平台通知服务是否适合该业务。

保留退出订阅和降级入口。定时器、常亮锁、页面通知均不保证页面关闭后的提醒或准时送达。浏览器允许通知也不保证系统免打扰、网络和电源策略下送达。

资料：[Notifications API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API/Using_the_Notifications_API)、[WebKit iOS Web Push](https://webkit.org/blog/13878/web-push-for-web-apps-on-ios-and-ipados/)。

## 文件、屏幕与设备

- **文件写入**：先让用户选择文件 / 目录，再按读或读写模式取得授权；持久化 handle 不保证后续仍有权限。写入前明确目标和覆盖范围，按业务动作提交内容，完成 writable.close() 后才报告文件保存成功；失败不报成功，下载副本也不能称原地保存。
- **屏幕共享**：点击发起 getDisplayMedia，始终由用户选择共享面；不能通过 constraints 静默强选或永久授权。监听 ended 并停止录制 / 推流，退出时 stop 轨道。只在确有需求时请求音频，并检查实际音轨；不要承诺所有端都能捕获系统声音。
- **多屏**：请求屏幕信息后按实际可用屏幕布局；处理拔屏、权限拒绝和弹窗阻止，回落单窗口。不为绕开阻止反复开窗。
- **传感器**：若事件类暴露 requestPermission，在点击时申请并检查结果；未暴露该方法不代表拒绝。只在业务页面订阅，校验数值非 null / 有限且及时，超时给手动替代；退出取消监听。
- **设备连接**：使用已知设备类型和服务 / 接口筛选条件；用户选择后核对设备和协议。BLE 仅请求需要的 GATT services；USB/HID/串口需要明确接口或命令协议。没有协议说明就不能凭设备名称编造读写字节。
- **断开与写入**：断开后更新状态并释放 reader / writer 锁及连接；不要自动重放可能已执行的动作。区分连接、传输完成、设备协议回执和业务完成；超时记为结果未知，先查询状态或让用户核对后再重试。
- **NFC**：限定 NDEF 读写及业务记录类型；识别读取、写入和 makeReadOnly 的不同风险。永久只读或覆盖需用户明确动作与目标提示，不能顺带执行。

## 局域网与对外开放

浏览器请求发自用户设备；云端代理不能天然访问用户局域网。HTTPS、安全上下文、CORS、混合内容、浏览器 Local Network Access 权限、企业策略和目标服务认证是独立条件。不要把 `mode: 'no-cors'` 当成读写兼容方案；opaque 响应不能证明业务操作成功。不要建议关闭浏览器安全策略。

只在需求需要集成时实现以下边界，不把普通本地拍照变成额外审批流程：

- 用已配置的目标标识映射允许的协议、主机、端口、路径和方法，限制请求体、超时及频率。避免向调用者暴露任意 URL 转发器或任意原始设备命令入口。
- 设备按允许型号 / 服务 / 接口和用户选中实例限制，操作按读、写、覆盖、控制等独立授权；前端筛选器是选择便利性，不替代网关或服务端鉴权。
- 对外接口绑定真实调用者、租户、业务权限和目标；跨窗口消息同时校验 origin、source、结构与操作范围，不接受通配来源。浏览器授权某个 origin 不代表所有外部调用者都被授权。
- 若需后端或本地代理，在该可信边界重新校验目标和操作；处理 DNS 解析、重定向后的目标，阻止绕过允许范围及访问非预期内部 / 元数据服务。只为明确业务接入部署认证代理，不能顺带创建开放代理。
- 写入明确目标、参数范围、可执行命令和成功回执；按业务风险提供确认、幂等或状态核验，保存必要审计。不要自动重试结果未知的非幂等写入。

这些是生成目标规则，不是宣称现有 Tier0 已实施这些控制。无法核验实际集成或权限时明确缺失条件，先提供可工作的手动导入 / 导出流程（业务允许时），不伪造实时设备数据。

资料：[Local Network Access](https://developer.chrome.com/blog/local-network-access)、[Web Serial](https://developer.chrome.com/docs/capabilities/serial)、[WebHID](https://developer.chrome.com/docs/capabilities/hid)、[Web Bluetooth](https://developer.chrome.com/docs/capabilities/bluetooth)、[Web NFC](https://developer.chrome.com/docs/capabilities/nfc)。
