<!-- Scope of original additions, adapted upstream code and shared runtime dependencies. -->
# 软件来源与改进范围

登记名称：无人机点云避障与局部轨迹规划软件 V1.0。

## 开源基础

原始算法工程为 [HKU-MARS/dyn_small_obs_avoidance](https://github.com/hku-mars/dyn_small_obs_avoidance)，固定版本 `9d25dd6974e04518c892e5711c9be9082558e5eb`，上游维护者 kongfz。沿用 GNU GPL version 3；原许可全文保存在 `LICENSE`，详细来源在 `THIRD_PARTY_NOTICES.md`。原工程对 [Fast-Planner](https://github.com/HKUST-Aerial-Robotics/Fast-Planner) 的致谢继续保留。

`src/path_searching/include/path_searching/kinodynamic_astar.h` 和 `src/path_searching/src/kinodynamic_astar.cpp` 是基于上游动力学搜索的改进实现，包含上游继承的搜索原语、启发式多项式求解、末端三次曲线、空间索引及双树地图设计。程序交存包含这两个经过改进的完整文件；继承部分的版权继续归原权利人，按 GPLv3 授权使用。

## 本软件的改进与新增内容

- 将搜索核心与 ROS 通信分离，使用现代 C++ 类型及独立配置提供 ROS 2 Jazzy 原生构建。
- 改进边界、碰撞及轨迹检查，加入水平向量速度/加速度限额、分方向约束、超限初速减速和垂直运动代价。
- 提供 ROS 2 点云、里程计和目标节点，按照目标、时间、位移及路径阻挡触发重规划。
- 提供持久目标、幂等设置、取消及会话/目标/结果身份；输出精确多项式段和其位置、速度、加速度采样。
- 提供面向机载应用的任务/坐标桥接，连接原生规划结果与机载执行接口。
- 本次独立提取只调整包内配置路径、构建/运行入口及测试产物位置，规划与桥接生产算法沿用冻结实现。

上述移植、改进及机载接入修改者为 LostPatrol。申报时使用实际作者、著作权人名称替换账号标识，并按真实职务开发、合作开发和权属协议填写。

## 配套依赖及既有四项边界

`src/guided_interfaces`、`src/correction_interfaces` 是原套件的共用接口，本项附带其源码供构建使用，不在本项源程序交存中重复编排。`path_planning` 的消息/服务定义属于本项原生规划接口，FPGA 项可将其作为兼容接口依赖。

`avoidance_backend_manager.py` 和 `avoidance_backend_process.py` 属于 CPU/FPGA 后端切换和进程管理的共用配套，不计入本项交存主体。测试、演示、编译和启动脚本用于验证及使用，不以其充实生产算法体量。

已有机载软著负责参考接续、轨迹跟踪、飞控输出和航点任务执行。本项负责点云地图、局部规划及规划接入；已有地面站负责操作和状态显示，定位校准、媒体管理的软件边界保持原样。
