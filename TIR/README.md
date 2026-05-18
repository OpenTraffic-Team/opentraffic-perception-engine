
# tir-0513-git-so

`.so` 交付版本。  


## 目录说明

当前目录已经自包含运行所需资源：

- 输入视频：`input/45_0429.mp4`
- 雷达参考：`reference_radar/HHL_QHDD_S/HHL_QHDD_S_shard_00000.jsonl`
- Python 环境：`.venv`
- 启动脚本：`run_local.sh`
- 停止脚本：`stop_local.sh`

## 如何运行 `.so` 版本

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

## 输出结果

默认输出目录：

```text
control_group_fullspeed_jsonl/HHL_QHDD_S/HHL_QHDD_S_shard_00000.jsonl
```

输出字段：

- `timestamp_ms`
- `intersection_id`
- `camera_id`
- `source`
- `coordinate_space`
- `vehicles[].id`
- `vehicles[].center`
- `vehicles[].speed`
- `vehicles[].speed_scalar`
- `vehicles[].lane`
- `vehicles[].type`

### 字段准确率对比表

说明：

 下表口径基于历史全量速度 `JSONL` 对比原始雷达 `JSONL`
| 字段 / 指标 | mean | median / p50 | p75 | p90 | 说明 |
|---|---:|---:|---:|---:|---|
| `timestamp_ms` 误差（ms） | `25.04` | `26.5 / 26` | `37` | `46` | 视频帧与最近雷达帧的时间差 |
| `vehicles[].center` 误差（m） | `2.5132` | `1.6251 / 1.6251` | `3.1987` | `6.7021` | 匹配目标的空间位置误差 |
| `vehicles[].speed_scalar` 误差（m/s） | `1.6727` | `0.3176 / 0.3176` | `1.7741` | `5.0061` | 匹配目标的速度标量误差 |

### 字段一致率

### 字段一致率



| 字段 | 和雷达对比方式 | 一致率 / 结果 |
|---|---|---:|
| `intersection_id` | 精确一致率 | `100%` |
| `camera_id` | 精确一致率 | `100%` |
| `coordinate_space` | 精确一致率 | `100%` |
| `timestamp_ms` | 200ms 内对齐率 | `100%` |
| `vehicles[].lane` | 与雷达精确一致率 | `100%` |


=======
# opentraffic-perception-engine
感知模型层

