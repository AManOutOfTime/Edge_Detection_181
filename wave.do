onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_edge_detect/dut/row
add wave -noupdate -radix unsigned /tb_edge_detect/dut/col
add wave -noupdate -radix unsigned /tb_edge_detect/row
add wave -noupdate -radix unsigned /tb_edge_detect/col
add wave -noupdate /tb_edge_detect/clk
add wave -noupdate /tb_edge_detect/rst
add wave -noupdate /tb_edge_detect/edge_en
add wave -noupdate -radix binary /tb_edge_detect/vga_rst
add wave -noupdate -radix unsigned /tb_edge_detect/cycles
add wave -noupdate -group XY -radix unsigned /tb_edge_detect/col
add wave -noupdate -group XY -radix unsigned /tb_edge_detect/row
add wave -noupdate -expand -group {INPUT RGB} -radix hexadecimal /tb_edge_detect/in_R
add wave -noupdate -expand -group {INPUT RGB} -radix hexadecimal /tb_edge_detect/in_G
add wave -noupdate -expand -group {INPUT RGB} -radix hexadecimal /tb_edge_detect/in_B
add wave -noupdate -group SYNC_FSM -radix unsigned /tb_edge_detect/dut/sync_state
add wave -noupdate -group SYNC_FSM -radix unsigned /tb_edge_detect/dut/next_sync_state
add wave -noupdate -group SYNC_FSM -radix unsigned /tb_edge_detect/dut/synced
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/conv_state
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/next_conv_state
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/curr_buff_wr_count
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/curr_row_to_disp
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/first_conv_done
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/init_curr_buff
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/buff_done
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/vga_rst_req
add wave -noupdate -expand -group CONV_STATE_FSM -radix unsigned /tb_edge_detect/dut/vga_synced
add wave -noupdate -expand -group {BUFFER ENABLE SIGNALS} /tb_edge_detect/dut/rst_buff
add wave -noupdate -expand -group {BUFFER ENABLE SIGNALS} /tb_edge_detect/dut/rd_buff_en
add wave -noupdate -expand -group {BUFFER ENABLE SIGNALS} /tb_edge_detect/dut/wr_buff_en
add wave -noupdate -expand -group {BUFFER ENABLE SIGNALS} /tb_edge_detect/dut/zero_fill_buff
add wave -noupdate -radix hexadecimal -childformat {{{/tb_edge_detect/dut/inter_grey[7]} -radix hexadecimal} {{/tb_edge_detect/dut/inter_grey[6]} -radix hexadecimal} {{/tb_edge_detect/dut/inter_grey[5]} -radix hexadecimal} {{/tb_edge_detect/dut/inter_grey[4]} -radix hexadecimal} {{/tb_edge_detect/dut/inter_grey[3]} -radix hexadecimal} {{/tb_edge_detect/dut/inter_grey[2]} -radix hexadecimal} {{/tb_edge_detect/dut/inter_grey[1]} -radix hexadecimal} {{/tb_edge_detect/dut/inter_grey[0]} -radix hexadecimal}} -subitemconfig {{/tb_edge_detect/dut/inter_grey[7]} {-height 15 -radix hexadecimal} {/tb_edge_detect/dut/inter_grey[6]} {-height 15 -radix hexadecimal} {/tb_edge_detect/dut/inter_grey[5]} {-height 15 -radix hexadecimal} {/tb_edge_detect/dut/inter_grey[4]} {-height 15 -radix hexadecimal} {/tb_edge_detect/dut/inter_grey[3]} {-height 15 -radix hexadecimal} {/tb_edge_detect/dut/inter_grey[2]} {-height 15 -radix hexadecimal} {/tb_edge_detect/dut/inter_grey[1]} {-height 15 -radix hexadecimal} {/tb_edge_detect/dut/inter_grey[0]} {-height 15 -radix hexadecimal}} /tb_edge_detect/dut/inter_grey
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff0_pixelA
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff1_pixelA
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff2_pixelA
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff3_pixelA
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff0_pixelB
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff1_pixelB
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff2_pixelB
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff3_pixelB
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff0_pixelC
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff1_pixelC
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff2_pixelC
add wave -noupdate -group BUFFER_OUTPUT -radix hexadecimal /tb_edge_detect/dut/buff3_pixelC
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel0
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel1
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel2
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel3
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel4
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel5
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel6
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel7
add wave -noupdate -group SOBEL_INPUT -radix hexadecimal /tb_edge_detect/dut/sobel_in_pixel8
add wave -noupdate -expand -group COUNT_FSM -radix unsigned /tb_edge_detect/dut/count_state
add wave -noupdate -expand -group COUNT_FSM -radix unsigned /tb_edge_detect/dut/next_count_state
add wave -noupdate -expand -group COUNT_FSM -radix unsigned /tb_edge_detect/dut/cycle_count
add wave -noupdate -expand -group COUNT_FSM -radix unsigned /tb_edge_detect/dut/cycle_output
add wave -noupdate -expand -group {Internal Output} -radix hexadecimal /tb_edge_detect/dut/done_edge_R
add wave -noupdate -expand -group {Internal Output} -radix hexadecimal /tb_edge_detect/dut/done_edge_G
add wave -noupdate -expand -group {Internal Output} -radix hexadecimal /tb_edge_detect/dut/done_edge_B
add wave -noupdate -expand -group {OUTPUT RGB} -radix hexadecimal /tb_edge_detect/done_edge_R
add wave -noupdate -expand -group {OUTPUT RGB} -radix hexadecimal /tb_edge_detect/done_edge_G
add wave -noupdate -expand -group {OUTPUT RGB} -radix hexadecimal /tb_edge_detect/done_edge_B
add wave -noupdate /tb_edge_detect/dut/hex
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {3084825012 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
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
WaveRestoreZoom {9215865293 ps} {9216028143 ps}
