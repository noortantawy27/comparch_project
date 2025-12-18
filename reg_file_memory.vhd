library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file_memory is
    generic( N: integer := 32; M: integer := 1024 );
    port(
        clk, rst : in std_logic;
        address, instruction_address  : in std_logic_vector(31 downto 0);
        mem_write, mem_read : in std_logic;
        writedata : in std_logic_vector(N-1 downto 0);
        mem_output : out std_logic_vector(N-1 downto 0)
    );
end reg_file_memory;

architecture structure of reg_file_memory is

    
    type mem_array is array (0 to M-1) of std_logic_vector(N-1 downto 0);
    signal memory : mem_array;
    signal readdata, instruction : std_logic_vector(N-1 downto 0);

begin
 process(clk, rst)
    begin
        if(rst='1')then
            for i in 0 to M-1 loop
                memory(i)<=(others=>'0');
            end loop;
        elsif clk'event and clk = '1' then
            if (mem_write = '1') then
                memory(to_integer(unsigned(address))) <= writedata;
            end if;
        end if;
    end process;
    readdata <= memory(to_integer(unsigned(address)));
    instruction <= memory(to_integer(unsigned(instruction_address)));
    
    mem_output <= readdata when mem_read = '1'
    else instruction when mem_write = '0';
end structure;
