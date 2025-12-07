Library ieee;
use ieee.std_logic_1164.all;

entity ripple_adder is
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
end entity ripple_adder;

Architecture ripple_adder_imp of ripple_adder is
    Component single_bit_adder is
        port (
            A : in std_logic;
            B : in std_logic;
            Cin : in std_logic;
            S : out std_logic;
            Cout : out std_logic
        );
    end Component;
    signal temp : std_logic_vector(N downto 0);
begin
    temp(0) <= Cin;
    GEN_LOOP: for i in 0 to N-1 generate
        fx: single_bit_adder port map (A(i), B(i), temp(i), S(i), temp(i+1));
    end generate GEN_LOOP;
    Cout <= temp(N);
end Architecture ripple_adder_imp;