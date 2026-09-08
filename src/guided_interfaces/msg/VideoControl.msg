# Copyright (c) 2026 北京航空航天大学
# SPDX-License-Identifier: Apache-2.0
# 机载控制节点发给独立视频服务的期望开关状态。
std_msgs/Header header
string source_id
uint64 sequence
bool enabled
string reason
