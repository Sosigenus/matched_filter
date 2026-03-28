onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 25 Parameters
add wave -noupdate -label SYS_CLH_MHZ /tb_matched_filter/SYS_CLK_MHZ
add wave -noupdate -label PERIOD /tb_matched_filter/PERIOD
add wave -noupdate -label AMOUNT_COEF /tb_matched_filter/AMOUNT_COEF
add wave -noupdate -label DATA_WIDTH /tb_matched_filter/DATA_WIDTH
add wave -noupdate -label COEF_WIDTH /tb_matched_filter/COEF_WIDTH
add wave -noupdate -label ACC_WIDTH /tb_matched_filter/ACC_WIDTH
add wave -noupdate -divider -height 25 tb_matched_filter
add wave -noupdate -label clk /tb_matched_filter/clk
add wave -noupdate -label rst_n /tb_matched_filter/rst_n
add wave -noupdate -label din /tb_matched_filter/din
add wave -noupdate -label valid /tb_matched_filter/din_valid
add wave -noupdate -label dout /tb_matched_filter/dout
add wave -noupdate -label dout_valid /tb_matched_filter/dout_valid
add wave -noupdate -label coef /tb_matched_filter/coef
add wave -noupdate -divider -height 25 inst_m_f
add wave -noupdate -label clk /tb_matched_filter/mtd_filter_inst/clk
add wave -noupdate -label rst_n /tb_matched_filter/mtd_filter_inst/rst_n
add wave -noupdate -label din /tb_matched_filter/mtd_filter_inst/din
add wave -noupdate -label din_translate -radix decimal /tb_matched_filter/mtd_filter_inst/din_translate
add wave -noupdate -label din_valid /tb_matched_filter/mtd_filter_inst/din_valid
add wave -noupdate -label dout /tb_matched_filter/mtd_filter_inst/dout
add wave -noupdate -format Analog-Interpolated -height 74 -label dout_analog -max 6.0 -min -6.0 -radix decimal /tb_matched_filter/dout
add wave -noupdate -label coef /tb_matched_filter/mtd_filter_inst/coef
add wave -noupdate -label delay /tb_matched_filter/mtd_filter_inst/delay
add wave -noupdate -label prod /tb_matched_filter/mtd_filter_inst/prod
add wave -noupdate -label valid_pipe /tb_matched_filter/mtd_filter_inst/valid_pipe
add wave -noupdate -label dout_valid /tb_matched_filter/mtd_filter_inst/dout_valid
add wave -noupdate -divider -height 25 gold_model
add wave -noupdate -label acc_gold -radix decimal /tb_matched_filter/acc
add wave -noupdate -format Analog-Interpolated -height 74 -label expected -max 6.0 -min -6.0 -radix decimal /tb_matched_filter/expected
add wave -noupdate -label gold -radix decimal /tb_matched_filter/gold
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {97099 ps} 0}
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
WaveRestoreZoom {0 ps} {1002527 ps}
