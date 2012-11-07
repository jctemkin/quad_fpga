
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name quad_fpga -dir "/home/jenn/git/quad_fpga/planAhead_run_3" -part xc6slx25ftg256-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/jenn/git/quad_fpga/toplevel.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/jenn/git/quad_fpga} {ipcore_dir} }
add_files "ipcore_dir/fifo.ncf" -fileset [get_property constrset [current_run]]
set_param project.pinAheadLayout  yes
set_param project.paUcfFile  "toplevel.ucf"
add_files "toplevel.ucf" -fileset [get_property constrset [current_run]]
open_netlist_design
