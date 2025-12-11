library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    generic( N: integer := 32; M: integer := 8 );
    port(
        clk, rst : in std_logic;
        readaddress1, readaddress2 : in std_logic_vector(2 downto 0);
        writeaddress1, writeaddress2 : in std_logic_vector(2 downto 0);
        wenable1, wenable2 : in std_logic;
        writeport1, writeport2 : in std_logic_vector(N-1 downto 0);
        readport1, readport2 : out std_logic_vector(N-1 downto 0)
    );
end reg_file;

architecture structure of reg_file is

    
    type reg_array is array (0 to M-1) of std_logic_vector(N-1 downto 0);
    signal q_regs, d_regs : reg_array;

    component my_ndff is
        generic (n : integer := 12);
        port(
            Rst, Clk : in std_logic;
            d : in std_logic_vector(n-1 downto 0);
            q : out std_logic_vector(n-1 downto 0)
        );
    end component;

begin

    
    generate_regs : for i in 0 to M-1 generate
        reg_inst : my_ndff
            generic map (n => N)
            port map (
                Rst => rst,
                Clk => clk,
                d   => d_regs(i),
                q   => q_regs(i)
            );
    end generate;

    
    process(wenable1, wenable2, writeaddress1, writeaddress2, writeport1, writeport2, q_regs)
    begin
        if (wenable1 = '1') then
            d_regs(to_integer(unsigned(writeaddress1))) <= writeport1;
        end if;

        if (wenable2 = '1') then
            d_regs(to_integer(unsigned(writeaddress2))) <= writeport2;
        end if;

        readport1 <= q_regs(to_integer(unsigned(readaddress1)));
        readport2 <= q_regs(to_integer(unsigned(readaddress2)));
    end process;

end structure;
