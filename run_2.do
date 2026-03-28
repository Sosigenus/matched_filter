if {[file exists work]} {
    catch {vdel -lib work -all}
    file delete -force work
}

vlib work
vmap work work

vlog -sv -work work rtl/*.sv
vlog -sv -work work tb/*.sv

vsim -voptargs="+acc" work.tb_matched_filter
if {[file exists ./waves/wave_m_f.do]} {
    do ./waves/wave_m_f.do
} else {
    add wave -r /*
}