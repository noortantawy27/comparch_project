library ieee;
use ieee.std_logic_1164.all;
entity ex_mem_reg is 
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
        pc_src_d: in std_logic
        );
end ex_mem_reg;
architecture dff of ex_mem_reg is
begin 
process(clk,rst)
begin
    if(rst='1')then
        inputport_q<=(others=>'0');
        sp_q<=(others=>'0');
        pc1_q<=(others=>'0');
        alu_q<=(others=>'0');
        readdata1_q<=(others=>'0');
        readdata2_q<=(others=>'0');
        writeaddress2_q<=(others=>'0');
        writeaddress1_q<=(others=>'0');
        memtoreg_q<='0';
        outputenable_q<='0';
        regwrite1_q<='0';
        regwrite2_q<='0';
        inputenable_q<='0';
        memwrite_q<='0';
        memread_q<='0';
        mem_add_src_q<='0';
        mem_data_src_q<='0';
        sp_dec_q<='0';
        pc_src_q<='0';
    elsif clk'event and clk = '1' and enable = '1' then 
        inputport_q<=inputport_d;
        sp_q<=sp_d;
        pc1_q<=pc1_d;
        alu_q<=alu_d;
        readdata1_q<=readdata1_d;
        readdata2_q<=readdata2_d;
        writeaddress2_q<=writeaddress2_d;
        writeaddress1_q<=writeaddress1_d;
        memtoreg_q<=memtoreg_d;
        outputenable_q<=outputenable_d;
        regwrite1_q<=regwrite1_d;
        regwrite2_q<=regwrite2_d;
        inputenable_q<=inputenable_d;
        memwrite_q<=memwrite_d;
        memread_q<=memread_d;
        mem_add_src_q<=mem_add_src_d;
        mem_data_src_q<=mem_data_src_d;
        sp_dec_q<=sp_dec_d;
        pc_src_q<=pc_src_d;
    end if;
end process;
end dff; 