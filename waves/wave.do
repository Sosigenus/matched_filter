onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 25 Parameters
add wave -noupdate /tb_pn_generator/SYS_CLK_MHZ
add wave -noupdate /tb_pn_generator/OS
add wave -noupdate /tb_pn_generator/PERIOD
add wave -noupdate /tb_pn_generator/WIDTH_OS
add wave -noupdate -divider -height 25 tb_pn_gen
add wave -noupdate /tb_pn_generator/clk
add wave -noupdate /tb_pn_generator/rst_n
add wave -noupdate /tb_pn_generator/q
add wave -noupdate /tb_pn_generator/q_valid
add wave -noupdate -radix unsigned /tb_pn_generator/counter_q
add wave -noupdate /tb_pn_generator/over_sampling
add wave -noupdate -divider -height 25 inst_pn_gen
add wave -noupdate /tb_pn_generator/dut/clk
add wave -noupdate /tb_pn_generator/dut/rst_n
add wave -noupdate /tb_pn_generator/dut/q_valid
add wave -noupdate /tb_pn_generator/dut/q
add wave -noupdate /tb_pn_generator/dut/shift_register
add wave -noupdate /tb_pn_generator/dut/valid
add wave -noupdate /tb_pn_generator/dut/q_reg
add wave -noupdate -radix unsigned /tb_pn_generator/dut/over_sampling
add wave -noupdate /tb_pn_generator/dut/xor_sreg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {71318 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2024518 ps}
