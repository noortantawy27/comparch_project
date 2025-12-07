Library ieee;
use ieee.std_logic_1164.all;

entity alu is
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
end entity alu;

Architecture alu_imp of alu is
Component A_ent is 
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : in std_logic_vector(3 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end Component;

Component B_ent is 
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : in std_logic_vector(3 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end Component;

Component C is 
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : in std_logic_vector(3 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end Component;

Component D is 
    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : in std_logic_vector(3 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end Component;


signal a_f,b_f, c_f, d_f : std_logic_vector(N-1 downto 0);
signal a_cout,b_cout, c_cout, d_cout : std_logic;
begin
    a_comp: A_ent GENERIC MAP (N) PORT MAP (A,B,S,Cin,a_f,a_cout);
    b_comp: B_ent GENERIC MAP (N) PORT MAP (A,B,S,Cin,b_f,b_cout);
    c_comp: C GENERIC MAP (N) PORT MAP (A,B,S,Cin,c_f,c_cout);
    d_comp: D GENERIC MAP (N) PORT MAP (A,B,S,Cin,d_f,d_cout);

    F <= b_f WHEN S(3 downto 2) = "01" ELSE
         c_f WHEN S(3 downto 2) = "10" ELSE
         d_f WHEN S(3 downto 2) = "11" ELSE
         a_f;

    Cout <= b_cout WHEN S(3 downto 2) = "01" ELSE
            c_cout WHEN S(3 downto 2) = "10" ELSE
            d_cout WHEN S(3 downto 2) = "11" ELSE
            a_cout;
end Architecture;