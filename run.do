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
sim:/processor/excute_comp/exmem_decsp \
sim:/processor/excute_comp/exmem_sp \
sim:/processor/excute_comp/inc_sp_q \
sim:/processor/excute_comp/inc_sp_q \
sim:/processor/excute_comp/sp_inst/q \
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
sim:/processor/decode_comp/regfile/q_regs \
sim:/processor/excute_comp/ccr_store/C_reg \
sim:/processor/excute_comp/ccr_store/flag_enable \
sim:/processor/excute_comp/ccr_store/N_reg \
sim:/processor/excute_comp/ccr_store/Z_reg \
sim:/processor/excute_comp/ccr_restore_q  \
sim:/processor/excute_comp/input_z_ccr \
sim:/processor/excute_comp/ccr_main/C_reg \
sim:/processor/excute_comp/ccr_main/flag_enable \
sim:/processor/excute_comp/ccr_main/N_reg \
sim:/processor/excute_comp/ccr_main/Z_reg
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
add wave -position insertpoint  \
sim:/processor/excute_comp/branch_q
add wave -position insertpoint  \
sim:/processor/excute_comp/branch_type_q
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/pc_plus_immediate \
sim:/processor/FetchMem_comp/do_branch
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/mem_address
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/writedata
add wave -position insertpoint  \
sim:/processor/excute_comp/alu_a \
sim:/processor/excute_comp/alu_b
add wave -position insertpoint  \
sim:/processor/excute_comp/alu_result
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/alu_q
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/sp_or_alu
add wave -position insertpoint  \
sim:/processor/FetchMem_comp/offset
add wave -position insertpoint  \
sim:/processor/decode_comp/mem_rb_regwrite1 \
sim:/processor/decode_comp/mem_rb_regwrite2 \
sim:/processor/decode_comp/mem_rb_writeaddress1 \
sim:/processor/decode_comp/mem_rb_writeaddress2 \
sim:/processor/decode_comp/mem_rb_writedata1 \
sim:/processor/decode_comp/mem_rb_writedata2
add wave -position insertpoint  \
sim:/processor/write_back_comp/readData1_out \
sim:/processor/write_back_comp/regWrite1_out \
sim:/processor/write_back_comp/regWrite2_out \
sim:/processor/write_back_comp/writeBack_out
add wave -position insertpoint  \
sim:/processor/write_back_comp/readData1_in \
sim:/processor/write_back_comp/readData2_in \
sim:/processor/FetchMem_comp/readdata \
sim:/processor/FetchMem_comp/mem_address \
sim:/processor/FetchMem_comp/memread_q \
sim:/processor/FetchMem_comp/pc_src_q \
sim:/processor/FetchMem_comp/pc_component/enable \
sim:/processor/FetchMem_comp/pc_component_d \
sim:/processor/FetchMem_comp/pc_component/q \
sim:/processor/FetchMem_comp/pc_component/d \
sim:/processor/write_back_comp/writeAddress1_in \
sim:/processor/write_back_comp/writeAddress2_in 
force -freeze sim:/processor/reset 1 0
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/processor/reset 0 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(4) b\"00111011011000000000000000000000" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(5) b\"10111001000000000000000000010000" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(6) b\"01100010001000000000000000000100" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(7) b\"01000010001010000000000000000000" 0
force -freeze sim:/processor/FetchMem_comp/memory/memory(8) b\"01100001001000000000000000001000" 0
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
