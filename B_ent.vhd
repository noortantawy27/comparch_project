Library ieee;
use ieee.std_logic_1164.all;

entity B_ent is
    GENERIC (
        N : integer := 16
    );
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : in std_logic_vector(3 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end entity B_ent;

Architecture B_imp of B_ent is
begin
    F <= A or B WHEN S = "0100" ELSE
         A and B WHEN S = "0101" ELSE
         A nor B WHEN S = "0110" ELSE
         Not A WHEN S = "0111";

    Cout <= '0';
end Architecture;
