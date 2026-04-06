# EZFPGA 🚀

[English](./README.md) | [中文](./README_zh.md)

Welcome to **EZFPGA**!

The goal of this repository is simple: to make FPGA development **easy, fun, and accessible**.

Whether you are hacking on a new development board, trying to light up a display, reading sensor data, or just looking for inspiration for your next hardware build, you will find useful and ready-to-use "bricks" here.

**EZFPGA** is an open-source FPGA peripheral driver library tailored for Xilinx Artix-7 (XC7A100T). With standardized bus architecture and modular design, it aims to simplify FPGA hardware development workflow.

## 🚀 Core Features
- **SPI LCD Driver**: Complete SPI TFT LCD display driver supporting multiple screen sizes
- **Atomic Driver Library**: Driver code is decoupled from application logic, highly reusable
- **Automated Build**: Supports Tcl scripts to rebuild Vivado projects, eliminating tedious GUI configuration
- **Modular Design**: Each module is independent, testable, and integrable

## 🏗️ Project Structure

```
EZFPGA/
├── .github/                # GitHub Actions CI scripts
├── docs/                   # Documentation
├── modules/                # Atomic driver library (highly reusable RTL source)
│   ├── bus/                # Bus and interface conversion modules
│   │   └── axi_lite/       # AXI4-Lite Slave universal controller interface
│   ├── display/            # Display processing modules
│   │   ├── spi_tft_lcd/    # Low-level SPI driver state machine
│   │   ├── lcd_controller/ # Controller with request/response handshake
│   │   └── font_engine/    # Character rendering engine & ASCII font ROM
│   ├── sensor/             # Sensor driver modules
│   │   ├── imu_mpu6050/    # Gyroscope I2C driver
│   │   ├── bluetooth_hc05/ # Bluetooth UART transparent transmission
│   │   └── temp/           # Temperature sensor driver
│   ├── motor/              # Motor control module
│   └── common/             # Common basic components
│       ├── fifo/           # Synchronous/asynchronous FIFO wrapper
│       └── uart/           # Standard UART debugging module
├── projects/               # Debugging case studies (independent project snapshots)
│   ├── 01_lcd_basic_test/ # Case 1: Basic 9-grid display verification
│   ├── 02_uart_loopback/  # Case 2: UART loopback test
│   ├── 03_imu_weather_st/ # Case 3: Desktop weather/level (planned)
│   └── desktop_weather_station/ # Desktop weather station project
├── tools/                  # Auxiliary development tools
├── scripts/                 # Global auxiliary scripts
├── .gitignore              # Ignore Vivado logs and temporary files
├── LICENSE                 # License (MIT)
└── README.md               # Project portal
```

Each module contains:
- `rtl/` – RTL source files (Verilog/SystemVerilog)
- `tb/`  – Testbench files for simulation
- `README.md` – Module-specific documentation

## 📂 Directory Navigation
- `/modules`: Stores verified generic RTL drivers
- `/projects`: Stores specific debugging cases and top-level integration code
- `/scripts`: Stores automation scripts for restoring project environments

## 🛠️ Development Environment
- **FPGA Chip**: Artix-7 XC7A100T
- **IDE**: Vivado 2018.3 or higher
- **Development Mode**: Local project + repository source file reference (soft-link mode)

## 📦 Available Modules

### 🖥️ Display Modules
| Module | Location | Status |
|--------|----------|--------|
| SPI TFT LCD Driver | `modules/display/spi_tft_lcd/` | ✅ Available |
| LCD Controller | `modules/display/lcd_controller/` | 🔄 In Development |
| Font Engine | `modules/display/font_engine/` | 🔄 In Development |

### 🌉 Bus & Interface Modules
| Module | Location | Status |
|--------|----------|--------|
| AXI4-Lite Slave | `modules/bus/axi_lite/` | 🔄 In Development |

### 🌡️ Sensor Modules
| Module | Location | Status |
|--------|----------|--------|
| MPU6050 IMU | `modules/sensor/imu_mpu6050/` | 🔄 In Development |
| HC-05 Bluetooth | `modules/sensor/bluetooth_hc05/` | 🔄 In Development |
| Temperature Sensor | `modules/sensor/temp/` | 🔄 In Development |

### 🧩 Common Modules
| Module | Location | Status |
|--------|----------|--------|
| FIFO Wrapper | `modules/common/fifo/` | 🔄 In Development |
| UART Module | `modules/common/uart/` | ✅ Available |

### 🚀 Motor Modules
| Module | Location | Status |
|--------|----------|--------|
| Motor Control | `modules/motor/` | 🔄 In Development |

## 📂 Case Projects

| Case | Description | Status |
|------|-------------|--------|
| 01_lcd_basic_test | Basic 9-grid display verification | ✅ Completed |
| 02_uart_loopback | UART loopback test | ✅ Completed |
| 03_imu_weather_st | Desktop weather/level instrument | 📋 Planned |
| desktop_weather_station | Desktop weather station full project | 🔄 In Development |

## 🛠️ Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/AlexYiWang/ezfpga.git
   cd ezfpga
   ```

2. **Explore a module**
   Navigate to the module directory, e.g. `modules/common/uart/`, and check the `rtl/` folder for ready-to-use HDL code.

3. **Use in your project**
   Copy the RTL files into your own FPGA project and instantiate the modules as needed.

4. **Run simulation** (if testbenches are available)
   Use your preferred simulator (ModelSim, Vivado Simulator, etc.) with the testbench files in the `tb/` folder.

5. **Rebuild Vivado project** (for case studies)
   Navigate to a specific case study folder under `projects/`, and in Vivado Tcl Console execute `source scripts/rebuild_project.tcl` to automatically restore the complete project environment.

## 📝 Contribution Guidelines

We welcome contributions! If you have a new module or improvement:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-module`)
3. Add your module under the appropriate `modules/` category
4. Include:
   - RTL files in `rtl/`
   - Testbench in `tb/`
   - A `README.md` describing the module
   - `.gitkeep` files to preserve directory structure
5. Commit your changes (`git commit -m "Add your module"`)
6. Push to your fork and open a Pull Request

## 📱 Connect with Me

I frequently share my hardware explorations, project showcases, and dev logs. You can follow my latest updates here:

* 📕 **rednote (小红书):** [Check out my posts & videos](https://xhslink.com/m/3w9oPTvwvrf)
* 💻 **CSDN:** [Read my technical blogs](https://blog.csdn.net/Alex497259)
* 📧 **Email:** [icwangyi@qq.com](mailto:icwangyi@qq.com)

---

*Feel free to explore, fork, and star this repository if you find it helpful!*

---

📖 **中文文档**: [README_zh.md](README_zh.md) - View the project description in Chinese.
