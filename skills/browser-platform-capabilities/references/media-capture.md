# 照片、扫码与录音

## 拍照报工：默认选择

普通“附照片报工”采用文件采集，减少对持续摄像头权限和嵌入环境的依赖。下面是入口结构示意，需接入当前应用的表单、校验和上传流程：

```html
<label>拍照
  <input type="file" accept="image/*" capture="environment" />
</label>
<label>选择照片
  <input type="file" accept="image/*" />
</label>
```

移动端由系统决定是否直接拍照；桌面通常出现文件选择器。两个入口分开，避免 capture 在某些移动端限制相册选择。不要声称此方案保证相机调用；若用户明确要求实时取景、扫描框或连续拍摄，再采用 getUserMedia。

接收 File 后校验非空、大小及可处理格式，显示真实预览并允许替换 / 删除。取消选择不清空已有照片和报工字段；处理后重置 input.value，允许再次选择同一文件。替换和卸载时释放对象 URL。区分“已选择”“上传中”“上传失败”“已上传”“报工已提交”。本地 Blob URL 不能作为永久附件地址保存。

上传走应用已有并核实可用的附件服务或平台文件契约，保存持久文件标识；不要凭本技能杜撰 SDK 方法。失败保留表单并可重试，避免重试造成重复报工。必填照片上传未完成不能提交成功；服务端仍验证文件与业务权限。

移动照片可能包含 HEIC、EXIF 方向或较大分辨率。不要通过改扩展名冒充转换；验证解码 / 预览能力，失败给重新选择或明确的格式转换路径。压缩应按业务可读性要求限制尺寸和内存，正确处理方向；无需保留的敏感元数据不要主动收集或上传。

**现场拍摄要求**：capture、文件名、EXIF、canvas 截图均不能证明真实性、时间或地点。用户要求禁止旧照片时，不能默默提供相册替代并称满足要求；应说明普通浏览器能力的证明边界，并在无法采集时阻止必填动作。

## 实时摄像头

- 客户端检测安全上下文和 `navigator.mediaDevices?.getUserMedia`；在点击后请求 `{ video: { facingMode: { ideal: 'environment' } }, audio: false }`。后摄只是偏好；不默认 exact、高分辨率或请求麦克风。
- 为视频设置 `playsInline`、`muted`，处理 play() 失败；等元数据和非零 videoWidth / videoHeight 后再抓帧。镜像预览与保存图方向分别处理；用 Blob 输出并检查结果非空。
- 处理 NotAllowedError（权限、策略等）、NotFoundError、NotReadableError 和 OverconstrainedError。约束不适配可在用户已发起的同次操作中放宽一次；拒绝后不循环弹权限。
- 提供关闭 / 取消。用户忽略权限时请求可能长期 pending：允许离开，用操作序号防止旧结果覆盖新状态；若流在取消后才返回，立即 stop 所有轨道。超时提示不代表底层权限请求已取消。
- 切换相机前、页面离开和卸载时停止旧轨道、清空 srcObject；监听轨道 ended 更新 UI。不因摄像头失败丢失表单。
- iframe 内失败先核验宿主 camera 授权和 sandbox，不能靠修改子应用代码保证解决。基础文件采集路径保留，但也应在真实容器中验证。

## 扫码

先确定 QR / EAN / Code 128 等实际码制。检查 BarcodeDetector 可用及 supported formats；不足时按需载入能覆盖目标码制的 JS/WASM 解码器，核对当前依赖、体积和目标端，不宣称 polyfill 能绕过摄像头权限。

解码循环限频，单次识别后停止或去重，避免一个码重复创建记录。图片上传可复用同一解码管线；无法识别时允许重拍或手输（如业务允许）。扫码内容是不可信输入：按业务格式和长度校验，不自动访问识别到的 URL、执行命令或提交写操作。键盘模拟扫码枪可走明确聚焦的输入框并按终止符处理。

## 录音

点击录音时才申请 `{ audio: true, video: false }`。检测 MediaRecorder，再用 `MediaRecorder.isTypeSupported()` 筛选目标端可接受的格式；无指定格式合适时可尝试浏览器默认格式，但需验证实际 recorder.mimeType 与服务端接收能力。不要统一硬编码 audio/webm 或伪装扩展名。

显示录音状态、时长与停止入口，设业务时长 / 大小上限。收集非空 dataavailable 数据，等待 stop 及最后数据事件后生成文件；处理录制 error 和空结果。结束、取消、离开时停止麦克风轨道并释放资源。后台或锁屏录音不保证持续；中断时明确显示。若允许，降级到上传录音或文本备注。

参考：[capture](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/capture)、[getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)、[MediaRecorder MIME 检测](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder/isTypeSupported_static)、[MediaRecorder stop](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder/stop_event)。
