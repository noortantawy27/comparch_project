LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.STOP;

ENTITY tb_array IS
END ENTITY tb_array;

ARCHITECTURE tb_imp_array OF tb_array IS

    -- Add the array component
    COMPONENT register_file_array IS
        PORT (
            clk          : IN STD_LOGIC;
            rst          : IN STD_LOGIC;
            read_addr0   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            read_addr1   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_addr0  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_addr1  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            write_data0  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            write_data1  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            write_en0    : IN STD_LOGIC;
            write_en1    : IN STD_LOGIC;
            read_data0   : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            read_data1   : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk, rst, write_en0, write_en1 : STD_LOGIC := '0';
    SIGNAL read_addr0, read_addr1, write_addr0, write_addr1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL write_data0, write_data1 : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
   
    
    -- Add signals for array implementation
    SIGNAL read_data0_array, read_data1_array : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN

    -- Add the array implementation
    uut_array: register_file_array
        PORT MAP (
            clk => clk,
            rst => rst,
            read_addr0 => read_addr0,
            read_addr1 => read_addr1,
            write_addr0 => write_addr0,
            write_addr1 => write_addr1,
            write_data0 => write_data0,
            write_data1 => write_data1,
            write_en0 => write_en0,
            write_en1 => write_en1,
            read_data0 => read_data0_array,
            read_data1 => read_data1_array
        );

    clk_process: PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR 50 ns;
            clk <= '1';
            WAIT FOR 50 ns;
        END LOOP;
    END PROCESS clk_process;

    tests: PROCESS
    BEGIN
        -- rst <= '0'; 
        -- Cycle 1: Reset all registers
        rst <= '1';
        read_addr0 <= (OTHERS => '0');
        read_addr1 <= (OTHERS => '0');
        write_addr0 <= (OTHERS => '0');
        write_addr1 <= (OTHERS => '0');
        write_en0 <= '0';
        write_en1 <= '0';
        WAIT UNTIL falling_edge(clk);
        
        rst <= '0';
        
        -- Cycle 2: Read Reg(0) on port 0, Read Reg(1) on port 1, 
        -- Write 0x0F0 to Reg(0), Write 0xAAA to Reg(3)
        write_en0 <= '1';
        write_en1 <= '1';
        write_addr1 <= "011";  -- Write to Reg(3)
        write_data1 <= x"AAA";
        write_addr0 <= "000";  -- Write to Reg(0)
        write_data0 <= x"0F0";
        WAIT UNTIL rising_edge(clk);
        read_addr0 <= "000";   -- Read Reg(0)
        read_addr1 <= "001";   -- Read Reg(1)
        WAIT UNTIL rising_edge(clk);

        -- Cycle 3: Read Reg(4) on port 0, Read Reg(3) on port 1,
        -- Write 0x123 to Reg(6), Write 0xCCC to Reg(1)
        read_addr0 <= "100";   -- Read Reg(4)
        read_addr1 <= "011";   -- Read Reg(3)
        write_addr0 <= "110";  -- Write to Reg(6)
        write_data0 <= x"123";
        write_addr1 <= "001";  -- Write to Reg(1)
        write_data1 <= x"CCC";
        WAIT UNTIL rising_edge(clk);

        -- Cycle 4: Read Reg(1) on port 0, Read Reg(6) on port 1,
        -- Write 0x456 to Reg(4), Don't write on 2nd port
        read_addr0 <= "001";   -- Read Reg(1)
        read_addr1 <= "110";   -- Read Reg(6)
        write_addr0 <= "100";  -- Write to Reg(4)
        write_data0 <= x"456";
        write_en1 <= '0';      -- Don't write on 2nd port
        WAIT UNTIL rising_edge(clk);

        -- Cycle 5: Read Reg(6) on port 0, Read Reg(0) on port 1,
        -- Don't write on 1st port, Write 0x789 to Reg(1)
        read_addr0 <= "110";   -- Read Reg(6)
        read_addr1 <= "000";   -- Read Reg(0)
        write_en0 <= '0';      -- Don't write on 1st port
        write_en1 <= '1';      -- Enable 2nd port
        write_addr1 <= "001";  -- Write to Reg(1)
        write_data1 <= x"789";
        WAIT UNTIL rising_edge(clk);

        -- Cycle 6: Read Reg(1) on port 0, Read Reg(2) on port 1,
        -- Don't write anything
        read_addr0 <= "001";   -- Read Reg(1)
        read_addr1 <= "010";   -- Read Reg(2)
        write_en0 <= '0';
        write_en1 <= '0';
        WAIT UNTIL rising_edge(clk);

        -- Cycle 7: Read Reg(3) on port 0, Read Reg(4) on port 1,
        -- Don't write anything
        read_addr0 <= "011";   -- Read Reg(3)
        read_addr1 <= "100";   -- Read Reg(4)
        WAIT UNTIL rising_edge(clk);

        STOP;
    END PROCESS tests;

END ARCHITECTURE tb_imp_array;
