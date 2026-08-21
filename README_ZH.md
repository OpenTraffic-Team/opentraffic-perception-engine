<div align="right">

[**English**](README.md) | [**中文**](README_ZH.md)

</div>

<div align="center">
  <img src="figure/LOGO2x.png" width="70%" style="vertical-align:-7px;" />

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.13+-green.svg?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20x86__64-orange.svg?style=for-the-badge&logo=linux&logoColor=white)]()

<br/>

[![Hugging Face](https://img.shields.io/badge/🤗%20HuggingFace-OpenTraffic-yellow.svg?style=for-the-badge)](https://huggingface.co/OpenTraffic)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/OpenTraffic-Team/opentraffic-perception-engine)
[![WeChat](https://img.shields.io/badge/WeChat%20Group-07C160?style=for-the-badge&logo=wechat&logoColor=white)](https://github.com/OpenTraffic-Team/Tir/issues/1)

</div>

### TIR — 面向城市交叉口的开源交通感知引擎

支持多路 RTSP 视频流输入、YOLO11 + DeepSort 检测与跟踪、基于单应性矩阵的坐标变换、世界坐标系速度估计、车道级结构化输出，以及基于雷达参考数据的验证。专为感知驱动的交通信号控制（Perception-Driven TSC）场景设计。

<div align="center">
  <img src="figure/Framework.png" width="90%">
</div>



## 🌟 目录

- [:clapper: 演示视频](#clapper-演示视频)
- [:loudspeaker: 新闻](#loudspeaker-新闻)
- [:clipboard: TODO 列表](#clipboard-todo-列表)
- [:rocket: 快速开始](#rocket-快速开始)
  - [环境要求](#环境要求)
  - [安装](#安装)
  - [启动 Redis](#启动-redis)
  - [准备视频流](#准备视频流)
  - [启动系统](#启动系统)
- [:pencil: 配置](#pencil-配置)
  - [摄像头字段](#摄像头字段)
  - [全局字段](#全局字段)
  - [示例](#示例)
- [:sparkles: 功能特性](#sparkles-功能特性)
- [:package: `.so` 交付版本](#package-so-交付版本)
- [:database: Redis 数据格式](#database-redis-数据格式)
- [:bar_chart: 性能](#bar_chart-性能)
- [:book: 论文](#book-论文)
- [:hugs: Hugging Face](#hugs-hugging-face)
- [:earth_asia: 社交媒体](#earth_asia-社交媒体)
- [:bookmark: 引用](#bookmark-citation)
- [:page_facing_up: 许可证](#page_facing_up-许可证)

<br/>

## :clapper: 演示视频

[![感知演示](figure/video_cover.png)](videos/perception_raw.mp4)

<br/>

## :loudspeaker: 新闻

- **[2026/05/27]** 重构 README，使其与统一的英文主页风格保持一致。
- **[2026/05/15]** TIR 首次发布，支持交叉口多方向实时感知。

<br/>

## :clipboard: TODO 列表

- [x] YOLO11 + DeepSort 检测与跟踪流水线
- [x] 四方向（E/S/W/N）数据融合
- [x] 基于单应性矩阵的像素坐标 → 雷达世界坐标变换
- [x] 实时写入 Redis Stream
- [x] 基于匈牙利算法的跨模态 ID 匹配（视觉 ↔ 雷达）
- [x] 视频帧内 OCR 时间戳提取
- [x] 车道级结构化输出
- [x] 基于雷达参考数据的验证流水线
- [ ] 将预训练模型权重发布到 Hugging Face
- [ ] 支持更多交叉口配置
- [ ] 发布技术报告 / ArXiv 论文
- [ ] Web 可视化仪表盘
- [ ] 支持更多摄像头协议

<br/>

## :rocket: 快速开始

### 环境要求

| 项目 | 要求 |
|---|---|
| 操作系统 | Linux x86_64 |
| NVIDIA 驱动 | ≥ 560 |
| CUDA | 12.6 |
| Python | 3.13+ |
| PyTorch | 2.11.0+cu126 |

### 安装

```bash
# 克隆代码仓库
git clone https://github.com/OpenTraffic-Team/opentraffic-perception-engine.git
cd opentraffic-perception-engine-main/opentraffic-TIR

# 安装依赖
pip install -r requirements.txt
```

### 启动 Redis

```bash
redis-server redis.conf
```

### 准备视频流

**使用 mediamtx 将本地视频作为 RTSP 视频流提供：**

```bash
./mediamtx mediamtx.yml
```

**或者使用 VLC 推流：**

```bash
vlc video.mp4 --sout '#rtp{sdp=rtsp://:8554/test}'
```

**也可以直接使用本地视频路径：** 将 `drivers/config.json` 中的 `rtsp_url` 字段设置为本地视频文件路径（例如 `input/45_0429.mp4`）。

> 测试视频：https://pan.baidu.com/s/1qULF2WcxUP_l5Cvs9uV-JA  密码：1234

### 启动系统

```bash
./run_local.sh
```

停止：

```bash
./stop_local.sh
```

<br/>

## :pencil: 配置

编辑 `opentraffic-TIR/drivers/config.json`。

### 摄像头字段

| 字段 | 类型 | 描述 |
|---|---|---|
| `id` | string | 摄像头 ID，格式：`{intersection_id}_{direction}` |
| `rtsp_url` | string | RTSP URL 或本地视频文件路径 |
| `window` | `[x1, y1, x2, y2]` | 检测裁剪窗口；全画面使用 `[0, 0, 1920, 1080]` |
| `H` | 3×3 matrix | 像素坐标 → 雷达坐标的单应性矩阵 |
| `H_inv` | 3×3 matrix | 雷达坐标 → 像素坐标的逆矩阵（若省略，则根据 H 自动计算） |
| `radar_variant` | string | 坐标变体，默认值为 `"default"` |
| `radar_redis_key` | string | 该摄像头输出对应的 Redis key |

### 全局字段

| 字段 | 描述 |
|---|---|
| `debugMode` | 启用详细的跟踪日志 |
| `jsonlOutputDir` | JSONL 输出目录 |
| `radarReferenceJsonl` | 用于验证的雷达参考文件 |
| `matchTargetDir` | 用于跨模态 ID 匹配的雷达 JSON 输出目录 |
| `matchTimeMaxDeltaMs` | 时间戳匹配的最大容差（毫秒） |
| `vehicleMatchMaxDist` | 车辆中心点匹配的最大距离（米） |
| `localRedisConfig.host` | Redis 服务器地址 |
| `localRedisConfig.password` | Redis 密码 |
| `data_processing.upload_interval_sec` | JSON 合并与上传间隔（秒） |

### 示例

```json
{
  "intersection": {
    "id": "HHL_QHDD",
    "name": "Honghua Road",
    "cameras": [
      {
        "id": "HHL_QHDD_S",
        "rtsp_url": "./input/45_0429.mp4",
        "window": [0, 0, 1920, 1080],
        "H": [[...], [...], [...]],
        "H_inv": [[...], [...], [...]],
        "radar_variant": "default",
        "radar_redis_key": "origin_info_state:HHL_QHDD"
      }
    ]
  },
  "debugMode": false,
  "jsonlOutputDir": "./control_group_fullspeed_jsonl",
  "radarReferenceJsonl": "./reference_radar/HHL_QHDD_S/HHL_QHDD_S_shard_00000.jsonl",
  "vehicleMatchMaxDist": 10.0,
  "localRedisConfig": {
    "host": "127.0.0.1",
    "port": 6379,
    "db": 0,
    "password": "your_password"
  },
  "data_processing": {
    "upload_interval_sec": 1
  }
}
```

<br/>

## :sparkles: 功能特性

### :oncoming_automobile: 车辆检测

- 面向交叉口视频进行车辆检测和多目标跟踪（YOLO11 + DeepSort）。
- 兼容 RTSP 视频流和本地视频文件。
- 识别引擎编译为 `.so` 以实现加速，并输出结构化目标 ID，供下游模块使用。

### :world_map: 世界坐标输出

- 将图像空间中的目标投影到世界坐标系。
- 使用标定后的单应性矩阵（H / H_inv）完成像素坐标到世界坐标的映射。
- 输出雷达风格的坐标，便于下游系统集成。

### :dash: 世界坐标系速度估计

- 基于卡尔曼滤波的 `SimpleVelocityEstimator` 在世界坐标系中估计目标速度。
- 为每个跟踪车辆输出结构化速度字段（m/s）。
- 支持交通状态分析，并可与雷达参考数据进行速度对比。

### :motorway: 车道级输出

- 将检测到的目标与车道语义进行关联。
- 生成车道级结构化结果，供控制系统使用。

### :clock1: 时间戳提取

- 使用 OCR 从视频帧中提取时间戳，以实现精确的时间对齐。

### :link: 跨模态 ID 匹配

- 使用匈牙利算法，根据 ID 将视觉目标与外部雷达数据进行对齐。

<br/>

## :package: `.so` 交付版本

本节适用于自包含的 `.so` 交付包，该版本无需完整源代码即可运行。

### 包含的资源

| 资源 | 路径 |
|---|---|
| 输入视频 | `input/45_0429.mp4` |
| 雷达参考数据 | `reference_radar/HHL_QHDD_S/HHL_QHDD_S_shard_00000.jsonl` |
| Python 环境 | `.venv` |
| 启动脚本 | `run_local.sh` |
| 停止脚本 | `stop_local.sh` |

### 运行

启动：

```bash
cd /tir-0513-git-so
./run_local.sh
```

停止：

```bash
cd /tir-0513-git-so
./stop_local.sh
```

### 输出格式

默认输出目录：

```text
control_group_fullspeed_jsonl/HHL_QHDD_S/HHL_QHDD_S_shard_00000.jsonl
```

输出 JSONL 字段：

| 字段 | 描述 |
|---|---|
| `timestamp_ms` | 视频帧时间戳（毫秒） |
| `intersection_id` | 交叉口 ID |
| `camera_id` | 摄像头 ID |
| `source` | 数据来源 |
| `coordinate_space` | 坐标空间 |
| `vehicles[].id` | 车辆 ID |
| `vehicles[].center` | 车辆中心坐标（米） |
| `vehicles[].speed` | 速度向量（m/s） |
| `vehicles[].speed_scalar` | 速度标量（m/s） |
| `vehicles[].lane` | 车道 |
| `vehicles[].type` | 车辆类型 |

<br/>

## :database: Redis 数据格式

结果会写入两个 Redis key：

- **快照（Snapshot）**：`recognition_{camera_id}_snap`
- **流（Stream）**：`recognition_{camera_id}`

四方向合并后的快照格式（`origin_info_state:{intersection_id}`）：

```json
{
  "code": "HHL_QHDD",
  "name": "Honghua Road",
  "recognitionSnap[HHL_QHDD_E]": {
    "timestamp": 1734400000.0,
    "vehicles": [
      {
        "id": "42",
        "orig_id": "7",
        "type": "",
        "lane": "",
        "center": [12.5, 8.3],
        "speed": [3.2, -1.1],
        "licenseNum": ""
      }
    ]
  }
}
```

| 字段 | 描述 |
|---|---|
| `timestamp` | 视频帧时间戳，单位为秒（通过 OCR 提取） |
| `id` | 雷达匹配后的目标 ID |
| `orig_id` | 原始视觉跟踪 ID（匹配前） |
| `center` | 世界坐标 `[x, y]`，单位为米 |
| `speed` | 速度分量 `[vx, vy]`，单位为 m/s |
| `type` | 车辆类型（若可用） |
| `licenseNum` | 车牌号码（若可用） |

<br/>

## :bar_chart: 性能

> 评估方式：历史全量速度 JSONL 与原始雷达 JSONL 进行对比。

### 字段误差对比

| 字段 | 平均值 | 中位数（p50） | p75 | p90 | 说明 |
|---|---|---|---|---|---|
| `timestamp_ms` 误差（ms） | 25.04 | 26.5 | 37 | 46 | 视频帧与最近雷达帧之间的时间差 |
| `vehicles[].center` 误差（m） | 2.5132 | 1.6251 | 3.1987 | 6.7021 | 已匹配目标的空间位置误差 |
| `vehicles[].speed_scalar` 误差（m/s） | 1.6727 | 0.3176 | 1.7741 | 5.0061 | 已匹配目标的速度标量误差 |

### 字段一致性

| 字段 | 对比方式 | 一致性 |
|---|---|---|
| `intersection_id` | 完全匹配 | **100%** |
| `camera_id` | 完全匹配 | **100%** |
| `coordinate_space` | 完全匹配 | **100%** |
| `timestamp_ms` | 在 200 ms 内对齐 | **100%** |
| `vehicles[].lane` | 与雷达数据完全匹配 | **100%** |

<br/>

## :book: 论文

- 标题：`OpenTraffic Perception System for Perception-Driven TSC`
- 状态：`准备中 / 待发布`

<br/>

## :hugs: Hugging Face

- 模型页面：`https://huggingface.co/OpenTraffic-Team`
- 计划发布：
  - 打包后的感知模型
  - 示例输出结果
  - 基准测试示例

<br/>

## :earth_asia: 社交媒体

- GitHub：`https://github.com/OpenTraffic-Team/Tir`
- 微信群：[加入讨论](https://github.com/OpenTraffic-Team/Tir/issues/1)
- X / Twitter：`即将上线`

<br/>


## :page_facing_up: 许可证

本项目基于 [Apache 2.0 License](LICENSE) 发布。

---

<div align="center">
  <b>OpenTraffic Team</b> | 让城市交通更智能。
</div>
