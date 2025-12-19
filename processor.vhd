library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
port (
    input_port: in std_logic_vector(31 downto 0);
    reset, interrupt, clk_input: in std_logic;
    output_port: out std_logic_vector(31 downto 0);
    clk_enable: out std_logic
);
end entity processor;

architecture behaviour of processor is
component fetch_mem is 
port (
--fetch section
-- input to processor
input_port : in std_logic_vector(31 downto 0);
clk, reset, interrupt: in std_logic;
-- input from excute section
pc_plus_immediate : in std_logic_vector(31 downto 0);
do_branch: in std_logic;
-- input from hazard detection
pc_enable: in std_logic;
-- output to if/id reg
instruction_d: out std_logic_vector(31 downto 0);
pc_d: out std_logic_vector(31 downto 0);
inputport_d_if_id: out std_logic_vector(31 downto 0);

--memory section
-- input from ex/mem reg
sp_q: in std_logic_vector(31 downto 0);
pc1_q: in std_logic_vector(31 downto 0);
alu_q: in std_logic_vector(31 downto 0);
inputport_q:in std_logic_vector(31 downto 0);
readdata1_q:in std_logic_vector(31 downto 0);
readdata2_q:in std_logic_vector(31 downto 0);
writeaddress1_q:in std_logic_vector(2 downto 0);
writeaddress2_q:in std_logic_vector(2 downto 0);
memtoreg_q: in std_logic;
outputenable_q: in std_logic;
regwrite1_q: in std_logic;
regwrite2_q: in std_logic;
inputenable_q:in std_logic;
memwrite_q:in std_logic;
memread_q:in std_logic;
mem_add_src_q: in std_logic;
mem_data_src_q: in std_logic;
sp_dec_q: in std_logic;
pc_src_q: in std_logic;

-- input from assembler 
offset: in std_logic_vector(31 downto 0);

--output to mem/wb reg
memory_d: out std_logic_vector(31 downto 0);
alu_d:out std_logic_vector(31 downto 0);
inputport_d:out std_logic_vector(31 downto 0);
readdata1_d:out std_logic_vector(31 downto 0);
readdata2_d:out std_logic_vector(31 downto 0);
writeaddress1_d: out std_logic_vector(2 downto 0);
writeaddress2_d: out std_logic_vector(2 downto 0);
memtoreg_d:out std_logic;
outputenable_d:out std_logic;
regwrite1_d:out std_logic;
regwrite2_d:out std_logic;
inputenable_d:out std_logic;

-- output sp and dec_sp for excute section
ex_mem_sp: out std_logic_vector(31 downto 0);
ex_mem_sp_dec: out std_logic
);

end component;

component decode is
    port(
        -- inputs 
        clk,rst:in std_logic;
        instruction_in:in std_logic_vector(31 downto 0);
        pc_in:in std_logic_vector(31 downto 0);
        inputport_in:in std_logic_vector(31 downto 0);
        -- writeback stage inputs
        mem_rb_regwrite1,mem_rb_regwrite2:in std_logic;
        mem_rb_writeaddress1,mem_rb_writeaddress2: in std_logic_vector(2 downto 0);
        mem_rb_writedata1,mem_rb_writedata2:in std_logic_vector(31 downto 0);
        -- outputs 
        pc_out: out std_logic_vector(31 downto 0); -- hay3ady 3alatool.
        readdata1:out std_logic_vector(31 downto 0); -- hayetla3 mn regfile 3alatool.
        readdata2:out std_logic_vector(31 downto 0);  -- hayetla3 mn regfile 3alatool.
        immediate: out std_logic_vector(31 downto 0); -- sign extended code soghayar.
        inputport_out: out std_logic_vector(31 downto 0); -- hay3ady 3alatool bas et2aked.
        writeaddress1_out,writeaddress2_out:out std_logic_vector(2 downto 0); -- hanakhdo mn el instruction w ye3ady.
        ----
        rs_out,rt_out: out std_logic_vector(2 downto 0);
        -- control signal outputs
        mem_write, mem_read, reg_write1, reg_write2, mem_to_reg, input_en, output_en : out std_logic;
        branch, alu_src, CCR_store,	CCR_restore, flag_enable : out std_logic;
        pc_src, mem_data_src, mem_add_src, sp_inc, sp_dec,	set_carry, clk_enable : out std_logic;
        alu_control : out std_logic_vector(2 downto 0);
        branch_type : out std_logic_vector(1 downto 0);
        hlt_signal : out std_logic
    );
end component;

component execute is 
    port(
        clk,rst: in std_logic; 
        --output of register id/ex
        immediate_q: in std_logic_vector(31 downto 0);
        pc1_q: in std_logic_vector(31 downto 0);
        inputport_q:in std_logic_vector(31 downto 0);
        readdata1_q:in std_logic_vector(31 downto 0);
        readdata2_q:in std_logic_vector(31 downto 0);
        writeaddress1_q:in std_logic_vector(2 downto 0);
        writeaddress2_q:in std_logic_vector(2 downto 0);
        memtoreg_q: in std_logic;
        outputenable_q: in std_logic;
        regwrite1_q: in std_logic;
        regwrite2_q: in std_logic;
        inputenable_q:in std_logic;
        memwrite_q:in std_logic;
        memread_q:in std_logic;
        mem_add_src_q: in std_logic;
        mem_data_src_q: in std_logic;
        sp_dec_q: in std_logic; --meen da??? ha pass it for now then nebaa neshouf
        pc_src_q: in std_logic;
        alu_control_q: in std_logic_vector(2 downto 0);
        alu_src_q: in std_logic;
        branch_q: in std_logic;
        branch_type_q: in std_logic_vector(1 downto 0);
        inc_sp_q: in std_logic;
        set_carry_q: in std_logic;
        ccr_store_q: in std_logic;
        ccr_restore_q: in std_logic;
        flag_enable_q: in std_logic;
        --outputs of mem el  2 lines ely dakhleen lel sp men odam
        exmem_sp: in std_logic_vector(31 downto 0);
        exmem_decsp: in std_logic;
        --inputs of ex/mem
       
        sp_d: out std_logic_vector(31 downto 0);
        pc1_d: out std_logic_vector(31 downto 0);
        alu_d:out std_logic_vector(31 downto 0);
        inputport_d:out std_logic_vector(31 downto 0);
        readdata1_d:out std_logic_vector(31 downto 0);
        readdata2_d:out std_logic_vector(31 downto 0);
        writeaddress1_d: out std_logic_vector(2 downto 0);
        writeaddress2_d: out std_logic_vector(2 downto 0);
        memtoreg_d:out std_logic;
        outputenable_d:out std_logic;
        regwrite1_d:out std_logic;
        regwrite2_d:out std_logic;
        inputenable_d:out std_logic;
        memwrite_d:out std_logic;
        memread_d:out std_logic;
        mem_add_src_d: out std_logic;
        mem_data_src_d: out std_logic;
        sp_dec_d: out std_logic; 
        pc_src_d: out std_logic;

        --adder ely fo2
        pc_plus1_plus_sign_extend: out std_logic_vector(31 downto 0);

        --branch 
        do_branch: out std_logic;
        ---- forwarding input from the register------
        rs_q: in std_logic_vector(2 downto 0);
        rt_q: in std_logic_vector(2 downto 0);

        -------- info form ex/mem ------------------
        ex_mem_regwrite1: in std_logic;
        ex_mem_regwrite2: in std_logic;
        ex_mem_writeaddress1:in std_logic_vector(2 downto 0);
        ex_mem_writeaddress2: in std_logic_vector(2 downto 0);
        ex_mem_alu_output: in std_logic_vector(31 downto 0);
        ex_mem_readdata1: in std_logic_vector(31 downto 0);
        ex_mem_readdata2: in std_logic_vector(31 downto 0);

        -------- info from mem/wb -------------------
        mem_wb_regwrite1: in std_logic;
        mem_wb_regwrite2: in std_logic;
        mem_wb_writeaddress1: in std_logic_vector(2 downto 0);
        mem_wb_writeaddress2:in std_logic_vector(2 downto 0);
        mem_wb_writedata: in std_logic_vector(31 downto 0);
        mem_wb_readdata1:in std_logic_vector(31 downto 0)

        );

end component;

component writeBack is
    port (
        memData: in std_logic_vector(31 downto 0); -- Memory read
        aluResult: in std_logic_vector(31 downto 0); -- ALU output
        readData1_in: in std_logic_vector(31 downto 0); -- Read data 1
        readData1_out: out std_logic_vector(31 downto 0); -- Read data 1
        readData2_in: in std_logic_vector(31 downto 0); -- Read data 2
        writeAddress1_in: in std_logic_vector(2 downto 0); -- Write address 1
        writeAddress1_out: out std_logic_vector(2 downto 0); -- Write address 1
        writeAddress2_in: in std_logic_vector(2 downto 0); -- Write address 2
        writeAddress2_out: out std_logic_vector(2 downto 0); -- Write address 2
        memToReg: in std_logic; -- control signal to select memory or ALU
        regWrite1_in: in std_logic; -- control signal for write port 1
        regWrite1_out: out std_logic; -- control signal for write port 1
        regWrite2_in: in std_logic; -- control signal for write port 2
        regWrite2_out: out std_logic; -- control signal for write port 2
        -- memWrite_in: in std_logic; -- control signal for memory write
        -- memWrite_out: out std_logic; -- control signal for memory write

        inputPortData: in std_logic_vector(31 downto 0); -- Input port data
        inputPortEnable: in std_logic; -- Input port enable
        outputPortEnable: in std_logic; -- Output port enable
        outputPort: out std_logic_vector(31 downto 0);

        writeBack_out: out std_logic_vector(31 downto 0)
    );
end component;

component if_id_reg is 
    port(
        clk,rst, enable:in std_logic; 
        instruction_d: in std_logic_vector(31 downto 0);
        instruction_q: out std_logic_vector(31 downto 0);
        pc_d:in std_logic_vector(31 downto 0);
        pc_q:out std_logic_vector(31 downto 0);
        inputport_d:in std_logic_vector(31 downto 0);
        inputport_q:out std_logic_vector(31 downto 0)

        );
end component;

component id_ex_reg is 
    port(
        clk,rst, enable:in std_logic; 
        immediate_d: in std_logic_vector(31 downto 0);
        immediate_q: out std_logic_vector(31 downto 0);
        pc1_d: in std_logic_vector(31 downto 0);
        pc1_q: out std_logic_vector(31 downto 0);
        inputport_d:in std_logic_vector(31 downto 0);
        inputport_q:out std_logic_vector(31 downto 0);
        readdata1_d:in std_logic_vector(31 downto 0);
        readdata1_q:out std_logic_vector(31 downto 0);
        readdata2_d:in std_logic_vector(31 downto 0);
        readdata2_q:out std_logic_vector(31 downto 0);
        writeaddress1_d: in std_logic_vector(2 downto 0);
        writeaddress1_q:out std_logic_vector(2 downto 0);
        writeaddress2_d: in std_logic_vector(2 downto 0);
        writeaddress2_q:out std_logic_vector(2 downto 0);
        memtoreg_q: out std_logic;
        memtoreg_d:in std_logic;
        outputenable_q: out std_logic;
        outputenable_d:in std_logic;
        regwrite1_q: out std_logic;
        regwrite1_d:in std_logic;
        regwrite2_q: out std_logic;
        regwrite2_d:in std_logic;
        inputenable_q:out std_logic;
        inputenable_d:in std_logic;
        memwrite_q:out std_logic;
        memwrite_d:in std_logic;
        memread_q:out std_logic;
        memread_d:in std_logic;
        mem_add_src_q: out std_logic;
        mem_add_src_d: in std_logic;
        mem_data_src_q: out std_logic;
        mem_data_src_d: in std_logic;
        sp_dec_q: out std_logic;
        sp_dec_d: in std_logic;
        pc_src_q: out std_logic;
        pc_src_d: in std_logic;
        alu_control_q: out std_logic_vector(2 downto 0);
        alu_control_d: in std_logic_vector(2 downto 0);
        alu_src_q: out std_logic;
        alu_src_d: in std_logic;
        branch_q: out std_logic;
        branch_d: in std_logic;
        branch_type_q: out std_logic_vector(1 downto 0);
        branch_type_d: in std_logic_vector(1 downto 0);
        inc_sp_q: out std_logic;
        inc_sp_d: in std_logic;
        set_carry_q: out std_logic;
        set_carry_d: in std_logic;
        ccr_store_q: out std_logic;
        ccr_store_d: in std_logic;
        ccr_restore_q: out std_logic;
        ccr_restore_d: in std_logic;
        flag_enable_q: out std_logic;
        flag_enable_d: in std_logic;
        ---- 
        rs_d:in std_logic_vector(2 downto 0);
        rs_q: out std_logic_vector(2 downto 0);
        rt_d: in std_logic_vector(2 downto 0);
        rt_q: out std_logic_vector(2 downto 0)
        );
end component;

component ex_mem_reg is 
    port(
        clk,rst, enable:in std_logic; 
        sp_d: in std_logic_vector(31 downto 0);
        sp_q: out std_logic_vector(31 downto 0);
        pc1_d: in std_logic_vector(31 downto 0);
        pc1_q: out std_logic_vector(31 downto 0);
        alu_d:in std_logic_vector(31 downto 0);
        alu_q:out std_logic_vector(31 downto 0);
        inputport_d:in std_logic_vector(31 downto 0);
        inputport_q:out std_logic_vector(31 downto 0);
        readdata1_d:in std_logic_vector(31 downto 0);
        readdata1_q:out std_logic_vector(31 downto 0);
        readdata2_d:in std_logic_vector(31 downto 0);
        readdata2_q:out std_logic_vector(31 downto 0);
        writeaddress1_d: in std_logic_vector(2 downto 0);
        writeaddress1_q:out std_logic_vector(2 downto 0);
        writeaddress2_d: in std_logic_vector(2 downto 0);
        writeaddress2_q:out std_logic_vector(2 downto 0);
        memtoreg_q: out std_logic;
        memtoreg_d:in std_logic;
        outputenable_q: out std_logic;
        outputenable_d:in std_logic;
        regwrite1_q: out std_logic;
        regwrite1_d:in std_logic;
        regwrite2_q: out std_logic;
        regwrite2_d:in std_logic;
        inputenable_q:out std_logic;
        inputenable_d:in std_logic;
        memwrite_q:out std_logic;
        memwrite_d:in std_logic;
        memread_q:out std_logic;
        memread_d:in std_logic;
        mem_add_src_q: out std_logic;
        mem_add_src_d: in std_logic;
        mem_data_src_q: out std_logic;
        mem_data_src_d: in std_logic;
        sp_dec_q: out std_logic;
        sp_dec_d: in std_logic;
        pc_src_q: out std_logic;
        pc_src_d: in std_logic;
        branch_q: out std_logic;
        branch_d: in std_logic
        );
end component;

component mem_wb_reg is 
    port(
        clk,rst, enable:in std_logic; 
        memory_d: in std_logic_vector(31 downto 0);
        memory_q: out std_logic_vector(31 downto 0); ---------
        alu_d:in std_logic_vector(31 downto 0);
        alu_q:out std_logic_vector(31 downto 0); ----------
        inputport_d:in std_logic_vector(31 downto 0);
        inputport_q:out std_logic_vector(31 downto 0); ----------
        readdata1_d:in std_logic_vector(31 downto 0);
        readdata1_q:out std_logic_vector(31 downto 0);  ----------
        readdata2_d:in std_logic_vector(31 downto 0);
        readdata2_q:out std_logic_vector(31 downto 0); --------
        writeaddress1_d: in std_logic_vector(2 downto 0);
        writeaddress1_q:out std_logic_vector(2 downto 0);  ----------
        writeaddress2_d: in std_logic_vector(2 downto 0);
        writeaddress2_q:out std_logic_vector(2 downto 0);  ----------
        memtoreg_q: out std_logic; ---------
        memtoreg_d:in std_logic; 
        outputenable_q: out std_logic; ---------
        outputenable_d:in std_logic;
        regwrite1_q: out std_logic;  -------
        regwrite1_d:in std_logic;
        regwrite2_q: out std_logic; -------
        regwrite2_d:in std_logic;
        inputenable_q:out std_logic; ------
        inputenable_d:in std_logic
        -- memwrite_q:out std_logic; -------
        -- memwrite_d:in std_logic
        );
end component;

component hazard_unit is 
port (
    reset: in std_logic;
    id_ex_mem_read, id_ex_mem_write: in std_logic;
    ex_mem_mem_read, ex_mem_mem_write: in std_logic;
    rst_if_id, rst_id_ex, rst_ex_mem, rst_mem_wb: out std_logic;
    branch1, branch2 : in std_logic; 
    enable_if_id, enable_id_ex, enable_ex_mem, enable_mem_wb: out std_logic;
    pc_enable: out std_logic
);
end component;

signal pc_plus_immediate : std_logic_vector(31 downto 0);
signal do_branch : std_logic;
signal pc_enable : std_logic;
signal rst_if_id, rst_id_ex, rst_ex_mem, rst_mem_wb : std_logic;
signal enable_if_id, enable_id_ex, enable_ex_mem, enable_mem_wb : std_logic;
signal instruction_if_id_in, input_port_if_id_in : std_logic_vector(31 downto 0);
signal pc_if_id_in : std_logic_vector(31 downto 0);

signal instruction_if_id_out, input_port_if_id_out : std_logic_vector(31 downto 0);
signal pc_if_id_out : std_logic_vector(31 downto 0);

signal mem_rb_regwrite1, mem_rb_regwrite2: std_logic;
signal mem_rb_writeaddress1, mem_rb_writeaddress2: std_logic_vector(2 downto 0);
signal mem_rb_writedata1, mem_rb_writedata2: std_logic_vector(31 downto 0);

signal immediate_id_ex_in, pc1_id_ex_in, inputport_id_ex_in, readdata1_id_ex_in, readdata2_id_ex_in : std_logic_vector(31 downto 0);
signal writeaddress1_id_ex_in, writeaddress2_id_ex_in : std_logic_vector(2 downto 0);
signal memtoreg_id_ex_in, outputenable_id_ex_in, regwrite1_id_ex_in, regwrite2_id_ex_in, inputenable_id_ex_in, memwrite_id_ex_in : std_logic;
signal memread_id_ex_in, mem_add_src_id_ex_in, mem_data_src_id_ex_in, sp_dec_id_ex_in, pc_src_id_ex_in : std_logic;
signal alu_control_id_ex_in : std_logic_vector(2 downto 0);
signal branch_type_id_ex_in : std_logic_vector(1 downto 0);
signal alu_src_id_ex_in, branch_id_ex_in, inc_sp_id_ex_in, set_carry_id_ex_in, ccr_store_id_ex_in, ccr_restore_id_ex_in, flag_enable_id_ex_in : std_logic;

signal immediate_id_ex_out, pc1_id_ex_out, inputport_id_ex_out, readdata1_id_ex_out, readdata2_id_ex_out : std_logic_vector(31 downto 0);
signal writeaddress1_id_ex_out, writeaddress2_id_ex_out : std_logic_vector(2 downto 0);
signal memtoreg_id_ex_out, outputenable_id_ex_out, regwrite1_id_ex_out, regwrite2_id_ex_out, inputenable_id_ex_out, memwrite_id_ex_out : std_logic;
signal memread_id_ex_out, mem_add_src_id_ex_out, mem_data_src_id_ex_out, sp_dec_id_ex_out, pc_src_id_ex_out : std_logic;
signal alu_control_id_ex_out : std_logic_vector(2 downto 0);
signal branch_type_id_ex_out : std_logic_vector(1 downto 0);
signal alu_src_id_ex_out, branch_id_ex_out, inc_sp_id_ex_out, set_carry_id_ex_out, ccr_store_id_ex_out, ccr_restore_id_ex_out, flag_enable_id_ex_out : std_logic;
---- forward signals----------
signal rs_id_ex_in,rt_id_ex_in: std_logic_vector(2 downto 0);
signal rs_id_ex_out:std_logic_vector(2 downto 0);
signal rt_id_ex_out:std_logic_vector(2 downto 0);
signal exmem_sp: std_logic_vector(31 downto 0);
signal exmem_decsp: std_logic;

signal sp_ex_mem_in, pc1_ex_mem_in, alu_ex_mem_in, inputport_ex_mem_in, readdata1_ex_mem_in : std_logic_vector(31 downto 0);
signal readdata2_ex_mem_in : std_logic_vector(31 downto 0);
signal writeaddress1_ex_mem_in : std_logic_vector(2 downto 0);
signal writeaddress2_ex_mem_in : std_logic_vector(2 downto 0);
signal memtoreg_ex_mem_in : std_logic;
signal outputenable_ex_mem_in : std_logic;
signal regwrite1_ex_mem_in : std_logic;
signal regwrite2_ex_mem_in : std_logic;
signal inputenable_ex_mem_in : std_logic;
signal memwrite_ex_mem_in : std_logic;
signal memread_ex_mem_in : std_logic;
signal mem_add_src_ex_mem_in : std_logic;
signal mem_data_src_ex_mem_in : std_logic;
signal sp_dec_ex_mem_in : std_logic;
signal pc_src_ex_mem_in : std_logic;

signal sp_ex_mem_out, pc1_ex_mem_out, alu_ex_mem_out, inputport_ex_mem_out, readdata1_ex_mem_out : std_logic_vector(31 downto 0);
signal readdata2_ex_mem_out : std_logic_vector(31 downto 0);
signal writeaddress1_ex_mem_out : std_logic_vector(2 downto 0);
signal writeaddress2_ex_mem_out : std_logic_vector(2 downto 0);
signal memtoreg_ex_mem_out : std_logic;
signal outputenable_ex_mem_out : std_logic;
signal regwrite1_ex_mem_out : std_logic;
signal regwrite2_ex_mem_out : std_logic;
signal inputenable_ex_mem_out : std_logic;
signal memwrite_ex_mem_out : std_logic;
signal memread_ex_mem_out : std_logic;
signal mem_add_src_ex_mem_out : std_logic;
signal mem_data_src_ex_mem_out : std_logic;
signal sp_dec_ex_mem_out : std_logic;
signal pc_src_ex_mem_out : std_logic;
signal branch_ex_mem_out : std_logic;

signal offset_assembler : std_logic_vector(31 downto 0) := x"00000000";

signal memory_mem_wb_in, alu_mem_wb_in, inputport_mem_wb_in, readdata1_mem_wb_in : std_logic_vector(31 downto 0);
signal readdata2_mem_wb_in : std_logic_vector(31 downto 0);
signal writeaddress1_mem_wb_in : std_logic_vector(2 downto 0);
signal writeaddress2_mem_wb_in : std_logic_vector(2 downto 0);
signal memtoreg_mem_wb_in : std_logic;
signal outputenable_mem_wb_in : std_logic;
signal regwrite1_mem_wb_in : std_logic;
signal regwrite2_mem_wb_in : std_logic;
signal inputenable_mem_wb_in : std_logic;

signal memory_mem_wb_out, alu_mem_wb_out, inputport_mem_wb_out, readdata1_mem_wb_out : std_logic_vector(31 downto 0);
signal readdata2_mem_wb_out : std_logic_vector(31 downto 0);
signal writeaddress1_mem_wb_out : std_logic_vector(2 downto 0);
signal writeaddress2_mem_wb_out : std_logic_vector(2 downto 0);
signal memtoreg_mem_wb_out : std_logic;
signal outputenable_mem_wb_out : std_logic;
signal regwrite1_mem_wb_out : std_logic;
signal regwrite2_mem_wb_out : std_logic;
signal inputenable_mem_wb_out : std_logic;

signal clk, hlt_signal : std_logic;
begin

clk <= '0' when hlt_signal = '1'
else clk_input;

FetchMem_comp: fetch_mem 
port map(
--fetch section
-- input to processor
input_port => input_port,
clk => clk, 
reset => reset, 
interrupt => interrupt,
-- input from excute section
pc_plus_immediate => pc_plus_immediate,
do_branch => do_branch,
-- input from hazard detection
pc_enable => pc_enable,
-- output to if/id reg
instruction_d => instruction_if_id_in,
pc_d => pc_if_id_in,
inputport_d_if_id => input_port_if_id_in,

--memory section
-- input from ex/mem reg
sp_q => sp_ex_mem_out,
pc1_q => pc1_ex_mem_out,
alu_q => alu_ex_mem_out,
inputport_q => inputport_ex_mem_out,
readdata1_q => readdata1_ex_mem_out,
readdata2_q => readdata2_ex_mem_out,
writeaddress1_q => writeaddress1_ex_mem_out,
writeaddress2_q => writeaddress2_ex_mem_out,
memtoreg_q => memtoreg_ex_mem_out,
outputenable_q => outputenable_ex_mem_out,
regwrite1_q => regwrite1_ex_mem_out,
regwrite2_q => regwrite2_ex_mem_out,
inputenable_q => inputenable_ex_mem_out,
memwrite_q => memwrite_ex_mem_out,
memread_q => memread_ex_mem_out,
mem_add_src_q => mem_add_src_ex_mem_out,
mem_data_src_q => mem_data_src_ex_mem_out,
sp_dec_q => sp_dec_ex_mem_out,
pc_src_q => pc_src_ex_mem_out,

-- input from assembler 
offset => offset_assembler,

--output to mem/wb reg
memory_d => memory_mem_wb_in,
alu_d => alu_mem_wb_in,
inputport_d => inputport_mem_wb_in,
readdata1_d => readdata1_mem_wb_in,
readdata2_d => readdata2_mem_wb_in,
writeaddress1_d => writeaddress1_mem_wb_in,
writeaddress2_d => writeaddress2_mem_wb_in,
memtoreg_d => memtoreg_mem_wb_in,
outputenable_d => outputenable_mem_wb_in,
regwrite1_d => regwrite1_mem_wb_in,
regwrite2_d => regwrite2_mem_wb_in,
inputenable_d => inputenable_mem_wb_in,

-- output sp and dec_sp for excute section
ex_mem_sp => exmem_sp,
ex_mem_sp_dec => exmem_decsp
);

if_id_reg_comp: if_id_reg 
    port map(
        clk => clk,
        rst => rst_if_id, 
        enable => enable_if_id,
        instruction_d => instruction_if_id_in,
        instruction_q => instruction_if_id_out,
        pc_d => pc_if_id_in,
        pc_q => pc_if_id_out,
        inputport_d => input_port_if_id_in,
        inputport_q => input_port_if_id_out
    );

decode_comp: decode 
port map(
    -- inputs 
    clk => clk,
    rst => reset,
    instruction_in => instruction_if_id_out,
    pc_in => pc_if_id_out,
    inputport_in => input_port_if_id_out,
    -- writeback stage inputs
    mem_rb_regwrite1 => mem_rb_regwrite1,
    mem_rb_regwrite2 => mem_rb_regwrite2,
    mem_rb_writeaddress1 => mem_rb_writeaddress1,
    mem_rb_writeaddress2 => mem_rb_writeaddress2,
    mem_rb_writedata1 => mem_rb_writedata1,
    mem_rb_writedata2 => mem_rb_writedata2,
    -- outputs 
    pc_out => pc1_id_ex_in,
    readdata1 => readdata1_id_ex_in, 
    readdata2 => readdata2_id_ex_in,
    immediate => immediate_id_ex_in,
    inputport_out => inputport_id_ex_in,
    writeaddress1_out => writeaddress1_id_ex_in,
    writeaddress2_out => writeaddress2_id_ex_in,
    -- control signal outputs
    mem_write => memwrite_id_ex_in, 
    mem_read => memread_id_ex_in, 
    reg_write1 => regwrite1_id_ex_in, 
    reg_write2 => regwrite2_id_ex_in, 
    mem_to_reg => memtoreg_id_ex_in, 
    input_en => inputenable_id_ex_in, 
    output_en => outputenable_id_ex_in,
    branch => branch_id_ex_in,
    alu_src => alu_src_id_ex_in, 
    CCR_store => ccr_store_id_ex_in,	
    CCR_restore => ccr_restore_id_ex_in, 
    flag_enable => flag_enable_id_ex_in,
    pc_src => pc_src_id_ex_in, 
    mem_data_src => mem_data_src_id_ex_in, 
    mem_add_src => mem_add_src_id_ex_in, 
    sp_inc => inc_sp_id_ex_in, 
    sp_dec => sp_dec_id_ex_in,	
    set_carry => set_carry_id_ex_in, 
    clk_enable => clk_enable,
    alu_control => alu_control_id_ex_in,
    branch_type => branch_type_id_ex_in,
    --- forward
    rs_out=> rs_id_ex_in,
    rt_out=>rt_id_ex_in,
    hlt_signal => hlt_signal
);

id_ex_comp: id_ex_reg
    port map(
        clk => clk,
        rst => rst_id_ex, 
        enable => enable_id_ex,
        immediate_d => immediate_id_ex_in,
        immediate_q => immediate_id_ex_out,
        pc1_d => pc1_id_ex_in,
        pc1_q => pc1_id_ex_out,
        inputport_d => inputport_id_ex_in,
        inputport_q => inputport_id_ex_out,
        readdata1_d => readdata1_id_ex_in,
        readdata1_q => readdata1_id_ex_out,
        readdata2_d => readdata2_id_ex_in,
        readdata2_q => readdata2_id_ex_out,
        writeaddress1_d => writeaddress1_id_ex_in,
        writeaddress1_q => writeaddress1_id_ex_out,
        writeaddress2_d => writeaddress2_id_ex_in,
        writeaddress2_q => writeaddress2_id_ex_out,
        memtoreg_q => memtoreg_id_ex_out,
        memtoreg_d => memtoreg_id_ex_in,
        outputenable_q => outputenable_id_ex_out,
        outputenable_d => outputenable_id_ex_in,
        regwrite1_q => regwrite1_id_ex_out,
        regwrite1_d => regwrite1_id_ex_in,
        regwrite2_q => regwrite2_id_ex_out,
        regwrite2_d => regwrite2_id_ex_in,
        inputenable_q => inputenable_id_ex_out,
        inputenable_d => inputenable_id_ex_in,
        memwrite_q => memwrite_id_ex_out,
        memwrite_d => memwrite_id_ex_in,
        memread_q => memread_id_ex_out,
        memread_d => memread_id_ex_in,
        mem_add_src_q => mem_add_src_id_ex_out,
        mem_add_src_d => mem_add_src_id_ex_in,
        mem_data_src_q => mem_data_src_id_ex_out,
        mem_data_src_d => mem_data_src_id_ex_in,
        sp_dec_q => sp_dec_id_ex_out,
        sp_dec_d => sp_dec_id_ex_in,
        pc_src_q => pc_src_id_ex_out,
        pc_src_d => pc_src_id_ex_in,
        alu_control_q => alu_control_id_ex_out,
        alu_control_d => alu_control_id_ex_in,
        alu_src_q => alu_src_id_ex_out,
        alu_src_d => alu_src_id_ex_in,
        branch_q => branch_id_ex_out,
        branch_d => branch_id_ex_in,
        branch_type_q => branch_type_id_ex_out,
        branch_type_d => branch_type_id_ex_in,
        inc_sp_q => inc_sp_id_ex_out,
        inc_sp_d => inc_sp_id_ex_in,
        set_carry_q => set_carry_id_ex_out,
        set_carry_d => set_carry_id_ex_in,
        ccr_store_q => ccr_store_id_ex_out,
        ccr_store_d => ccr_store_id_ex_in,
        ccr_restore_q => ccr_restore_id_ex_out,
        ccr_restore_d => ccr_restore_id_ex_in,
        flag_enable_q => flag_enable_id_ex_out,
        flag_enable_d => flag_enable_id_ex_in,
        rs_d=>rs_id_ex_in,
        rs_q=>rs_id_ex_out,
        rt_d=>rt_id_ex_in,
        rt_q=>rt_id_ex_out
    );


excute_comp: execute 
    port map(
        clk => clk,
        rst => reset, 
        --output of register id/ex
        immediate_q => immediate_id_ex_out,
        pc1_q => pc1_id_ex_out,
        inputport_q => inputport_id_ex_out,
        readdata1_q => readdata1_id_ex_out,
        readdata2_q => readdata2_id_ex_out,
        writeaddress1_q => writeaddress1_id_ex_out,
        writeaddress2_q => writeaddress2_id_ex_out,
        memtoreg_q => memtoreg_id_ex_out,
        outputenable_q => outputenable_id_ex_out,
        regwrite1_q => regwrite1_id_ex_out,
        regwrite2_q => regwrite2_id_ex_out,
        inputenable_q => inputenable_id_ex_out,
        memwrite_q => memwrite_id_ex_out,
        memread_q => memread_id_ex_out,
        mem_add_src_q => mem_add_src_id_ex_out,
        mem_data_src_q => mem_data_src_id_ex_out,
        sp_dec_q => sp_dec_id_ex_out, --meen da??? ha pass it for now then nebaa neshouf
        pc_src_q => pc_src_id_ex_out,
        alu_control_q => alu_control_id_ex_out,
        alu_src_q => alu_src_id_ex_out,
        branch_q  => branch_id_ex_out,
        branch_type_q => branch_type_id_ex_out,
        inc_sp_q => inc_sp_id_ex_out,
        set_carry_q => set_carry_id_ex_out,
        ccr_store_q => ccr_store_id_ex_out,
        ccr_restore_q => ccr_restore_id_ex_out,
        flag_enable_q => flag_enable_id_ex_out,
        --outputs of mem el  2 lines ely dakhleen lel sp men odam
        exmem_sp => exmem_sp,
        exmem_decsp => exmem_decsp,
        --inputs of ex/mem
       
        sp_d => sp_ex_mem_in,
        pc1_d => pc1_ex_mem_in,
        alu_d => alu_ex_mem_in,
        inputport_d => inputport_ex_mem_in,
        readdata1_d => readdata1_ex_mem_in,
        readdata2_d => readdata2_ex_mem_in,
        writeaddress1_d => writeaddress1_ex_mem_in,
        writeaddress2_d => writeaddress2_ex_mem_in,
        memtoreg_d => memtoreg_ex_mem_in,
        outputenable_d => outputenable_ex_mem_in,
        regwrite1_d => regwrite1_ex_mem_in,
        regwrite2_d => regwrite2_ex_mem_in,
        inputenable_d => inputenable_ex_mem_in,
        memwrite_d => memwrite_ex_mem_in,
        memread_d => memread_ex_mem_in,
        mem_add_src_d => mem_add_src_ex_mem_in,
        mem_data_src_d => mem_data_src_ex_mem_in,
        sp_dec_d => sp_dec_ex_mem_in,
        pc_src_d => pc_src_ex_mem_in,

        --adder ely fo2
        pc_plus1_plus_sign_extend => pc_plus_immediate,

        --branch 
        do_branch => do_branch,
        -- forward----
        rs_q=> rs_id_ex_out,
        rt_q=>rt_id_ex_out,

        -------- info form ex/mem ------------------
        ex_mem_regwrite1=>regwrite1_ex_mem_out,
        ex_mem_regwrite2=>regwrite2_ex_mem_out,
        ex_mem_writeaddress1=>writeaddress1_ex_mem_out,
        ex_mem_writeaddress2=>writeaddress2_ex_mem_out,
        ex_mem_alu_output=>alu_ex_mem_out,
        ex_mem_readdata1=>readdata1_ex_mem_out,
        ex_mem_readdata2=>readdata2_ex_mem_out,

        -------- info from mem/wb -------------------
        mem_wb_regwrite1=>regwrite1_mem_wb_out,
        mem_wb_regwrite2=>regwrite2_mem_wb_out,
        mem_wb_writeaddress1=>writeaddress1_mem_wb_out,
        mem_wb_writeaddress2=>writeaddress2_mem_wb_out,
        mem_wb_writedata=>mem_rb_writedata1,
        mem_wb_readdata1=>readdata1_mem_wb_out
    );

    ex_mem_comp: ex_mem_reg 
    port map(
        clk => clk,
        rst => rst_ex_mem, 
        enable => enable_ex_mem,
        sp_d => sp_ex_mem_in,
        sp_q => sp_ex_mem_out,
        pc1_d => pc1_ex_mem_in,
        pc1_q => pc1_ex_mem_out,
        alu_d => alu_ex_mem_in,
        alu_q => alu_ex_mem_out,
        inputport_d => inputport_ex_mem_in,
        inputport_q => inputport_ex_mem_out,
        readdata1_d => readdata1_ex_mem_in,
        readdata1_q => readdata1_ex_mem_out,
        readdata2_d => readdata2_ex_mem_in,
        readdata2_q => readdata2_ex_mem_out,
        writeaddress1_d => writeaddress1_ex_mem_in,
        writeaddress1_q => writeaddress1_ex_mem_out,
        writeaddress2_d => writeaddress2_ex_mem_in,
        writeaddress2_q => writeaddress2_ex_mem_out,
        memtoreg_q => memtoreg_ex_mem_out,
        memtoreg_d => memtoreg_ex_mem_in,
        outputenable_q => outputenable_ex_mem_out,
        outputenable_d => outputenable_ex_mem_in,
        regwrite1_q => regwrite1_ex_mem_out,
        regwrite1_d => regwrite1_ex_mem_in,
        regwrite2_q => regwrite2_ex_mem_out,
        regwrite2_d => regwrite2_ex_mem_in,
        inputenable_q => inputenable_ex_mem_out,
        inputenable_d => inputenable_ex_mem_in,
        memwrite_q => memwrite_ex_mem_out,
        memwrite_d => memwrite_ex_mem_in,
        memread_q => memread_ex_mem_out,
        memread_d => memread_ex_mem_in,
        mem_add_src_q => mem_add_src_ex_mem_out,
        mem_add_src_d => mem_add_src_ex_mem_in,
        mem_data_src_q => mem_data_src_ex_mem_out,
        mem_data_src_d => mem_data_src_ex_mem_in,
        sp_dec_q => sp_dec_ex_mem_out,
        sp_dec_d => sp_dec_ex_mem_in,
        pc_src_q => pc_src_ex_mem_out,
        pc_src_d => pc_src_ex_mem_in,
        branch_q => branch_ex_mem_out,
        branch_d => do_branch
    );

    mem_wb_comp: mem_wb_reg 
    port map(
        clk => clk,
        rst => rst_mem_wb, 
        enable => enable_mem_wb,
        memory_d => memory_mem_wb_in,
        memory_q => memory_mem_wb_out, ---------
        alu_d => alu_mem_wb_in,
        alu_q => alu_mem_wb_out, ----------
        inputport_d => inputport_mem_wb_in,
        inputport_q => inputport_mem_wb_out, ----------
        readdata1_d => readdata1_mem_wb_in,
        readdata1_q => readdata1_mem_wb_out,  ----------
        readdata2_d => readdata2_mem_wb_in,
        readdata2_q => readdata2_mem_wb_out, --------
        writeaddress1_d => writeaddress1_mem_wb_in,
        writeaddress1_q => writeaddress1_mem_wb_out,  ----------
        writeaddress2_d => writeaddress2_mem_wb_in,
        writeaddress2_q => writeaddress2_mem_wb_out,  ----------
        memtoreg_q => memtoreg_mem_wb_out, ---------
        memtoreg_d => memtoreg_mem_wb_in,
        outputenable_q => outputenable_mem_wb_out, ---------
        outputenable_d => outputenable_mem_wb_in,   
        regwrite1_q => regwrite1_mem_wb_out,  -------
        regwrite1_d => regwrite1_mem_wb_in,
        regwrite2_q => regwrite2_mem_wb_out, -------
        regwrite2_d => regwrite2_mem_wb_in,
        inputenable_q => inputenable_mem_wb_out, ------
        inputenable_d => inputenable_mem_wb_in
    );

    write_back_comp: writeBack 
    port map (
        memData => memory_mem_wb_out, -- Memory read
        aluResult => alu_mem_wb_out, -- ALU output
        readData1_in => readdata1_mem_wb_out, -- Read data 1
        readData1_out => mem_rb_writedata2,
        readData2_in => readdata2_mem_wb_out, -- Read data 2
        writeAddress1_in => writeaddress1_mem_wb_out, -- Write address 1
        writeAddress1_out => mem_rb_writeaddress1,
        writeAddress2_in => writeaddress2_mem_wb_out, -- Write address 2
        writeAddress2_out => mem_rb_writeaddress2, 
        memToReg => memtoreg_mem_wb_out, -- control signal to select memory or ALU
        regWrite1_in => regwrite1_mem_wb_out, -- control signal for write port 1
        regWrite1_out => mem_rb_regwrite1,
        regWrite2_in => regwrite2_mem_wb_out, -- control signal for write port 2
        regWrite2_out => mem_rb_regwrite2,
        -- memWrite_in: in std_logic; -- control signal for memory write
        -- memWrite_out: out std_logic; -- control signal for memory write

        inputPortData => inputport_mem_wb_out, -- Input port data
        inputPortEnable => inputenable_mem_wb_out, -- Input port enable
        outputPortEnable => outputenable_mem_wb_out, -- Output port enable
        outputPort => output_port,

        writeBack_out => mem_rb_writedata1
    );

    hazard_comp: hazard_unit
    port map (
        reset => reset,
        id_ex_mem_read => memread_id_ex_out, 
        id_ex_mem_write => memwrite_id_ex_out, 
        ex_mem_mem_read => memread_ex_mem_out, 
        ex_mem_mem_write => memwrite_ex_mem_out,
        rst_if_id => rst_if_id,
        rst_id_ex => rst_id_ex, 
        rst_ex_mem => rst_ex_mem, 
        rst_mem_wb => rst_mem_wb,
        branch1 => do_branch,
        branch2 => branch_ex_mem_out, 
        enable_if_id => enable_if_id, 
        enable_id_ex => enable_id_ex, 
        enable_ex_mem => enable_ex_mem, 
        enable_mem_wb => enable_mem_wb,
        pc_enable => pc_enable   
    );
end architecture behaviour;