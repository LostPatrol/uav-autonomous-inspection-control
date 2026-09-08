# Copyright (c) 2026 北京航空航天大学
# SPDX-License-Identifier: Apache-2.0
"""上位机地面站核心包：高层协议客户端、本地仿真编排与 GUI。"""

from .config import PROJECT_ROOT
from .models import FlightMode

__all__ = ["FlightMode", "PROJECT_ROOT"]
