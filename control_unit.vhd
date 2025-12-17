Library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        opcode : in std_logic_vector(4 downto 0);
        mem_write, mem_read, reg_write1, reg_write2, mem_to_reg, input_en, output_en : out std_logic;
        branch, alu_src, CCR_store,	CCR_restore, flag_enable : out std_logic;
        pc_src, mem_data_src, mem_add_src, sp_inc, sp_dec, set_carry, clk_enable : out std_logic;
        alu_control : out std_logic_vector(2 downto 0);
        branch_type : out std_logic_vector(1 downto 0)
    );
end entity control_unit;



Architecture control_unit_imp of control_unit is 

    constant NOP : std_logic_vector(4 downto 0) := "00000";
    constant HLT : std_logic_vector(4 downto 0) := "00001";
    constant SETC : std_logic_vector(4 downto 0) := "00010";
    constant NOT_op : std_logic_vector(4 downto 0) := "00111";
    constant INC : std_logic_vector(4 downto 0) := "00100";
    constant OUT_op : std_logic_vector(4 downto 0) := "00101";
    constant IN_op : std_logic_vector(4 downto 0) := "00110";
    constant MOV : std_logic_vector(4 downto 0) := "01011";
    constant SWAP : std_logic_vector(4 downto 0) := "01000";
    constant ADD : std_logic_vector(4 downto 0) := "01001";
    constant SUB : std_logic_vector(4 downto 0) := "01110";
    constant AND_op : std_logic_vector(4 downto 0) := "01111";
    constant IADD : std_logic_vector(4 downto 0) := "01100";
    constant PUSH : std_logic_vector(4 downto 0) := "10001";
    constant POP : std_logic_vector(4 downto 0) := "10010";
    constant LDM : std_logic_vector(4 downto 0) := "10111";
    constant LDD : std_logic_vector(4 downto 0) := "10100";
    constant STD : std_logic_vector(4 downto 0) := "10101";
    constant JZ : std_logic_vector(4 downto 0) := "11010";
    constant JN : std_logic_vector(4 downto 0) := "11011";
    constant JC : std_logic_vector(4 downto 0) := "11000";
    constant JMP : std_logic_vector(4 downto 0) := "11001";
    constant CALL : std_logic_vector(4 downto 0) := "11110";
    constant RET : std_logic_vector(4 downto 0) := "11111";
    constant INT : std_logic_vector(4 downto 0) := "11100";
    constant RTI : std_logic_vector(4 downto 0) := "11101";
    constant RESET : std_logic_vector(4 downto 0) := "10000";
    constant INTERRUPT : std_logic_vector(4 downto 0) := "10011";

begin

    with opcode select
        mem_write <= '1' when PUSH | STD | CALL | INT | INTERRUPT,
                 '0' when others;

    -- with opcode select
    --     mem_read <= '1' when POP | LDM | LDD | RET | INT | RTI | RESET | INTERRUPT,
    --              '0' when others;
    
    with opcode select
        reg_write1 <= '1' when NOT_op | INC | IN_op | SWAP | ADD | SUB | AND_op | IADD | POP | LDM | LDD ,
                     '0' when others;

    with opcode select
        reg_write2 <= '1' when MOV | SWAP,
                     '0' when others;

    with opcode select
        mem_to_reg <= '1' when POP | LDD,
                     '0' when others;

    with opcode select
        input_en <= '1' when IN_op,
                    '0' when others;

    with opcode select
        output_en <= '1' when OUT_op,
                     '0' when others;

    with opcode select
        branch_type <= "01" when JZ,
                       "10" when JN,
                       "11" when JC,
                       "00" when others;
    
    with opcode select
        branch <= '1' when JZ | JN | JC | JMP | CALL,
                  '0' when others;

    with opcode select
        alu_src <= '1' when NOT_op | ADD | SUB | AND_op | PUSH,
                   '0' when others;

    with opcode select
        CCR_store <= '1' when INT | INTERRUPT,
                     '0' when others;
    
    with opcode select
        CCR_restore <= '1' when  RTI,
                       '0' when others;
    
    with opcode select
        flag_enable <= '1' when NOT_op | INC | ADD | SUB | AND_op | IADD,
                       '0' when others;

    with opcode select
        pc_src <= '1' when RET | INT | RTI | RESET | INTERRUPT,
                  '0' when others;
    
    with opcode select 
        mem_data_src <= '1' when CALL | INT | INTERRUPT,
                        '0' when others;
    
    with opcode select
        mem_add_src <= '1' when PUSH | POP | CALL | RET |RTI, 
                       '0' when others;
    
    with opcode select 
        sp_inc <= '1' when POP | RET | RTI,
                  '0' when others;
    
    with opcode select 
        sp_dec <= '1' when PUSH | CALL | INT | INTERRUPT,
                    '0' when others;
    
    with opcode select 
        set_carry <= '1' when SETC,
                    '0' when others;
    with opcode select
        clk_enable <= '0' when HLT,
                      '1' when others;

    with opcode select
        alu_control <= "000" when INC | ADD | LDD | STD | IADD, --ADD
                       "011" when NOT_op, --NOT
                       "001" when SUB, --SUB
                       "010" when AND_op, --AND
                       "100" when PUSH | LDM | INT | RESET | INTERRUPT, --PASS
                       "111" when others; --DON'T CARE

    with opcode select
        mem_read <= '1' when POP | LDM | LDD | RET | INT | RTI | RESET | INTERRUPT,
                    '0' when others;

end Architecture;