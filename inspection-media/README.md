<!-- 独立视频处理与媒体管理软件的功能和运行入口。 -->
# 无人机巡检视频处理与媒体管理软件 V1.0

面向无人机巡检影像的独立媒体软件，包含机载采集、地面处理和媒体管理三个部分。机载端一次打开摄像头，同步提供原始直播、录像及抓拍；地面端完成镜头去畸变、处理版直播和录像入库；文件管理窗口按飞机、任务与日期检索影像，提供预览、下载、删除和原片重建。

## 安装

推荐 Ubuntu 24.04、Python 3.12。机载 ROS 接口使用 ROS 2 Jazzy。系统准备 FFmpeg、ffprobe、v4l-utils、rsync、OpenSSH 和 MediaMTX v1.20.0；MediaMTX 安装到 PATH 或 `/usr/local/bin/mediamtx`。地面界面使用 PySide6，CPU 去畸变使用 PyAV、OpenCV 和 NumPy。

```bash
sudo apt install python3-venv ffmpeg v4l-utils rsync openssh-client python3-colcon-common-extensions
./setup.sh
# 使用机载 ROS 接口时，在对应主机安装 ROS 2 Jazzy 后执行：
./build.sh
```

## 运行

首次运行编辑 `config/ground/media.json`：`root` 为独立媒体存储根，`public_host` 为客户端可达地址，`backend` 可选 auto、intel、nvidia、amd、cpu。相机内参由 `intrinsics` 指定，默认档案为 Wasintek 1920×1080 五参数模型。

```bash
./run.sh ground                 # HTTP、FTP、RTSP 与地面媒体处理
./run.sh camera                 # 摄像头控制和实时预览
./run.sh files                  # 独立文件管理
./run.sh service status         # 本机摄像头后台状态
./run.sh onboard                # 机载 ROS 视频服务
```

`PYTHON=/path/to/python ./run.sh files` 可指定已经安装依赖的 Python 环境。`GROUND_MEDIA_CONFIG=/path/to/media.json` 可指定另一份地面配置。关闭界面后，独立媒体后台继续处理录像与文件传输。

机载配置位于 `config/aircraft/simulation/video/`，选择器为 `config/aircraft.local.env`。部署时设置实际设备、压缩格式、分辨率和帧率，并填写 `push_url`、`public_url`、`ground_api`、`upload_target` 和 `upload_root`。地面接收目录与机载上传目录须对应，SSH 目标使用部署人员配置的主机别名。

## 使用流程

1. 启动地面后台，确认存储与网络地址。
2. 打开摄像头面板，选择本机、机载或指定 RTSP 来源，核对地址与采集设置。
3. 开启采集后播放直播，录像在后台保存；通过“保存当前图片”或 ROS 航点事件抓拍。
4. 打开文件管理，按飞机、任务和日期筛选媒体；选择图片预览，选择录像打开或另存下载。
5. 对保留完整原片的录像选择“从原片整段重建”，完成后下载新生成的处理版。

## 代码结构

| 目录或文件 | 职责 |
| --- | --- |
| `video_service/camera_app`、`camera_service.py` | 摄像头配置、后台状态机、本机控制与预览 |
| `onboard_video_node.py`、`onboard_media.py` | ROS 机载视频入口、会话关联与主动推流 |
| `media_transfer.py` | 持久上传队列、差分传输与入库确认 |
| `ground_media.py`、`media_store.py` | 媒体接收、SQLite 索引、服务接口与容量管理 |
| `ground_relay.py`、`relay_cpu.py`、`shaders` | GPU/CPU 去畸变处理与编码 |
| `file_manager.py`、`file_manager_app.py` | 检索、预览、下载与原片重建窗口 |
| `src/guided_interfaces` | 与机载控制软件共享的 ROS 接口依赖 |
| `ground_station_core/qt_ui` | 共享窗口装饰依赖 |

媒体核心登记范围为 `video_service` 的自有实现。共享接口、窗口装饰、开源媒体工具与运行库按依赖使用，详见仓库的第三方说明。
