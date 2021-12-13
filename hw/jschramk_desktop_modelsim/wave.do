onerror {resume}
radix define fixed#5#decimal -fixed -fraction 5 -base signed -precision 6
radix define fixed#5#decimal#signed -fixed -fraction 5 -signed -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {clk & rst_n}
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/clk
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/rst_n
add wave -noupdate -radix unsigned /AudioProcessor_tb/cycle_cnt
add wave -noupdate -divider control
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/start
add wave -noupdate -divider -height 34 INPUTS
add wave -noupdate -divider {data in}
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/data_wr_en
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/input_index
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/data_in
add wave -noupdate -divider {pitch shift}
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/pitch_shift_wr_en
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/pitch_shift_semitones
add wave -noupdate -divider {frequency coefficients}
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/freq_coeff_wr_en
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/freq_coeff_index
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/freq_coeff_in
add wave -noupdate -divider {data out}
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/output_index
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/data_out
add wave -noupdate -divider -height 34 INTERNAL
add wave -noupdate -divider states
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/state
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/next_state
add wave -noupdate -divider control
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/fft_sync
add wave -noupdate -format Analog-Step -height 74 -max 999.0 -min -999.0 -radix decimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/fft_sample_in
add wave -noupdate -format Analog-Step -height 74 -max 65035.999999999993 -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/fft_output_full
add wave -noupdate -format Analog-Step -height 74 -max 65035.999999999993 -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/pitch_shift_output_full
add wave -noupdate -format Analog-Step -height 74 -max 65035.999999999993 -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/equalizer_output_full
add wave -noupdate -radix unsigned -radixshowbase 1 /AudioProcessor_tb/dj_disco/sample_counter
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/fft_enable
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/pitch_shift_enable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49656 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 318
configure wave -valuecolwidth 140
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
WaveRestoreZoom {0 ps} {105730 ps}
