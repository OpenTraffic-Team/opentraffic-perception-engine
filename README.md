<div align="center">
  <img src="figure/LOGO2x.png" width="70%" style="vertical-align:-7px;" />

[![Hugging Face](https://img.shields.io/badge/Models-fcd022?style=for-the-badge&logo=huggingface&logoColor=white)](https://huggingface.co/OpenTraffic-Team) [![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/OpenTraffic-Team/Tir)

</div>

### TIR 交通态势感知系统 — 基于视觉的交叉口实时交通感知，支持多路 RTSP 视频流接入，YOLO11 + DeepSort 检测跟踪，单应矩阵坐标转换，结果写入 Redis Stream。

<br/>

<div id="top" align="center">
<p align="center">
<img src="figure/Framework.png" width="90%" />
</p>
</div>

> **Paper:** https://arxiv.org/abs/XXXX.XXXXX  
> **Project Page:** https://opentraffic-team.github.io/tir  
> **HuggingFace:** https://huggingface.co/OpenTraffic-Team  
> **GitHub:** https://github.com/OpenTraffic-Team/Tir

---

## News!

- **[2026/05/15]** 发布 TIR 初始版本，支持多方向交叉口实时感知。

---

## TODO List

- [x] YOLO11 + DeepSort 检测跟踪流水线。
- [x] 东/南/西/北四方向数据融合。
- [x] 单应矩阵像素坐标 → 雷达世界坐标转换。
- [x] Redis Stream 实时写入。
- [x] 匈牙利算法跨模态 ID 匹配（视觉 ↔ 雷达）。
- [x] OCR 帧内时间戳提取。
- [ ] 发布预训练模型权重至 HuggingFace。
- [ ] 支持更多交叉口配置。
- [ ] 发布技术报告 / ArXiv 论文。
- [ ] Web 可视化看板。
- [ ] 支持更多摄像头协议。

---

## Table of Contents

- [Quick Start](#quick-start)
- [System Architecture](#system-architecture)
- [Environment Requirements](#environment-requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the System](#running-the-system)
- [Redis Data Format](#redis-data-format)
- [Performance](#performance)
- [Citation](#citation)
- [License](#license)

---

## Quick Start

### 1. 克隆仓库

```bash
git clone https://github.com/OpenTraffic-Team/Tir.git
cd Tir
```

### 2. 安装依赖

**方式一：使用打包好的 conda 虚拟环境（推荐）**

链接: https://pan.baidu.com/s/17hgVxfpdaldXHnu3zdRFrQ 提取码: 1234

```bash
mkdir -p py314_env
tar -xzf py314_env.tar.gz -C py314_env
source py314_env/bin/activate
conda-unpack
```

**方式二：从 requirements.txt 安装**

```bash
pip install -r requirements.txt
```

### 3. 启动 Redis

```bash
redis-server redis.conf
```

### 4. 准备视频流

**使用 mediamtx 将本地视频转为 RTSP 流：**

```bash
./mediamtx mediamtx.yml
```

**或使用 VLC 推流：**

```bash
vlc 视频文件.mp4 --sout '#rtp{sdp=rtsp://:8554/test}'
```

**或直接填写本地视频路径：** 在 `drivers/config.json` 的 `rtsp_url` 字段填写本地视频路径（如 `HHL/48_20251217_093510.mp4`）。

> 测试视频获取：链接: https://pan.baidu.com/s/1qULF2WcxUP_l5Cvs9uV-JA 提取码: 1234

### 5. 启动系统

```bash
python run.py
```

按 `q` + 回车退出。

---

## System Architecture

```
RTSP 视频流 / 本地视频文件
        │
        ▼
capProcessMain (采集进程)
  └─ Rtsp_driver  ← 拉流 / 读帧，维护摄像头健康状态
        │  multiprocessing.Queue
        ▼
recProcessMain (识别进程)
  ├─ Recognizer (YOLO11 + DeepSort .so)  ← 检测 + 跟踪
  ├─ pixel_to_radar (H_inv 单应矩阵)     ← 像素 → 世界坐标
  ├─ SimpleVelocityEstimator             ← 速度估计
  ├─ recognize_digits_from_region (OCR)  ← 帧内时间戳提取
  └─ 匈牙利算法 ID 匹配 (scipy)          ← 与雷达数据对齐
        │
        ├─ JSON 文件落盘 (json_out_pipei_*)
        └─ Redis Stream 写入
```

**核心模块：**

- **多路视频采集**：并发拉取东/南/西/北四方向 RTSP 流，支持本地视频文件。
- **目标检测与跟踪**：YOLO11 检测 + DeepSort 跟踪，识别引擎编译为 `.so` 加速。
- **坐标转换**：单应矩阵（H / H_inv）将像素坐标映射至雷达世界坐标。
- **速度估计**：基于卡尔曼滤波的 `SimpleVelocityEstimator`，输出单位 m/s。
- **时间戳提取**：OCR 从视频帧提取时间戳，保证时序准确性。
- **跨模态匹配**：匈牙利算法将视觉目标与外部雷达数据进行 ID 对齐。
- **双进程架构**：采集进程与识别进程解耦，通过 `multiprocessing.Queue` 通信。

---

## Environment Requirements

| 项目 | 要求 |
|---|---|
| 操作系统 | Linux x86_64 |
| NVIDIA 驱动 | ≥ 560 |
| CUDA | 12.6 |
| Python | 3.14（虚拟环境已打包） |
| PyTorch | 2.11.0+cu126 |

---

## Installation

### 项目结构

```
dist_linux/
├── run.py                             # 启动入口，调用 main.Tir().polling()
├── requirements.txt                   # Python 依赖（含 CUDA 版本锁定）
├── drivers/
│   ├── config.json                    # 系统配置文件
│   ├── service.cpython-314-*.so       # 识别服务调度（编译版）
│   ├── ra_config.cpython-314-*.so     # 配置加载（编译版）
│   ├── merge_json_to_snap.py          # 多方向 JSON 合并工具
│   ├── cal_h_v926.py                  # 单应矩阵标定工具
│   ├── calculate_m1.py                # M1 矩阵计算工具
│   └── valid_m1_m2.py                 # M1/M2 矩阵验证工具
├── recognizer/
│   ├── recognizer.cpython-314-*.so    # YOLO11 检测封装（编译版）
│   ├── tracker.py                     # DeepSort 跟踪封装
│   ├── deep_sort_pytorch/             # DeepSort 实现
│   └── ultralytics/                   # YOLO11 模型库
└── mediamtx.yml                       # mediamtx 推流配置
```

> `service.so` 和 `recognizer.so` 为预编译的 CPython 3.14 扩展，仅支持 Linux x86_64。

---

## Configuration

编辑 `drivers/config.json`：

```json
{
  "intersection": {
    "id": "HHL_QHDD",
    "name": "弘化路",
    "cameras": [
      {
        "id": "HHL_QHDD_E",
        "rtsp_url": "rtsp://127.0.0.1:8554/east",
        "window": [0, 0, 1920, 1080],
        "H": [[...], [...], [...]],
        "H_inv": [[...], [...], [...]],
        "radar_variant": "default",
        "radar_redis_key": "origin_info_state:HHL_QHDD"
      }
    ]
  },
  "debugMode": false,
  "localRedisConfig": {
    "host": "127.0.0.1",
    "port": 6379,
    "db": 0,
    "password": "your_password"
  },
  "matchTargetDir": "/path/to/radar/output",
  "vehicleMatchMaxDist": 10.0,
  "data_processing": {
    "upload_interval_sec": 1
  }
}
```

### 摄像头配置字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 摄像头唯一标识，格式 `{交叉口ID}_{方向}` |
| `rtsp_url` | string | RTSP 地址或本地视频文件路径 |
| `window` | `[x1, y1, x2, y2]` | 识别区域裁剪窗口，全帧填 `[0, 0, 1920, 1080]` |
| `H` | 3×3 矩阵 | 像素 → 雷达坐标单应矩阵 |
| `H_inv` | 3×3 矩阵 | 雷达 → 像素坐标逆矩阵（缺省时自动对 H 求逆） |
| `radar_variant` | string | 坐标转换变体，默认 `"default"` |
| `radar_redis_key` | string | 该摄像头对应的 Redis 写入 key |

### 全局配置字段

| 字段 | 说明 |
|---|---|
| `debugMode` | 开启后打印详细跟踪日志 |
| `matchTargetDir` | 雷达 JSON 输出目录，用于跨模态 ID 匹配 |
| `matchTimeMaxDeltaMs` | 时间戳匹配最大容差（毫秒） |
| `vehicleMatchMaxDist` | 车辆中心点匹配最大距离（米） |
| `localRedisConfig.host` | Redis 服务器地址 |
| `localRedisConfig.password` | Redis 密码 |
| `data_processing.upload_interval_sec` | JSON 合并上传间隔（秒） |

---

## Running the System

### 启动主程序

```bash
python run.py
```

按 `q` + 回车退出。

### 调试模式

在 `drivers/config.json` 中设置 `"debugMode": true`，启动后会打印详细的跟踪日志。

### 输出说明

系统运行后会同时产生两类输出：

- **JSON 文件落盘**：每秒合并一次四方向识别结果，写入 `json_out_pipei_*` 目录。
- **Redis Stream 写入**：实时推送识别快照至 Redis，供下游系统消费。

---

## Redis Data Format

识别结果写入两个 Redis key：

- **快照**：`recognition_{camera_id}_snap`
- **流**：`recognition_{camera_id}`

合并后的四方向快照格式（`origin_info_state:{intersection_id}`）：

```json
{
  "code": "HHL_QHDD",
  "name": "弘化路",
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
| `timestamp` | 帧时间戳（秒，由 OCR 从视频帧提取） |
| `id` | 经雷达匹配后的目标 ID |
| `orig_id` | 视觉跟踪原始 ID（匹配前） |
| `center` | 世界坐标 `[x, y]`（米） |
| `speed` | 速度分量 `[vx, vy]`（m/s） |
| `type` | 车辆类型（如有） |
| `licenseNum` | 车牌号（如有） |

---

## Performance

> 评测口径：历史全量速度 JSONL 对比原始雷达 JSONL。

### 字段误差对比

| 字段 | Mean | Median (p50) | p75 | p90 | 说明 |
|---|---|---|---|---|---|
| `timestamp_ms` 误差 (ms) | 25.04 | 26 | 37 | 46 | 视频帧与最近雷达帧的时间差 |
| `vehicles[].center` 误差 (m) | 2.5132 | 1.6251 | 3.1987 | 6.7021 | 匹配目标的空间位置误差 |
| `vehicles[].speed_scalar` 误差 (m/s) | 1.6727 | 0.3176 | 1.7741 | 5.0061 | 匹配目标的速度标量误差 |

### 字段一致率

| 字段 | 对比方式 | 一致率 |
|---|---|---|
| `intersection_id` | 精确一致率 | **100%** |
| `camera_id` | 精确一致率 | **100%** |
| `coordinate_space` | 精确一致率 | **100%** |
| `timestamp_ms` | 200ms 内对齐率 | **100%** |
| `vehicles[].lane` | 与雷达精确一致率 | **100%** |

---

## Citation

如果 TIR 对你的研究有帮助，请引用：

```bibtex
@article{tir2026,
  title   = {TIR: Real-Time Traffic Situation Awareness for Urban Intersections},
  author  = {OpenTraffic Team},
  journal = {arXiv preprint},
  year    = {2026}
}
```

---

## License

本项目基于 [Apache License 2.0](LICENSE) 开源。

```
Copyright 2026 OpenTraffic Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
```

---

<div align="center">
  <b>OpenTraffic Team</b> | Making urban traffic smarter.
</div>
