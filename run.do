if {[file exists work]} {
    catch {vdel -lib work -all}
    file delete -force work
}

vlib work
vmap work work

vlog -sv -work work rtl/*.sv
vlog -sv -work work tb/*.sv

vsim -voptargs="+acc" work.tb_pn_generator
if {[file exists ./waves/wave.do]} {
    do ./waves/wave.do
} else {
    add wave -r /*
}