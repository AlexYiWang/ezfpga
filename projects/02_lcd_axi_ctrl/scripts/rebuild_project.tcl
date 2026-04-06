# rebuild_project.tcl - 一键恢复 Vivado 工程
# 在 Vivado Tcl Console 中执行: source scripts/rebuild_project.tcl

# 加载通用工具库
set utils_path [file normalize [file dirname [info script]]/../../../scripts/vivado_utils.tcl]
if {[file exists ${utils_path}]} {
    source ${utils_path}
} else {
    puts "ERROR: vivado_utils.tcl not found at ${utils_path}"
    return
}

# 项目配置
set project_name      "lcd_axi_ctrl"
set project_dir       [pwd]  ;# 当前目录 (projects/02_lcd_axi_ctrl/)
set part             "xc7a100tcsg324-1"
set board            "digilentinc.com:arty-a7-100:part0:1.0"
set top_module       "top_v2_axi"

# 源文件目录列表 (相对路径)
set src_dirs {
    ./rtl
    ../../modules/display/spi_tft_lcd/rtl
    ../../modules/display/lcd_controller/rtl
    ../../modules/display/font_engine/rtl
    ../../modules/bus/axi_lite/rtl
    ../../modules/common/fifo/rtl
    ../../modules/common/uart/rtl
}

# 约束文件目录
set constr_dirs {
    ./constrs
}

# 执行重建
rebuild_project \
    ${project_name} \
    ${project_dir} \
    ${part} \
    ${board} \
    ${top_module} \
    ${src_dirs} \
    ${constr_dirs}

# 可选: 自动运行综合
# launch_runs synth_1 -jobs 4
# wait_on_run synth_1