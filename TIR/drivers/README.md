Author: 聂生元
Date: 2025-03-01
Version: 1.0


drivers/ - 驱动程序主目录
│
├── config.json - sensor配置文件
│   - 包含传感器、视频等设备的配置参数
│
├── ra_config.py - 载入配置文件
│   - 载入具体参数配置
│
├── redis_drivers/ - Redis数据库驱动目录
│   - Redis连接和操作的相关驱动
│
├── video_drivers/ - 视频设备驱动目录
│   - 摄像头等视频设备的驱动程序
│   - 视频流的采集和处理
│
├── utils/ - 工具函数目录
│   - 包含各类辅助功能和工具函数
│   - 为驱动程序提供通用功能支持
|
├── sensor_driver.py - 传感器驱动主程序
│   - 负责各类传感器的驱动管理
│   - 处理传感器数据的采集和预处理
│