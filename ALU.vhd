Library ieee;
use ieee.std_logic_1164.all;

entity alu is
    GENERIC (
        N : integer := 32
    );
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : in std_logic_vector(2 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        zero_flag:out std_logic;
        negative_flag: out std_logic;
        Cout : out std_logic
    );
end entity alu;
Architecture alu_imp of alu is 
Component n_bit_adder is
    port (
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(N-1 downto 0);
        Cin: in std_logic;
        S: out std_logic_vector(N-1 downto 0);
        cout: out std_logic
    );
end Component;
signal adder_output:std_logic_vector(N-1 downto 0);
signal b_temp:std_logic_vector(N-1 downto 0);
signal cin_temp:std_logic;
signal cout_output: std_logic;
signal f_temp:std_logic_vector(N-1 downto 0);
begin
    not_b <= NOT B;
    adder: n_bit_adder GENERIC MAP (N,4) PORT MAP (A, b_temp,cin_temp,adder_output,cout_output);
    b_temp<=b when s="000"
    else not_b;

    cin_temp<='0' when s="000"
    else '1';

    f_temp<= A and B when s="010"
    else NOT A when s= "011"
    else B when s="100"
    else adder_output;

    cout<= cout_output when s="000" or s="001"
    else Cin;

    negative_flag<=f_temp(N-1);

    zero_flag<= '1' when f_temp=(Others => '0')
    else '0';




end Architecture;