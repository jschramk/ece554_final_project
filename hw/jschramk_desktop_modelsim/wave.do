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
add wave -noupdate -format Analog-Step -height 74 -max 20000.0 -min -20000.0 -radix decimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/fft_sample_in
add wave -noupdate -format Analog-Step -height 74 -max 1280000.0000000002 -min -3.0 -radix decimal -radixshowbase 1 /AudioProcessor_tb/fft_real
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix decimal /AudioProcessor_tb/fft_imag
add wave -noupdate -format Analog-Step -height 74 -max 17592200000000.0 -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/pitch_shift_output_full
add wave -noupdate -format Analog-Step -height 74 -max 17592200000000.0 -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/equalizer_output_full
add wave -noupdate -radix unsigned -radixshowbase 1 /AudioProcessor_tb/dj_disco/sample_counter
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/fft_enable
add wave -noupdate -radix hexadecimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/pitch_shift_enable
add wave -noupdate /AudioProcessor_tb/dj_disco/ifft_sync
add wave -noupdate -format Analog-Step -height 74 -max 21474836480000.004 -min -20344186315320.0 -radix decimal /AudioProcessor_tb/dj_disco/ifft_output_full
add wave -noupdate /AudioProcessor_tb/dj_disco/ifft_enable
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix decimal /AudioProcessor_tb/dj_disco/ifft/i_sample
add wave -noupdate /AudioProcessor_tb/dj_disco/ifft/o_result
add wave -noupdate /AudioProcessor_tb/dj_disco/ifft/o_sync
add wave -noupdate -format Analog-Step -height 74 -max 80000.0 -min -75788.0 -radix decimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/ifft_output_real
add wave -noupdate -format Analog-Step -height 74 -max 78938.0 -min -78938.0 -radix decimal -radixshowbase 1 /AudioProcessor_tb/dj_disco/ifft_output_imag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {114335 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 318
configure wave -valuecolwidth 236
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
WaveRestoreZoom {110968 ps} {119546 ps}
