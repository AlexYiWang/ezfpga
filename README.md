# ezfpga 🚀

Welcome to **ezfpga**! 

The goal of this repository is simple: to make FPGA development **easy, fun, and accessible**. 

Whether you are hacking on a new development board, trying to light up a display, reading sensor data, or just looking for inspiration for your next hardware build, you will find useful and ready-to-use "bricks" here.

## 🏗️ Project Structure

The repository is organized into modular components and project examples:

```
ezfpga/
├── LICENSE
├── README.md
├── modules/           # Reusable hardware modules
│   ├── display/       # Display drivers (SPI TFT LCD, etc.)
│   ├── sensor/        # Sensor interfaces (temperature, etc.)
│   └── motor/         # Motor control modules
└── projects/          # Complete project examples
    └── desktop_weather_station/  # Example project using multiple modules
```

Each module contains:
- `rtl/` – RTL source files (Verilog/SystemVerilog)
- `tb/`  – Testbench files for simulation
- `README.md` – Module-specific documentation

## 📦 Available Modules

### 🖥️ Display Modules
- **SPI TFT LCD** – Driver for SPI-based TFT LCD screens
  - Location: `modules/display/spi_tft_lcd/`
  - Status: Under development

### 🌡️ Sensor Modules
- **Temperature Sensor** – Interface for temperature sensors (e.g., DHT11)
  - Location: `modules/sensor/temp/`
  - Status: Under development

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