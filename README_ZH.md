<div align="right">

**中文** | [**English**](README.md)

</div>

<div align="center">
  <img src="figure/LOGO2x.png" width="70%" style="vertical-align:-7px;" />

[![Paper](https://img.shields.io/badge/Paper-A42C25?style=for-the-badge&logo=arxiv&logoColor=white)](https://arxiv.org/abs/XXXX.XXXXX)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.13+-green.svg?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20x86__64-orange.svg?style=for-the-badge&logo=linux&logoColor=white)]()

<br/>

[![Hugging Face](https://img.shields.io/badge/🤗%20HuggingFace-OpenTraffic-yellow.svg?style=for-the-badge)](https://huggingface.co/OpenTraffic-Team)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/OpenTraffic-Team/Tir)
[![WeChat](https://img.shields.io/badge/WeChat%20Group-07C160?style=for-the-badge&logo=wechat&logoColor=white)](https://github.com/OpenTraffic-Team/Tir/issues/1)

</div>

### TIR — 开源交通感知引擎，面向城市路口场景

支持多路 RTSP 输入、YOLO11 + DeepSort 检测跟踪、单应性矩阵坐标转换、世界坐标系速度估计、车道级结构化输出与雷达基准校验。专为感知驱动型交通信号控制（Perception-Driven TSC）场景设计。

<div align="center">
  <img src="figure/Framework.png" width="90%">
</div>

<br/>

> **论文:** https://arxiv.org/abs/XXXX.XXXXX  
> **项目主页:** https://opentraffic-team.github.io/tir  
> **HuggingFace:** https://huggingface.co/OpenTraffic-Team  
> **GitHub:** https://github.com/OpenTraffic-Team/Tir

<br/>

## 🌟 目录

- [:clapper: 演示视频](#clapper-演示视频)
- [:loudspeaker: 更新动态](#loudspeaker-更新动态)
- [:clipboard: TODO 列表](#clipboard-todo-列表)
- [:rocket: 快速开始](#rocket-快速开始)
  - [环境要求](#环境要求)
  - [安装依赖](#安装依赖)
  - [启动 Redis](#启动-redis)
  - [准备视频流](#准备视频流)
  - [启动系统](#启动系统)
- [:pencil: 配置说明](#pencil-配置说明)
  - [相机配置字段](#相机配置字段)
  - [全局配置字段](#全局配置字段)
  - [配置示例](#配置示例)
- [:sparkles: 功能特性](#sparkles-功能特性)
- [:package: .so 交付版本](#package-so-交付版本)
- [:database: Redis 数据格式](#database-redis-数据格式)
- [:bar_chart: 性能指标](#bar_chart-性能指标)
- [:book: 论文](#book-论文)
- [:hugs: Hugging Face](#hugs-hugging-face)
- [:earth_asia: 社交媒体](#earth_asia-社交媒体)
- [:bookmark: 引用](#bookmark-引用)
- [:page_facing_up: 许可证](#page_facing_up-许可证)

<br/>

## :clapper: 演示视频

[![Perception Demo](figure/video_cover.png)](videos/perception_raw.mp4)

<br/>

## :loudspeaker: 更新动态

- **[2026/05/27]** 重构 README，统一英文主页风格。
- **[2026/05/15]** TIR 首次发布，支持实时多方向路口感知。

<br/>

## :clipboard: TODO 列表

- [x] YOLO11 + DeepSort 检测跟踪管线
- [x] 四方向（E/S/W/N）数据融合
- [x] 单应性矩阵像素 → 雷达世界坐标转换
- [x] 实时 Redis Stream 写入
- [x] 匈牙利算法跨模态 ID 匹配（视觉 ↔ 雷达）
- [x] 帧内 OCR 时间戳提取
- [x] 车道级结构化输出
- [x] 雷达基准校验管线
- [ ] 预训练模型权重发布至 HuggingFace
- [ ] 支持更多路口配置
- [ ] 发布技术报告 / ArXiv 论文
- [ ] Web 可视化看板
- [ ] 支持更多相机协议

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

### 安装依赖

```bash
# 克隆仓库
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

**使用 mediamtx 将本地视频推成 RTSP 流：**

```bash
./mediamtx mediamtx.yml
```

**或使用 VLC 推流：**

```bash
vlc video.mp4 --sout '#rtp{sdp=rtsp://:8554/test}'
```

**或直接使用本地视频文件路径：** 将 `drivers/config.json` 中的 `rtsp_url` 字段设为本地文件路径（如 `input/45_0429.mp4`）。

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

## :pencil: 配置说明

编辑 `opentraffic-TIR/drivers/config.json`。

### 相机配置字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 相机 ID，格式：`{路口ID}_{方向}` |
| `rtsp_url` | string | RTSP 地址或本地视频文件路径 |
| `window` | `[x1, y1, x2, y2]` | 检测裁剪窗口；全帧使用 `[0, 0, 1920, 1080]` |
| `H` | 3×3 矩阵 | 像素 → 雷达坐标单应性矩阵 |
| `H_inv` | 3×3 矩阵 | 雷达 → 像素逆矩阵（若省略则从 H 自动计算） |
| `radar_variant` | string | 坐标变体，默认 `"default"` |
| `radar_redis_key` | string | 该相机的 Redis 输出键 |

### 全局配置字段

| 字段 | 说明 |
|---|---|
| `debugMode` | 启用详细跟踪日志 |
| `jsonlOutputDir` | JSONL 输出目录 |
| `radarReferenceJsonl` | 用于校验的雷达基准文件 |
| `matchTargetDir` | 跨模态 ID 匹配的雷达 JSON 输出目录 |
| `matchTimeMaxDeltaMs` | 时间戳匹配最大容差（毫秒） |
| `vehicleMatchMaxDist` | 车辆中心匹配最大距离（米） |
| `localRedisConfig.host` | Redis 服务器地址 |
| `localRedisConfig.password` | Redis 密码 |
| `data_processing.upload_interval_sec` | JSON 合并与上传间隔（秒） |

### 配置示例

```json
{
  "intersection": {
    "id": "HHL_QHDD",
    "name": "红花路",
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

- 对路口视频进行车辆检测与多目标跟踪（YOLO11 + DeepSort）。
- 兼容 RTSP 流与本地视频文件。
- 识别引擎编译为 `.so` 加速，输出结构化目标 ID 供下游使用。

### :world_map: 世界坐标输出

- 将图像空间目标投影到世界坐标系。
- 使用标定好的单应性矩阵（H / H_inv）进行像素到世界坐标的映射。
- 输出雷达风格的坐标，便于下游集成。

### :dash: 世界速度估计

- 基于卡尔曼滤波的 `SimpleVelocityEstimator` 估计目标在世界坐标系中的速度。
- 输出每个被跟踪车辆的结构化速度字段（m/s）。
- 支持交通状态解析，可与雷达基准进行速度对比。

### :motorway: 车道级输出

- 将检测目标关联到车道语义。
- 生成车道级结构化结果，供控制系统消费。

### :clock1: 时间戳提取

- OCR 从视频帧中提取时间戳，实现精确时间对齐。

### :link: 跨模态 ID 匹配

- 匈牙利算法将视觉目标与外部雷达数据按 ID 对齐。

<br/>

## :package: .so 交付版本

本节适用于独立 `.so` 交付包，无需完整源码即可运行。

### 包含资源

| 资源 | 路径 |
|---|---|
| 输入视频 | `input/45_0429.mp4` |
| 雷达基准数据 | `reference_radar/HHL_QHDD_S/HHL_QHDD_S_shard_00000.jsonl` |
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

| 字段 | 说明 |
|---|---|
| `timestamp_ms` | 帧时间戳（毫秒） |
| `intersection_id` | 路口 ID |
| `camera_id` | 相机 ID |
| `source` | 数据来源 |
| `coordinate_space` | 坐标空间 |
| `vehicles[].id` | 车辆 ID |
| `vehicles[].center` | 车辆中心坐标（米） |
| `vehicles[].speed` | 速度矢量（m/s） |
| `vehicles[].speed_scalar` | 速度标量（m/s） |
| `vehicles[].lane` | 所在车道 |
| `vehicles[].type` | 车辆类型 |

<br/>

## :database: Redis 数据格式

结果写入两个 Redis 键：

- **快照**：`recognition_{camera_id}_snap`
- **流**：`recognition_{camera_id}`

合并四方向快照格式（`origin_info_state:{intersection_id}`）：

```json
{
  "code": "HHL_QHDD",
  "name": "红花路",
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

| 字段 | 说明 |
|---|---|
| `timestamp` | 帧时间戳，秒（OCR 提取） |
| `id` | 雷达匹配后的目标 ID |
| `orig_id` | 视觉跟踪原始 ID（匹配前） |
| `center` | 世界坐标 `[x, y]`（米） |
| `speed` | 速度分量 `[vx, vy]`（m/s） |
| `type` | 车辆类型（如有） |
| `licenseNum` | 车牌号（如有） |

<br/>

## :bar_chart: 性能指标

> 评测方式：历史全量速度 JSONL 与原始雷达 JSONL 对比。

### 字段误差对比

| 字段 | 均值 | 中位数 (p50) | p75 | p90 | 备注 |
|---|---|---|---|---|---|
| `timestamp_ms` 误差（ms） | 25.04 | 26.5 | 37 | 46 | 视频帧与最近雷达帧的时间差 |
| `vehicles[].center` 误差（m） | 2.5132 | 1.6251 | 3.1987 | 6.7021 | 匹配目标的空间位置误差 |
| `vehicles[].speed_scalar` 误差（m/s） | 1.6727 | 0.3176 | 1.7741 | 5.0061 | 匹配目标的速度标量误差 |

### 字段一致性

| 字段 | 对比方式 | 一致性 |
|---|---|---|
| `intersection_id` | 精确匹配 | **100%** |
| `camera_id` | 精确匹配 | **100%** |
| `coordinate_space` | 精确匹配 | **100%** |
| `timestamp_ms` | 200ms 内对齐 | **100%** |
| `vehicles[].lane` | 与雷达精确匹配 | **100%** |

<br/>

## :book: 论文

- 标题：`OpenTraffic Perception System for Perception-Driven TSC`
- 状态：`撰写中 / 待发布`
- 占位链接：`https://arxiv.org/abs/XXXX.XXXXX`

<br/>

## :hugs: Hugging Face

- 模型页面：`https://huggingface.co/OpenTraffic-Team`
- 计划发布：
  - 打包的感知模型
  - 样本输出结果
  - 基准测试样例

<br/>

## :earth_asia: 社交媒体

- GitHub：`https://github.com/OpenTraffic-Team/Tir`
- 微信群：[加入讨论](https://github.com/OpenTraffic-Team/Tir/issues/1)
- X / Twitter：`即将上线`

<br/>

## :bookmark: 引用

如果 TIR 对您的研究有帮助，请引用：

```bibtex
@article{tir2026,
  title   = {TIR: Real-Time Traffic Situation Awareness for Urban Intersections},
  author  = {OpenTraffic Team},
  journal = {arXiv preprint},
  year    = {2026}
}
```

<br/>

## :page_facing_up: 许可证

本项目基于 [Apache 2.0 许可证](LICENSE) 发布。

---

<div align="center">
  <b>OpenTraffic Team</b> | 让城市交通更智能。
</div>
