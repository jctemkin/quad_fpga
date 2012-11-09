
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name quad_fpga -dir "/home/jenn/quad/quad_fpga/planAhead_run_3" -part xc6slx25ftg256-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property top toplevel $srcset
set_param project.paUcfFile  "toplevel.ucf"
set hdlfile [add_files [list {ipcore_dir/fifo.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {spi_slave.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {reg_file.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {pcm_gen.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {mem_spi.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/clk_100mhz/example_design/clk_100mhz_exdes.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/clk_100mhz.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {toplevel.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
add_files "toplevel.ucf" -fileset [get_property constrset [current_run]]
add_files "ipcore_dir/fifo.ncf" -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx25ftg256-3
