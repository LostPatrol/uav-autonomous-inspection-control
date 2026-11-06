<!-- 独立媒体软件模块与维护入口。 -->
# 视频处理与媒体管理模块

操作与安装见 [软件 README](../README.md)。

采集链路由 `camera_app/controller.py` 统一管理，FFmpeg 打开一次摄像头，将原生 H.264/MJPEG 同时交给 MediaMTX 发布和录像封装；抓拍从本机流读取。`camera_app/panel.py` 提供本机、机载和指定 RTSP 三种来源，`camera_app/ros_client.py` 连接机载视频接口。

`onboard_media.py` 维护会话与主动推流，`media_transfer.py` 维护 SQLite 上传队列、rsync 传输及 ACK 确认。`ground_media.py` 提供 HTTP、FTP、RTSP 与会话处理，`media_store.py` 负责核验入库、图片去畸变、索引和容量管理。`file_manager_app.py` 提供检索、预览、另存下载和重建操作。

`ground_relay.py` 选择实际可用的处理后端；Intel 使用 VAAPI/OpenCL，NVIDIA 使用 NVDEC/OpenCL/NVENC，AMD 使用 VAAPI/Vulkan，CPU 使用 PyAV/OpenCV/libx264。几何模型统一使用 `relay_calibration.py` 的五参数镜头模型与 alpha=0 投影。

地面配置为 `config/ground/media.json`；机载参数由 `config/aircraft.local.env` 选择 `config/aircraft/<ID>/video/`；相机内参位于 `config/video/Wasintek/intrinsics.yaml`。

需要开机运行时使用 `deploy/install_ground_media.sh` 或 `deploy/install_onboard_video_service.sh`。`--install-only` 仅安装服务定义。
