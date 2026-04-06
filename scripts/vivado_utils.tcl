# vivado_utils.tcl - 通用 Vivado Tcl 函数库
# 用于支持各项目的 rebuild 脚本

# 创建新项目（如果不存在）并设置基本属性
proc create_project_safe {project_name project_dir part board} {
    if {[file exists ${project_dir}/${project_name}.xpr]} {
        puts "Project already exists, opening..."
        open_project ${project_dir}/${project_name}.xpr
    } else {
        puts "Creating new project..."
        create_project ${project_name} ${project_dir} -part ${part}
        if {${board} != ""} {
            set_property board_part ${board} [current_project]
        }
        # 设置仿真语言为 Verilog
        set_property target_simulator "Vivado" [current_project]
        set_property -name {xsim.simulate.runtime} -value {1000ns} -objects [get_filesets sim_1]
    }
}

# 添加源文件目录（递归搜索 .v .sv .vhd）
proc add_source_dir {src_dir {file_type "verilogSource"}} {
    if {![file exists ${src_dir}]} {
        puts "Warning: Source directory ${src_dir} does not exist."
        return
    }
    set src_files [list]
    # 根据文件类型选择扩展名
    if {${file_type} == "verilogSource"} {
        set ext_pattern {\.(v|sv)$}
    } elseif {${file_type} == "vhdlSource"} {
        set ext_pattern {\.(vhd|vhdl)$}
    } else {
        set ext_pattern {\.(v|sv|vhd|vhdl)$}
    }
    # 递归查找
    foreach file [glob -nocomplain -directory ${src_dir} -type f *] {
        if {[regexp ${ext_pattern} ${file}]} {
            lappend src_files ${file}
        }
    }
    # 添加文件到项目
    if {[llength ${src_files}] > 0} {
        add_files -norecurse ${src_files}
        puts "Added [llength ${src_files}] files from ${src_dir}"
    } else {
        puts "No source files found in ${src_dir}"
    }
}

# 添加约束文件目录
proc add_constraint_dir {constr_dir} {
    if {![file exists ${constr_dir}]} {
        puts "Warning: Constraint directory ${constr_dir} does not exist."
        return
    }
    set xdc_files [glob -nocomplain -directory ${constr_dir} *.xdc]
    if {[llength ${xdc_files}] > 0} {
        add_files -fileset constrs_1 -norecurse ${xdc_files}
        puts "Added [llength ${xdc_files}] constraint files from ${constr_dir}"
    } else {
        puts "No constraint files found in ${constr_dir}"
    }
}

# 设置顶层模块
proc set_top_module {top_name} {
    set_property top ${top_name} [current_fileset]
    puts "Set top module to ${top_name}"
}

# 标准项目重建流程
proc rebuild_project {project_name project_dir part board top_module src_dirs constr_dirs} {
    create_project_safe ${project_name} ${project_dir} ${part} ${board}
    # 添加源文件目录
    foreach src_dir ${src_dirs} {
        add_source_dir ${src_dir}
    }
    # 添加约束文件目录
    foreach constr_dir ${constr_dirs} {
        add_constraint_dir ${constr_dir}
    }
    # 设置顶层模块
    set_top_module ${top_module}
    # 更新编译顺序
    update_compile_order -fileset sources_1
    puts "Project rebuild completed."
}

# 输出使用说明
proc print_usage {} {
    puts "========================================"
    puts "Vivado Utilities Tcl Library"
    puts "Usage in your rebuild script:"
    puts ""
    puts "source vivado_utils.tcl"
    puts ""
    puts "rebuild_project \\"
    puts "    project_name    \"my_project\" \\"
    puts "    project_dir     \".\" \\"
    puts "    part            \"xc7a100tcsg324-1\" \\"
    puts "    board           \"digilentinc.com:arty-a7-100:part0:1.0\" \\"
    puts "    top_module      \"top\" \\"
    puts "    src_dirs        {../rtl ../../modules/display} \\"
    puts "    constr_dirs     {../constrs}"
    puts "========================================"
}