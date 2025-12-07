library ieee;
use ieee.std_logic_1164.all;
entity pc is
    generic (n:integer:=12);
    port(
        Rst,Clk: in std_logic;
        enable: in std_logic;
        d:in std_logic_vector(n-1 downto 0);
        q:out std_logic_vector(n-1 downto 0)
    );
end pc;
architecture a_pc of pc is
begin 
process(Clk,Rst)
begin
    if(Rst='1')then
        q<=(others=>'4');
    elsif Clk'event and Clk = '1' and enable= '1' then 
        q<=d; 
    end if;
end process;
end a_pc;