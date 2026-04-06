# 案例2: AXI 总线控制显示集成

## 实验目标
实现基于 AXI4-Lite 总线的 LCD 显示控制系统，验证总线接口与显示模块的集成。

## 硬件连接
| FPGA 引脚 | LCD 模块信号 | 说明 |
|-----------|--------------|------|
| 见约束文件 | 见约束文件 | 详细引脚映射在 `constrs/` 目录下 |

## 软件设计
- **顶层模块**: `top_v2_axi.v`
- **总线接口**: AXI4-Lite Slave
- **显示架构**: 双缓冲 BRAM 显存
- **控制方式**: 通过 AXI 总线写入显示数据和命令

## 文件说明
- `rtl/top_v2_axi.v` - 集成总线与显示的顶层逻辑
- `constrs/` - 约束文件
- `scripts/rebuild_project.tcl` - 一键恢复本地 Vivado 工程的 Tcl 脚本

## 一键恢复工程
在 Vivado Tcl Console 中执行：
```tcl
source scripts/rebuild_project.tcl
```
脚本将自动：
1. 创建/打开项目
2. 添加所有源文件（包括 modules/ 下的驱动库）
3. 添加约束文件
4. 设置顶层模块
5. 更新编译顺序

## AXI 寄存器映射
| 地址偏移 | 名称 | 读写 | 功能 |
|----------|------|------|------|
| 0x00 | CONTROL | R/W | 控制寄存器 |
| 0x04 | STATUS | R | 状态寄存器 |
| 0x08 | BUFFER_SEL | R/W | 双缓冲选择 |
| 0x0C | CURSOR_X | R/W | 光标 X 坐标 |
| 0x10 | CURSOR_Y | R/W | 光标 Y 坐标 |
| 0x14 | COLOR | R/W | 当前绘制颜色 |
| 0x8000 | FRAME_BUFFER | R/W | 显存起始地址 |

## 使用步骤
1. 执行 `rebuild_project.tcl` 恢复工程
2. 综合、实现、生成比特流
3. 下载到 FPGA 开发板
4. 通过 AXI 总线接口（如 MicroBlaze 或 Zynq PS）发送显示命令
5. 观察 LCD 屏幕显示

## 预期结果
- 系统正确响应 AXI 总线读写
- 能够通过总线写入像素数据到显存
- LCD 屏幕显示写入的图像内容
- 支持双缓冲切换，避免画面撕裂

## 调试笔记
- AXI 总线信号时序需符合协议规范
- 显存地址对齐到 4KB 边界
- 双缓冲切换时需等待当前帧完成