library ieee;
use ieee.std_logic_1164.all;
entity mem_wb_reg is 
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
end mem_wb_reg;
architecture dff of mem_wb_reg is
begin 
process(clk,rst)
begin
    if(rst='1')then
        inputport_q<=(others=>'0');
        memory_q<=(others=>'0');
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
        -- memwrite_q<='0';
    elsif clk'event and clk = '1' and enable = '1' then 
        inputport_q<=inputport_d;
        memory_q<=memory_d;
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
        -- memwrite_q<=memwrite_d;
    end if;
end process;
end dff; 