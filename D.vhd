Library ieee;
use ieee.std_logic_1164.all;

entity D is
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
end entity D;

Architecture D_imp of D is
begin
    F <= "0" & A(N-1 downto 1) WHEN S = "1100" ELSE
         A(0) & A(N-1 downto 1) WHEN S = "1101" ELSE
         Cin & A(N-1 downto 1) WHEN S = "1110" ELSE
         A(N-1) & A(N-1 downto 1) WHEN S = "1111";

    Cout <= A(0) WHEN S = "1100" ELSE
            A(0) WHEN S = "1101" ELSE
            A(0) WHEN S = "1110" ELSE
            '0' WHEN S = "1111";
end Architecture;