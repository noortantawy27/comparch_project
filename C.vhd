Library ieee;
use ieee.std_logic_1164.all;

entity C is
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
end entity C;

Architecture C_imp of C is
begin
    F <= A(N-2 downto 0) & "0" WHEN S = "1000" ELSE
         A(N-2 downto 0) & A(N-1) WHEN S = "1001" ELSE
         A(N-2 downto 0) & Cin WHEN S = "1010" ELSE
         (Others => '0') WHEN S = "1011";

    Cout <= A(N-1) WHEN S = "1000" ELSE
            A(N-1) WHEN S = "1001" ELSE
            A(N-1) WHEN S = "1010" ELSE
            '0' WHEN S = "1011";
end Architecture;