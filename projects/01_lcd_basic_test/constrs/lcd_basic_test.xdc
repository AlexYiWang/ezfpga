# =======================================================
# 第一部分：板载电源开关，系统时钟与复位
# =======================================================
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS15} [get_ports sys_clk]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS15} [get_ports sys_rst_n]

# =======================================================
# 第二部分：SPI 屏幕专用引脚定义
# =======================================================
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports lcd_spi_sclk]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports lcd_spi_mosi]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports lcd_spi_cs]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports lcd_dc]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports lcd_reset]
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVCMOS33} [get_ports lcd_blk]

#------------------------------------SPI-------------------------------------------
# SPI 时钟约束
create_clock -period 20.000 -name sys_clk [get_ports sys_clk]
