Library ieee;
use ieee.std_logic_1164.all;

entity carry_select_adder is
    GENERIC (
        N : integer := 4
    );
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        Cin : in std_logic;
        S : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end entity carry_select_adder;

Architecture carry_select_adder_imp of carry_select_adder is
    Component ripple_adder is
        port (
            A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            Cin : in std_logic;
            S : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end Component;
    signal s0, s1 : std_logic_vector(N-1 downto 0);
    signal c0, c1 : std_logic;
begin
    r0: ripple_adder port map (A, B, '0', s0, c0);
    r1: ripple_adder port map (A, B, '1', s1, c1);
    S <= s0 WHEN Cin = '0' ELSE s1;
    Cout <= c0 WHEN Cin = '0' ELSE c1;
end Architecture carry_select_adder_imp;