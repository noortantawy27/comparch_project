vsim -gui work.processor
add wave -position insertpoint  \
sim:/processor/reset \
sim:/processor/clk \
sim:/processor/rst_if_id \
sim:/processor/rst_id_ex \
sim:/processor/rst_ex_mem \
sim:/processor/rst_mem_wb \
sim:/processor/enable_if_id \
sim:/processor/enable_id_ex \
sim:/processor/enable_ex_mem \
sim:/processor/enable_mem_wb \
sim:/processor/instruction_if_id_in \
sim:/processor/pc_if_id_in \
sim:/processor/instruction_if_id_out \
sim:/processor/readdata1_id_ex_in \
sim:/processor/readdata2_id_ex_in \
sim:/processor/readdata1_id_ex_out \
sim:/processor/readdata2_id_ex_out \
sim:/processor/alu_ex_mem_out
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/memory/memory
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/pc_component/d \
sim:/processor/FetchMem_comp/pc_component/q
add wave -position insertpoint  \
sim:/processor/decode_comp/regfile/q_regs
add wave -position insertpoint  \
sim:/processor/alu_mem_wb_out
add wave -position insertpoint  \
sim:/processor/writeaddress1_mem_wb_out
add wave -position insertpoint  \
sim:/processor/mem_rb_writeaddress1
add wave -position insertpoint  \
sim:/processor/mem_rb_writedata1
add wave -position insertpoint  \
sim:/processor/mem_rb_regwrite1
add wave -position insertpoint  \
sim:/processor/mem_rb_regwrite2
add wave -position insertpoint  \
sim:/processor/decode_comp/regfile/writeaddress1 \
sim:/processor/decode_comp/regfile/wenable1 \
sim:/processor/decode_comp/regfile/writeport1
add wave -position insertpoint  \
sim:/processor/immediate_id_ex_in
force -freeze sim:/processor/reset 1 0
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/processor/reset 0 0
force -freeze sim:/processor/rst_if_id 0 0
force -freeze sim:/processor/rst_id_ex 0 0
force -freeze sim:/processor/rst_ex_mem 0 0
force -freeze sim:/processor/rst_mem_wb 0 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(4) b\"10111010000000000000000000011000" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(5) b\"10111011000000000000000000001100" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(6) b\"10111001000000000000000000000100" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(7) b\"10111100000000000000000000010000" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(8) b\"10111101000000000000000000001100" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(9) b\"01111011011010000000000000000000" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(10) b\"01001110001010000000000000000000" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(11) b\"01110000001010000000000000000000" 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run

