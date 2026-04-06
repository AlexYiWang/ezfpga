# EZFPGA 🚀

Welcome to **EZFPGA**! 

The goal of this repository is simple: to make FPGA development **easy, fun, and accessible**. 

Whether you are hacking on a new development board, trying to light up a display, reading sensor data, or just looking for inspiration for your next hardware build, you will find useful and ready-to-use "bricks" here.

**EZFPGA** is an open-source FPGA peripheral driver library tailored for Xilinx Artix-7 (XC7A100T). With standardized bus architecture and modular design, it aims to simplify FPGA hardware development workflow.

## 🚀 Core Features
- **AXI4-Lite Bus Support**: All core display modules support AXI standard bus, making it easy to integrate with soft-core SoC environments.
- **Atomic Driver Library**: Driver code is decoupled from application logic, highly reusable.
- **Automated Build**: Supports Tcl scripts to rebuild Vivado projects, eliminating tedious GUI configuration.
- **Double Buffering Display Architecture**: Utilizes Artix-7's rich BRAM resources for high-performance image refresh.

## 🏗️ Project Structure

The repository is organized into modular components and project examples:

```
EZFPGA/
├── .github/                # GitHub Actions CI scripts
├── docs/                   # Documentation (images, specifications)
├── modules/                # Atomic driver library (highly reusable RTL source)
│   ├── bus/                # Bus and interface conversion modules
│   │   └── axi_lite/       # AXI4-Lite Slave universal controller interface
│   ├── display/            # Display processing modules
│   │   ├── spi_tft_lcd/    # Low-level SPI driver state machine
│   │   ├── lcd_controller/ # Controller with request/response handshake
│   │   └── font_engine/    # Character rendering engine & ASCII font ROM
│   ├── sensor/             # Sensor driver modules
│   │   ├── imu_mpu6050/    # Gyroscope I2C driver
│   │   └── bluetooth_hc05/ # Bluetooth UART transparent transmission
│   └── common/             # Common basic components
│       ├── fifo/           # Synchronous/asynchronous FIFO wrapper
│       └── uart/           # Standard UART debugging module
├── projects/               # Debugging case studies (independent project snapshots)
│   ├── 01_lcd_basic_test/  # Case 1: Basic 9-grid display verification
│   ├── 02_lcd_axi_ctrl/    # Case 2: AXI bus control display integration
│   └── 03_imu_weather_st/  # Case 3: Future goal (desktop weather/level)
├── tools/                  # Auxiliary development tools
├── scripts/                # Global auxiliary scripts
├── .gitignore             # Ignore Vivado logs and temporary files
├── LICENSE                # License (MIT/Apache 2.0)
└── README.md              # Project portal
```

Each module contains:
- `rtl/` – RTL source files (Verilog/SystemVerilog)
- `tb/`  – Testbench files for simulation
- `README.md` – Module-specific documentation

## 📂 Directory Navigation
- `/modules`: Stores verified generic RTL drivers.
- `/projects`: Stores specific debugging cases and top-level integration code.
- `/scripts`: Stores automation scripts for restoring project environments.

## 🛠️ Development Environment
- **FPGA Chip**: Artix-7 XC7A100T
- **IDE**: Vivado 2018.3 or higher
- **Development Mode**: Local project + repository source file reference (soft-link mode)

## 📦 Available Modules

### 🖥️ Display Modules
- **SPI TFT LCD** – Driver for SPI-based TFT LCD screens
  - Location: `modules/display/spi_tft_lcd/`
  - Status: Under development
- **LCD Controller** – Controller with request/response handshake mechanism
  - Location: `modules/display/lcd_controller/`
  - Status: Planned
- **Font Engine** – Character rendering engine & ASCII font ROM
  - Location: `modules/display/font_engine/`
  - Status: Planned

### 🌉 Bus & Interface Modules
- **AXI4-Lite Slave** – Universal controller interface for AXI4-Lite bus
  - Location: `modules/bus/axi_lite/`
  - Status: Planned

### 🌡️ Sensor Modules
- **Temperature Sensor** – Interface for temperature sensors (e.g., DHT11)
  - Location: `modules/sensor/temp/`
  - Status: Planned
- **MPU6050 IMU** – Gyroscope and accelerometer I2C driver
  - Location: `modules/sensor/imu_mpu6050/`
  - Status: Planned
- **HC-05 Bluetooth** – Bluetooth UART transparent transmission module
  - Location: `modules/sensor/bluetooth_hc05/`
  - Status: Planned

### 🧩 Common Modules
- **FIFO Wrapper** – Synchronous/asynchronous FIFO implementation
  - Location: `modules/common/fifo/`
  - Status: Planned
- **UART Module** – Standard UART debugging module
  - Location: `modules/common/uart/`
  - Status: Planned

### 🚀 Motor Modules
- **Motor Control** – PWM and driver logic for DC/stepper motors
  - Location: `modules/motor/`
  - Status: Planned

## 🛠️ Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/AlexYiWang/ezfpga.git
   cd ezfpga
   ```

2. **Explore a module**
   Navigate to the module directory, e.g., `modules/display/spi_tft_lcd/`, and check the `rtl/` folder for ready‑to‑use HDL code.

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

*This project is continuously updated, with plans to introduce more cases like gyroscope dynamic level, Bluetooth wireless control, etc.*

---

📖 **中文文档**: [README_zh.md](README_zh.md) - 查看中文版本的项目说明。