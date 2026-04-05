# 🖥️ SPI TFT 屏幕驱动模块 (ST7789)

这是一个基于 FPGA 的 SPI 协议屏幕驱动模块，专为驱动搭载 **ST7789** 主控芯片的 TFT LCD (IPS) 屏幕而设计。

它采用了模块化的架构，将底层 SPI 时序、ST7789 的专属初始化序列与上层显示逻辑分离。由于 ST7789 是一款非常经典的显示驱动 IC（常见于 1.14寸、1.3寸、1.54寸、2.0寸等全彩 IPS 屏幕），本模块的底层时序也具备极高的通用性。

> **📚 参考与致谢**
> 本模块的架构设计与文档说明，部分参考了立创·梁山派 FPGA 团队的优秀开源教程：
> [立创·梁山派 FPGA 开发板 - SPI OLED 模块实验](https://wiki.lckfb.com/zh-hans/fpga-ljpi-z1/module/display/spi-oled.html#_4%E3%80%81%E5%AE%9E%E9%AA%8C%E7%8E%B0%E8%B1%A1)

---

## 🔌 1. 硬件接线指南 (Pinout & Connection)

在使用本模块前，请确保您的 FPGA 开发板与 ST7789 屏幕模块正确连接。绝大多数 ST7789 屏幕模块使用 3.3V 逻辑电平。

| 屏幕模块引脚 (ST7789) | FPGA 信号名 (RTL Port) | 信号类型 | 功能描述 (Description) |
| :--- | :--- | :--- | :--- |
| **GND** | - | 电源 | 系统地 |
| **VCC** | - | 电源 | 3.3V 供电 |
| **SCL/CLK** | `spi_sclk` | Output | SPI 时钟信号 |
| **SDA/MOSI/DIN** | `spi_mosi` | Output | SPI 主机输出从机输入数据线 |
| **RES/RST** | `spi_rst_n` | Output | 屏幕硬件复位引脚（低电平有效） |
| **DC/RS** | `lcd_dc` | Output | 数据/命令选择 (0: 命令 Command, 1: 数据 Data) |
| **CS** | `spi_cs` | Output | SPI 片选信号（低电平有效，部分没有 CS 引脚的模块内部已默认接地） |
| **BLK** | - | Output | 屏幕背光控制（可选，接 3.3V 高电平默认常亮） |

---

## 🏗️ 2. 代码组织结构 (RTL Architecture)

为了实现高内聚低耦合，本驱动采用了分层架构，核心代码均存放在 `rtl/` 目录下：

* **`spi_screen_top.sv` (顶层模块)**
  负责整合底层驱动和初始化控制，暴露最简单的接口给外部的显示逻辑。
* **`spi_master_driver.sv` (底层 SPI 主机)**
  核心的 SPI 时序发生器。负责将并行的 8-bit 数据按照 SPI 协议（通常为 CPOL=0, CPHA=0 模式）串行发送出去，并控制 `CS` 和 `SCLK`。
* **`spi_tft_screen_init.sv` (ST7789 初始化状态机)**
  **核心文件。** 内部存储了针对 **ST7789 芯片**的专属初始化命令和参数序列（如退出睡眠模式、色彩格式设置、显示方向配置等）。上电后自动依次下发，唤醒屏幕。
* **`spi_tft_screen_flush.sv` (刷屏/显存控制)**
  用于向 ST7789 连续发送 RGB 色彩数据，执行设定显示窗口（Column/Row Address Set）、清屏、刷纯色或显示图片的操作。

---

## 🚀 3. 如何使用 (Usage)

在你的顶层工程中，只需要例化 `spi_screen_top` 模块，并接入系统时钟与复位信号即可。

```verilog
// 顶层例化示例
spi_screen_top u_spi_screen_top (
    .sys_clk      (sys_clk),       // 系统时钟 (如 50MHz)
    .sys_rst_n    (sys_rst_n),     // 系统复位 (低电平有效)

    // ST7789 屏幕物理接口
    .spi_cs       (spi_cs),
    .spi_sclk     (spi_sclk),
    .spi_mosi     (spi_mosi),
    .lcd_dc       (lcd_dc),
    .spi_rst_n    (screen_rst_n) 
);