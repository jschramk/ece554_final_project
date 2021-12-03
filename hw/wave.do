onerror {resume}
radix define fixed#8#decimal#signed -fixed -fraction 8 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /Sinusoid_tb/SIN/in
add wave -noupdate -format Analog-Step -height 74 -max 256.0 -min -256.0 -radix fixed#8#decimal#signed /Sinusoid_tb/SIN/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14965 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 108
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
WaveRestoreZoom {0 ps} {21271 ps}
