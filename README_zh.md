# EZFPGA 🚀

[English](./README.md) | [中文](./README_zh.md)

欢迎来到 **EZFPGA**！

本仓库的目标很简单：让 FPGA 开发变得**简单、有趣、易上手**。

无论您是在尝试新的开发板，点亮显示屏，读取传感器数据，还是为下一个硬件项目寻找灵感，这里都有有用的、开箱即用的"积木"模块。

**EZFPGA** 是一个为 Xilinx Artix-7 (XC7A100T) 量身定制的开源 FPGA 外设驱动库。采用标准化总线架构与模块化设计，旨在简化 FPGA 硬件开发流程。

## 🚀 项目核心特性
- **SPI LCD 驱动**：完整的 SPI TFT LCD 显示驱动，支持多种屏幕尺寸
- **原子化驱动库**：驱动代码与应用逻辑解耦，高度可复用
- **自动化构建**：支持 Tcl 脚本重建 Vivado 工程，告别繁琐的图形界面配置
- **模块化设计**：各模块独立，可单独测试和集成

## 🏗️ 项目结构

```
EZFPGA/
├── .github/                # GitHub Actions CI 脚本
├── docs/                   # 仓库全局文档
├── modules/                # 核心原子驱动库（高复用性 RTL 源码）
│   ├── bus/                # 总线与接口转换模块
│   │   └── axi_lite/       # AXI4-Lite Slave 通用控制器接口
│   ├── display/            # 显示处理模块
│   │   ├── spi_tft_lcd/    # 底层 SPI 发送状态机
│   │   ├── lcd_controller/ # 带有请求/响应握手机制的控制器
│   │   └── font_engine/    # 字符渲染引擎与 ASCII 字库 ROM
│   ├── sensor/             # 传感器驱动模块
│   │   ├── imu_mpu6050/    # 陀螺仪 I2C 驱动
│   │   ├── bluetooth_hc05/ # 蓝牙 UART 透明传输模块
│   │   └── temp/           # 温度传感器驱动
│   ├── motor/              # 电机控制模块
│   └── common/             # 通用基础组件
│       ├── fifo/           # 同步/异步 FIFO 封装
│       └── uart/           # 标准串口调试模块
├── projects/               # 联合调试案例（具体的独立工程快照）
│   ├── 01_lcd_basic_test/ # 案例1：基础九宫格显示验证
│   ├── 02_uart_loopback/  # 案例2：UART 回环测试
│   ├── 03_imu_weather_st/ # 案例3：桌面天气站/动态水平仪（规划中）
│   └── desktop_weather_station/ # 桌面天气站完整工程
├── tools/                  # 辅助开发工具
├── scripts/                # 全局辅助脚本
├── .gitignore             # 忽略 Vivado 产生的日志及编译临时文件
├── LICENSE                # 许可证 (MIT)
└── README.md              # 项目门户
```

每个模块包含：
- `rtl/` – RTL 源文件 (Verilog/SystemVerilog)
- `tb/`  – 测试平台文件（用于仿真）
- `README.md` – 模块特定文档

## 📂 目录导航
- `/modules`: 存放经过验证的通用 RTL 驱动
- `/projects`: 存放具体的调试案例及顶层粘合代码
- `/scripts`: 存放用于恢复工程环境的自动化脚本

## 🛠️ 开发环境
- **FPGA 芯片**: Artix-7 XC7A100T
- **IDE**: Vivado 2018.3 或更高版本
- **开发模式**: 本地工程 + 仓库源文件引用（软链接模式）

## 📦 可用模块

### 🖥️ 显示模块
| 模块 | 位置 | 状态 |
|------|------|------|
| SPI TFT LCD 驱动 | `modules/display/spi_tft_lcd/` | ✅ 可用 |
| LCD 控制器 | `modules/display/lcd_controller/` | 🔄 开发中 |
| 字体引擎 | `modules/display/font_engine/` | 🔄 开发中 |

### 🌉 总线与接口模块
| 模块 | 位置 | 状态 |
|------|------|------|
| AXI4-Lite 从机接口 | `modules/bus/axi_lite/` | 🔄 开发中 |

### 🌡️ 传感器模块
| 模块 | 位置 | 状态 |
|------|------|------|
| MPU6050 陀螺仪 | `modules/sensor/imu_mpu6050/` | 🔄 开发中 |
| HC-05 蓝牙模块 | `modules/sensor/bluetooth_hc05/` | 🔄 开发中 |
| 温度传感器 | `modules/sensor/temp/` | 🔄 开发中 |

### 🧩 通用模块
| 模块 | 位置 | 状态 |
|------|------|------|
| FIFO 封装 | `modules/common/fifo/` | 🔄 开发中 |
| UART 模块 | `modules/common/uart/` | ✅ 可用 |

### 🚀 电机模块
| 模块 | 位置 | 状态 |
|------|------|------|
| 电机控制 | `modules/motor/` | 🔄 开发中 |

## 📂 案例项目

| 案例 | 描述 | 状态 |
|------|------|------|
| 01_lcd_basic_test | 基础九宫格显示验证 | ✅ 完成 |
| 02_uart_loopback | UART 回环测试 | ✅ 完成 |
| 03_imu_weather_st | 桌面天气站/水平仪 | 📋 规划中 |
| desktop_weather_station | 桌面天气站完整工程 | 🔄 开发中 |

## 🛠️ 快速开始

1. **克隆仓库**
   ```bash
   git clone https://github.com/AlexYiWang/ezfpga.git
   cd ezfpga
   ```

2. **探索模块**
   导航到模块目录，例如 `modules/common/uart/`，检查 `rtl/` 文件夹中的 HDL 代码。

3. **在项目中使用**
   将 RTL 文件复制到您的 FPGA 项目中，并按需实例化模块。

4. **运行仿真**（如果测试平台可用）
   使用您喜欢的仿真器（ModelSim、Vivado Simulator 等）配合 `tb/` 文件夹中的测试平台文件。

5. **重建 Vivado 工程**（针对案例研究）
   导航到 `projects/` 下的特定案例文件夹，在 Vivado Tcl Console 中执行 `source scripts/rebuild_project.tcl` 即可自动恢复完整的工程环境。

## 📝 贡献指南

我们欢迎贡献！如果您有新的模块或改进：

1. Fork 本仓库
2. 创建新分支 (`git checkout -b feature/your-module`)
3. 在适当的 `modules/` 类别下添加您的模块
4. 包括：
   - `rtl/` 中的 RTL 文件
   - `tb/` 中的测试平台
   - 描述模块的 `README.md`
   - `.gitkeep` 文件以保持目录结构
5. 提交更改 (`git commit -m "添加您的模块"`)
6. 推送到您的 fork 并打开 Pull Request

## 📱 联系我

我经常分享硬件探索、项目展示和开发日志。您可以通过以下方式关注我的最新动态：

* 📕 **小红书:** [查看我的帖子与视频](https://xhslink.com/m/3w9oPTvwvrf)
* 💻 **CSDN:** [阅读我的技术博客](https://blog.csdn.net/Alex497259)
* 📧 **邮箱:** [icwangyi@qq.com](mailto:icwangyi@qq.com)

---

*如果您觉得这个仓库有用，请随意探索、fork 和 star！*

---

📖 **English Documentation**: [README.md](README.md) - View the project description in English.
