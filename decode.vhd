Library ieee;
use ieee.std_logic_1164.all;
entity decode is
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
        writeaddress1_out, writeaddress2_out:out std_logic_vector(2 downto 0); -- hanakhdo mn el instruction w ye3ady.
        -- control signal outputs
        mem_write, mem_read, reg_write1, reg_write2, mem_to_reg, input_en, output_en : out std_logic;
        branch, alu_src, CCR_store,	CCR_restore, flag_enable : out std_logic;
        pc_src, mem_data_src, mem_add_src, sp_inc, sp_dec,set_carry, clk_enable : out std_logic;
        alu_control : out std_logic_vector(2 downto 0);
        branch_type : out std_logic_vector(1 downto 0)
    );
end decode;
architecture behaviour of decode is
-- instantiate registerfile
component reg_file
        generic( 
            N: integer := 32; 
            M: integer := 8 
        );
        port(
            clk, rst : in std_logic;
            readaddress1, readaddress2 : in std_logic_vector(2 downto 0);
            writeaddress1, writeaddress2 : in std_logic_vector(2 downto 0);
            wenable1, wenable2 : in std_logic;
            writeport1, writeport2 : in std_logic_vector(N-1 downto 0);
            readport1, readport2 : out std_logic_vector(N-1 downto 0)
        );
    end component;
-- control unit
component control_unit 
     port (
        opcode : in std_logic_vector(4 downto 0);
        mem_write, mem_read, reg_write1, reg_write2, mem_to_reg, input_en, output_en : out std_logic;
        branch, alu_src, CCR_store,	CCR_restore, flag_enable : out std_logic;
        pc_src, mem_data_src, mem_add_src, sp_inc, sp_dec,set_carry, clk_enable : out std_logic;
        alu_control : out std_logic_vector(2 downto 0);
        branch_type : out std_logic_vector(1 downto 0)
    );
end component;
-- signals needed.
signal immediate16bits: std_logic_vector(15 downto 0);
signal extenedimmediate32bit:std_logic_vector(31 downto 0);
signal en1,en2: std_logic;
begin
    -- reg file
    regfile: reg_file 
    generic map (N => 32, M => 8)
    port map
    (
        clk=>clk,
        rst=>rst,
        readaddress1=>instruction_in(23 downto 21),
        readaddress2=>instruction_in(20 downto 18),
        writeaddress1=>mem_rb_writeaddress1,
        writeaddress2=>mem_rb_writeaddress2,
        wenable1=>en1,
        wenable2=>en2,
        writeport1=>mem_rb_writedata1,
        writeport2=>mem_rb_writedata2,
        readport1=>readdata1,
        readport2=>readdata2
    );
    -- sign extend
    immediate16bits<=instruction_in(17 downto 2);
    extenedimmediate32bit<=(31 downto 16 =>immediate16bits(15))&immediate16bits;
    immediate<=extenedimmediate32bit; -- output
    en1<=mem_rb_regwrite1 or mem_rb_regwrite2;
    en2<=mem_rb_regwrite1 and mem_rb_regwrite2;
    -- outputs elly hat3ady 3alatool.
        writeaddress1_out<= instruction_in(26 downto 24);
        writeaddress2_out<= instruction_in(23 downto 21);
        inputport_out<=inputport_in;
        pc_out<=pc_in;
    
    -- control unit
    controlunit: control_unit port map (
        opcode=>instruction_in(31 downto 27),
        mem_write=>mem_write,
        mem_read=>mem_read,
        reg_write1=>reg_write1,
        reg_write2=>reg_write2,
        mem_to_reg=>mem_to_reg,
        input_en=>input_en,
        output_en=>output_en,
        branch=>branch,
        alu_src=>alu_src,
        CCR_store=>CCR_store,
        CCR_restore=>CCR_restore,
        flag_enable=>flag_enable,
        pc_src=>pc_src,
        mem_data_src=>mem_data_src,
        mem_add_src=>mem_add_src,
        sp_inc=>sp_inc,
        sp_dec=>sp_dec,
        set_carry=>set_carry,
        clk_enable=>clk_enable,
        alu_control=>alu_control,
        branch_type=>branch_type
    );

    
end architecture;