library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file_memory is
    generic( N: integer := 12; M: integer := 7 );
    port(
        clk, rst : in std_logic;
        readaddress1, readaddress2 : in std_logic_vector(2 downto 0);
        writeaddress1, writeaddress2 : in std_logic_vector(2 downto 0);
        wenable1, wenable2 : in std_logic;
        writeport1, writeport2 : in std_logic_vector(N-1 downto 0);
        readport1, readport2 : out std_logic_vector(N-1 downto 0)
    );
end reg_file_memory;

architecture structure of reg_file_memory is

    
    type mem_array is array (0 to M-1) of std_logic_vector(N-1 downto 0);
    signal memory : mem_array;
begin
 process(clk, rst)
    begin
        if(rst='1')then
            for i in 0 to M-1 loop
                memory(i)<=(others=>'0');
            end loop;
        elsif clk'event and clk = '1' then
            if (wenable1 = '1') then
                memory(to_integer(unsigned(writeaddress1))) <= writeport1;
            end if;

            if (wenable2 = '1') then
                memory(to_integer(unsigned(writeaddress2))) <= writeport2;
            end if;
        end if;
    end process;

    readport1 <= memory(to_integer(unsigned(readaddress1)));
    readport2 <= memory(to_integer(unsigned(readaddress2)));

end structure;
