<!-- 地面媒体处理与系统服务部署说明。 -->
# 媒体服务部署

在软件根目录执行 `./setup.sh`，安装 FFmpeg、ffprobe、v4l-utils、rsync、OpenSSH 与 MediaMTX v1.20.0。先以 `./run.sh ground` 验证配置，再用 `./video_service/deploy/install_ground_media.sh` 安装 systemd 服务。仅安装可加 `--install-only`。

## 主机配置

`config/ground/media.json` 的 `root` 设置媒体根目录，`listen` 设置监听地址，`public_host` 设置访问地址；默认 HTTP 8090、RTSP 8554、FTP 2121、FTP 被动端口 30000～30019。机载 `upload_root` 与地面 `root` 对应，`upload_target` 使用已配置 SSH 密钥的主机别名。

`backend` 设为 `auto` 时实际探测 Intel、NVIDIA、AMD 与 CPU。CPU 需要 PyAV、OpenCV、NumPy；Intel 需要 VAAPI 与 OpenCL，NVIDIA 需要匹配 FFmpeg 的 NVDEC/NVENC/OpenCL 驱动，AMD 需要 VAAPI、Vulkan 与 libplacebo。`gpu.intel.device`、`gpu.nvidia.cuda_device`、`gpu.amd.device` 可指定设备。

`intrinsics` 设置五参数相机内参，`bitrate` 和 `gop` 设置编码参数；图像宽高与相机配置对应。每次会话保存内参与编码配置，历史重建沿用会话参数。`max_bytes` 控制总容量，`delivery_timeout_seconds` 控制落地后的交付等待时间。

## 服务管理

```bash
sudo systemctl status ground-media.service
sudo journalctl -u ground-media.service -n 100
sudo systemctl restart ground-media.service
```

机载端在本机执行 `./build.sh` 构建共享接口，然后使用 `./video_service/deploy/install_onboard_video_service.sh`。采集启停与抓拍由独立视频接口管理。
