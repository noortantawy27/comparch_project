LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY register_file IS
    PORT (
        clk      : IN STD_LOGIC;
        rst      : IN STD_LOGIC;
        
        -- (3 bits --> 7 registers)
        read_addr0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_addr1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_addr0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_addr1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        -- data (12 bits each)
        write_data0 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        write_data1 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        
        write_en0   : IN STD_LOGIC;
        write_en1   : IN STD_LOGIC;
       
        read_data0  : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        read_data1  : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END ENTITY register_file;

ARCHITECTURE structural OF register_file IS
    
    COMPONENT my_nDFF IS
        GENERIC (n : INTEGER := 12);
        PORT (
            Clk, Rst : IN STD_LOGIC;
            d        : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            q        : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
        );
    END COMPONENT;
    
    SIGNAL reg0, reg1, reg2, reg3, reg4, reg5, reg6 : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL reg0_in, reg1_in, reg2_in, reg3_in, reg4_in, reg5_in, reg6_in : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
BEGIN
    
    -- 7 registers (DFFs)
    reg_0: my_nDFF GENERIC MAP (n => 12) PORT MAP (Clk => clk, Rst => rst, d => reg0_in, q => reg0);
    reg_1: my_nDFF GENERIC MAP (n => 12) PORT MAP (Clk => clk, Rst => rst, d => reg1_in, q => reg1);
    reg_2: my_nDFF GENERIC MAP (n => 12) PORT MAP (Clk => clk, Rst => rst, d => reg2_in, q => reg2);
    reg_3: my_nDFF GENERIC MAP (n => 12) PORT MAP (Clk => clk, Rst => rst, d => reg3_in, q => reg3);
    reg_4: my_nDFF GENERIC MAP (n => 12) PORT MAP (Clk => clk, Rst => rst, d => reg4_in, q => reg4);
    reg_5: my_nDFF GENERIC MAP (n => 12) PORT MAP (Clk => clk, Rst => rst, d => reg5_in, q => reg5);
    reg_6: my_nDFF GENERIC MAP (n => 12) PORT MAP (Clk => clk, Rst => rst, d => reg6_in, q => reg6);
    
    WRITE_PROC : PROCESS (write_addr0, write_addr1, write_data0, write_data1, write_en0, write_en1,
                         reg0, reg1, reg2, reg3, reg4, reg5, reg6)
    BEGIN
        -- Default: maintain current value (no write)
        reg0_in <= reg0;
        reg1_in <= reg1;
        reg2_in <= reg2;
        reg3_in <= reg3;
        reg4_in <= reg4;
        reg5_in <= reg5;
        reg6_in <= reg6;
        
        -- Write port 1 has HIGHER priority
        IF write_en1 = '1' THEN
            CASE write_addr1 IS
                WHEN "000" => reg0_in <= write_data1;
                WHEN "001" => reg1_in <= write_data1;
                WHEN "010" => reg2_in <= write_data1;
                WHEN "011" => reg3_in <= write_data1;
                WHEN "100" => reg4_in <= write_data1;
                WHEN "101" => reg5_in <= write_data1;
                WHEN "110" => reg6_in <= write_data1;
                WHEN OTHERS => NULL;
            END CASE;
        END IF;
        
        IF write_en0 = '1' THEN
            CASE write_addr0 IS
                WHEN "000" => reg0_in <= write_data0;
                WHEN "001" => reg1_in <= write_data0;
                WHEN "010" => reg2_in <= write_data0;
                WHEN "011" => reg3_in <= write_data0;
                WHEN "100" => reg4_in <= write_data0;
                WHEN "101" => reg5_in <= write_data0;
                WHEN "110" => reg6_in <= write_data0;
                WHEN OTHERS => NULL;
            END CASE;
        END IF;
    END PROCESS WRITE_PROC;
    
    READ_PROC : PROCESS (read_addr0, read_addr1, reg0, reg1, reg2, reg3, reg4, reg5, reg6)
    BEGIN
        CASE read_addr0 IS
            WHEN "000" => read_data0 <= reg0;
            WHEN "001" => read_data0 <= reg1;
            WHEN "010" => read_data0 <= reg2;
            WHEN "011" => read_data0 <= reg3;
            WHEN "100" => read_data0 <= reg4;
            WHEN "101" => read_data0 <= reg5;
            WHEN "110" => read_data0 <= reg6;
            WHEN OTHERS => read_data0 <= (OTHERS => '0');
        END CASE;
        
        CASE read_addr1 IS
            WHEN "000" => read_data1 <= reg0;
            WHEN "001" => read_data1 <= reg1;
            WHEN "010" => read_data1 <= reg2;
            WHEN "011" => read_data1 <= reg3;
            WHEN "100" => read_data1 <= reg4;
            WHEN "101" => read_data1 <= reg5;
            WHEN "110" => read_data1 <= reg6;
            WHEN OTHERS => read_data1 <= (OTHERS => '0');
        END CASE;
    END PROCESS READ_PROC;
    
END ARCHITECTURE structural;

