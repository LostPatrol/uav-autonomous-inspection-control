# Build the shared planning protocol independently of the CPU planner implementation.
cmake_minimum_required(VERSION 3.16)
project(path_planning LANGUAGES C CXX)
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(std_msgs REQUIRED)
find_package(builtin_interfaces REQUIRED)
find_package(trajectory_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/PolynomialSegment.msg" "msg/PlanResult.msg" "srv/PlanMotion.srv" "srv/SetGoal.srv"
  DEPENDENCIES std_msgs builtin_interfaces trajectory_msgs geometry_msgs)
ament_export_dependencies(rosidl_default_runtime)
ament_package()
