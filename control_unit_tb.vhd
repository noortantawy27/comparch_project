library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit_tb is
end entity control_unit_tb;

architecture tb_arch of control_unit_tb is
    -- Component declaration
    component control_unit is
        port (
            opcode : in std_logic_vector(4 downto 0);
            mem_write, reg_write1, reg_write2, mem_to_reg, input_en, output_en : out std_logic;
            branch, alu_src, CCR_store, CCR_restore, flag_enable : out std_logic;
            pc_src, mem_data_src, mem_add_src, sp_inc, sp_dec, set_carry, clk_enable : out std_logic;
            alu_control : out std_logic_vector(2 downto 0);
            branch_type : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Test signals
    signal opcode : std_logic_vector(4 downto 0) := (others => '0');
    
    -- Control unit outputs
    signal mem_write, reg_write1, reg_write2, mem_to_reg : std_logic;
    signal input_en, output_en, branch, alu_src, CCR_store : std_logic;
    signal CCR_restore, flag_enable, pc_src, mem_data_src : std_logic;
    signal mem_add_src, sp_inc, sp_dec, set_carry : std_logic;
    signal clk_enable : std_logic;
    signal alu_control : std_logic_vector(2 downto 0);
    signal branch_type : std_logic_vector(1 downto 0);
    
    -- Expected values record type
    type control_signals_t is record
        mem_write, reg_write1, reg_write2, mem_to_reg : std_logic;
        input_en, output_en, branch, alu_src, CCR_store : std_logic;
        CCR_restore, flag_enable, pc_src, mem_data_src : std_logic;
        mem_add_src, sp_inc, sp_dec, set_carry, clk_enable : std_logic;
        alu_control : std_logic_vector(2 downto 0);
        branch_type : std_logic_vector(1 downto 0);
    end record;
    
    -- Test vector type
    type test_vector is record
        opcode : std_logic_vector(4 downto 0);
        opcode_name : string(1 to 5);  -- Name for display
        expected : control_signals_t;
    end record;
    
    -- Helper function to convert std_logic_vector to string
    function to_string(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
        variable index : integer;
    begin
        index := 1;
        for i in slv'range loop
            case slv(i) is
                when '0' => result(index) := '0';
                when '1' => result(index) := '1';
                when 'U' => result(index) := 'U';
                when 'X' => result(index) := 'X';
                when 'Z' => result(index) := 'Z';
                when '-' => result(index) := '-';
                when 'L' => result(index) := 'L';
                when 'H' => result(index) := 'H';
                when 'W' => result(index) := 'W';
                when others => result(index) := '?';
            end case;
            index := index + 1;
        end loop;
        return result;
    end function;
    
    -- Test vectors array
    type test_vector_array is array (natural range <>) of test_vector;
    
    -- Test vectors
    constant test_vectors : test_vector_array := (
        -- NOP: "00000"
        (
            opcode => "00000",
            opcode_name => "NOP  ",
            expected => (
                mem_write => '0',  reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- HLT: "00001"
        (
            opcode => "00001",
            opcode_name => "HLT  ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '0',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- SETC: "00010"
        (
            opcode => "00010",
            opcode_name => "SETC ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '1', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- NOT: "00111"
        (
            opcode => "00111",
            opcode_name => "NOT  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '1', CCR_store => '0', CCR_restore => '0', flag_enable => '1',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "011", branch_type => "00"
            )
        ),
        -- INC: "00100"
        (
            opcode => "00100",
            opcode_name => "INC  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '1',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "000", branch_type => "00"
            )
        ),
        -- OUT: "00101"
        (
            opcode => "00101",
            opcode_name => "OUT  ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '1', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- IN: "00110"
        (
            opcode => "00110",
            opcode_name => "IN   ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '0', input_en => '1', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- MOV: "01011"
        (
            opcode => "01011",
            opcode_name => "MOV  ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '1',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- SWAP: "01000"
        (
            opcode => "01000",
            opcode_name => "SWAP ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '1',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- ADD: "01001"
        (
            opcode => "01001",
            opcode_name => "ADD  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '1', CCR_store => '0', CCR_restore => '0', flag_enable => '1',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "000", branch_type => "00"
            )
        ),
        -- SUB: "01110"
        (
            opcode => "01110",
            opcode_name => "SUB  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '1', CCR_store => '0', CCR_restore => '0', flag_enable => '1',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "001", branch_type => "00"
            )
        ),
        -- AND: "01111"
        (
            opcode => "01111",
            opcode_name => "AND  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '1', CCR_store => '0', CCR_restore => '0', flag_enable => '1',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "010", branch_type => "00"
            )
        ),
        -- IADD: "01100"
        (
            opcode => "01100",
            opcode_name => "IADD ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '1',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "000", branch_type => "00"
            )
        ),
        -- PUSH: "10001"
        (
            opcode => "10001",
            opcode_name => "PUSH ",
            expected => (
                mem_write => '1', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '1', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '1', sp_inc => '0',
                sp_dec => '1', set_carry => '0', clk_enable => '1',
                alu_control => "100", branch_type => "00"
            )
        ),
        -- POP: "10010"
        (
            opcode => "10010",
            opcode_name => "POP  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '1', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '1', sp_inc => '1',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- LDM: "10111"
        (
            opcode => "10111",
            opcode_name => "LDM  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '1', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "100", branch_type => "00"
            )
        ),
        -- LDD: "10100"
        (
            opcode => "10100",
            opcode_name => "LDD  ",
            expected => (
                mem_write => '0', reg_write1 => '1', reg_write2 => '0',
                mem_to_reg => '1', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "000", branch_type => "00"
            )
        ),
        -- STD: "10101"
        (
            opcode => "10101",
            opcode_name => "STD  ",
            expected => (
                mem_write => '1', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "000", branch_type => "00"
            )
        ),
        -- JZ: "11010"
        (
            opcode => "11010",
            opcode_name => "JZ   ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '1',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "01"
            )
        ),
        -- JN: "11011"
        (
            opcode => "11011",
            opcode_name => "JN   ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '1',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "10"
            )
        ),
        -- JC: "11000"
        (
            opcode => "11000",
            opcode_name => "JC   ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '1',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "11"
            )
        ),
        -- JMP: "11001"
        (
            opcode => "11001",
            opcode_name => "JMP  ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '1',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- CALL: "11110"
        (
            opcode => "11110",
            opcode_name => "CALL ",
            expected => (
                mem_write => '1', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '1',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '0', mem_data_src => '1', mem_add_src => '1', sp_inc => '0',
                sp_dec => '1', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- RET: "11111"
        (
            opcode => "11111",
            opcode_name => "RET  ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '1', mem_data_src => '0', mem_add_src => '1', sp_inc => '1',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- INT: "11100"
        (
            opcode => "11100",
            opcode_name => "INT  ",
            expected => (
                mem_write => '1', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '1', CCR_restore => '0', flag_enable => '0',
                pc_src => '1', mem_data_src => '1', mem_add_src => '0', sp_inc => '0',
                sp_dec => '1', set_carry => '0', clk_enable => '1',
                alu_control => "100", branch_type => "00"
            )
        ),
        -- RTI: "11101"
        (
            opcode => "11101",
            opcode_name => "RTI  ",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '1', flag_enable => '0',
                pc_src => '1', mem_data_src => '0', mem_add_src => '1', sp_inc => '1',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "111", branch_type => "00"
            )
        ),
        -- RESET: "10000"
        (
            opcode => "10000",
            opcode_name => "RESET",
            expected => (
                mem_write => '0', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '0', CCR_restore => '0', flag_enable => '0',
                pc_src => '1', mem_data_src => '0', mem_add_src => '0', sp_inc => '0',
                sp_dec => '0', set_carry => '0', clk_enable => '1',
                alu_control => "100", branch_type => "00"
            )
        ),
        -- INTERRUPT: "10011"
        (
            opcode => "10011",
            opcode_name => "INTR ",
            expected => (
                mem_write => '1', reg_write1 => '0', reg_write2 => '0',
                mem_to_reg => '0', input_en => '0', output_en => '0', branch => '0',
                alu_src => '0', CCR_store => '1', CCR_restore => '0', flag_enable => '0',
                pc_src => '1', mem_data_src => '1', mem_add_src => '0', sp_inc => '0',
                sp_dec => '1', set_carry => '0', clk_enable => '1',
                alu_control => "100", branch_type => "00"
            )
        )
    );
    
    -- Error counter
    signal error_count : integer := 0;
    
begin
    -- Instantiate the control unit
    uut: control_unit
        port map (
            opcode => opcode,
            mem_write => mem_write,
            reg_write1 => reg_write1,
            reg_write2 => reg_write2,
            mem_to_reg => mem_to_reg,
            input_en => input_en,
            output_en => output_en,
            branch => branch,
            alu_src => alu_src,
            CCR_store => CCR_store,
            CCR_restore => CCR_restore,
            flag_enable => flag_enable,
            pc_src => pc_src,
            mem_data_src => mem_data_src,
            mem_add_src => mem_add_src,
            sp_inc => sp_inc,
            sp_dec => sp_dec,
            set_carry => set_carry,
            clk_enable => clk_enable,
            alu_control => alu_control,
            branch_type => branch_type
        );
    
    -- Test process
    test_process: process
        variable test_pass : boolean;
        variable opcode_str : string(1 to 5);
    begin
        report "Starting control unit testbench..." severity note;
        
        -- Initialize
        error_count <= 0;
        
        -- Test each vector
        for i in test_vectors'range loop
            -- Apply test vector
            opcode <= test_vectors(i).opcode;
            opcode_str := test_vectors(i).opcode_name;
            wait for 10 ns;
            
            -- Check all outputs
            test_pass := true;
            
            if mem_write /= test_vectors(i).expected.mem_write then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": mem_write = " & std_logic'image(mem_write) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.mem_write)
                       severity error;
                test_pass := false;
            end if;
            
           
            if reg_write1 /= test_vectors(i).expected.reg_write1 then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": reg_write1 = " & std_logic'image(reg_write1) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.reg_write1)
                       severity error;
                test_pass := false;
            end if;
            
            if reg_write2 /= test_vectors(i).expected.reg_write2 then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": reg_write2 = " & std_logic'image(reg_write2) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.reg_write2)
                       severity error;
                test_pass := false;
            end if;
            
            if mem_to_reg /= test_vectors(i).expected.mem_to_reg then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": mem_to_reg = " & std_logic'image(mem_to_reg) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.mem_to_reg)
                       severity error;
                test_pass := false;
            end if;
            
            if input_en /= test_vectors(i).expected.input_en then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": input_en = " & std_logic'image(input_en) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.input_en)
                       severity error;
                test_pass := false;
            end if;
            
            if output_en /= test_vectors(i).expected.output_en then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": output_en = " & std_logic'image(output_en) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.output_en)
                       severity error;
                test_pass := false;
            end if;
            
            if branch /= test_vectors(i).expected.branch then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": branch = " & std_logic'image(branch) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.branch)
                       severity error;
                test_pass := false;
            end if;
            
            if alu_src /= test_vectors(i).expected.alu_src then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": alu_src = " & std_logic'image(alu_src) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.alu_src)
                       severity error;
                test_pass := false;
            end if;
            
            if CCR_store /= test_vectors(i).expected.CCR_store then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": CCR_store = " & std_logic'image(CCR_store) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.CCR_store)
                       severity error;
                test_pass := false;
            end if;
            
            if CCR_restore /= test_vectors(i).expected.CCR_restore then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": CCR_restore = " & std_logic'image(CCR_restore) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.CCR_restore)
                       severity error;
                test_pass := false;
            end if;
            
            if flag_enable /= test_vectors(i).expected.flag_enable then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": flag_enable = " & std_logic'image(flag_enable) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.flag_enable)
                       severity error;
                test_pass := false;
            end if;
            
            if pc_src /= test_vectors(i).expected.pc_src then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": pc_src = " & std_logic'image(pc_src) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.pc_src)
                       severity error;
                test_pass := false;
            end if;
            
            if mem_data_src /= test_vectors(i).expected.mem_data_src then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": mem_data_src = " & std_logic'image(mem_data_src) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.mem_data_src)
                       severity error;
                test_pass := false;
            end if;
            
            if mem_add_src /= test_vectors(i).expected.mem_add_src then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": mem_add_src = " & std_logic'image(mem_add_src) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.mem_add_src)
                       severity error;
                test_pass := false;
            end if;
            
            if sp_inc /= test_vectors(i).expected.sp_inc then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": sp_inc = " & std_logic'image(sp_inc) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.sp_inc)
                       severity error;
                test_pass := false;
            end if;
            
            if sp_dec /= test_vectors(i).expected.sp_dec then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": sp_dec = " & std_logic'image(sp_dec) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.sp_dec)
                       severity error;
                test_pass := false;
            end if;
            
            if set_carry /= test_vectors(i).expected.set_carry then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": set_carry = " & std_logic'image(set_carry) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.set_carry)
                       severity error;
                test_pass := false;
            end if;
            
            if clk_enable /= test_vectors(i).expected.clk_enable then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": clk_enable = " & std_logic'image(clk_enable) & 
                       ", expected = " & std_logic'image(test_vectors(i).expected.clk_enable)
                       severity error;
                test_pass := false;
            end if;
            
            if alu_control /= test_vectors(i).expected.alu_control then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": alu_control = " & to_string(alu_control) & 
                       ", expected = " & to_string(test_vectors(i).expected.alu_control)
                       severity error;
                test_pass := false;
            end if;
            
            if branch_type /= test_vectors(i).expected.branch_type then
                report "Error at " & opcode_str & " (" & to_string(opcode) & ")" & 
                       ": branch_type = " & to_string(branch_type) & 
                       ", expected = " & to_string(test_vectors(i).expected.branch_type)
                       severity error;
                test_pass := false;
            end if;
            
            -- Update error count
            if not test_pass then
                error_count <= error_count + 1;
            else
                report "Test passed for: " & opcode_str & " (" & to_string(opcode) & ")" severity note;
            end if;
            
            wait for 10 ns;
        end loop;
        
        -- Test some undefined opcodes
        report "Testing undefined opcodes..." severity note;
        
        -- Test an undefined opcode (e.g., "01010")
        opcode <= "01010";
        wait for 10 ns;
        
        -- Check that all control signals are at safe defaults
        -- You might want to add specific checks for undefined opcodes here
        
        -- Summary
        report "Testbench complete. Total errors: " & integer'image(error_count) severity note;
        
        if error_count = 0 then
            report "All tests passed!" severity note;
        else
            report "Some tests failed!" severity error;
        end if;
        
        wait;
    end process test_process;

end architecture tb_arch;
