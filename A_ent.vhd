Library ieee;
use ieee.std_logic_1164.all;

entity A_ent is
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
end entity A_ent;

Architecture A_imp of A_ent is
Component n_bit_adder is
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        Cin : in std_logic;
        S : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end Component;
signal cin_temp : std_logic;
signal a_temp, b_temp : std_logic_vector(N-1 downto 0);
signal b_complement_temp, not_b : std_logic_vector(N-1 downto 0);

begin
    not_b <= NOT B;
    two_complement: n_bit_adder GENERIC MAP (N,4) PORT MAP (not_b, (Others => '0'), '1', b_complement_temp, open );
    adder: n_bit_adder GENERIC MAP (N,4) PORT MAP (a_temp, b_temp, cin_temp, F, Cout);

    a_temp <= (Others => '0') when S = "0011" AND  Cin = '1' ELSE A; 
    
    b_temp <= (Others => '0') when S = "0000"
    ELSE not_b when S = "0001"
    ELSE (Others => '1') when S = "0011" AND Cin = '0'
    ELSE b_complement_temp when S = "0010" AND Cin = '0'
    ELSE B;

    cin_temp <= NOT Cin when S = "0001" OR (S = "0010" AND Cin = '0')  ELSE Cin;

end Architecture A_imp;