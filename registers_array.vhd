LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY register_file_array IS
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
END ENTITY register_file_array;

ARCHITECTURE behavioral OF register_file_array IS
    -- Define register file as a 2D array (7 registers x 12 bits)
    TYPE register_array IS ARRAY (0 TO 6) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL registers : register_array;
    
BEGIN
    -- Register update process (synchronous)
    reg_process: PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            -- Reset all registers to zero
            FOR i IN 0 TO 6 LOOP
                registers(i) <= (OTHERS => '0');
            END LOOP;
        ELSIF rising_edge(clk) THEN
            -- Write port 0
            IF write_en0 = '1' THEN
                CASE write_addr0 IS
                    WHEN "000" => registers(0) <= write_data0;
                    WHEN "001" => registers(1) <= write_data0;
                    WHEN "010" => registers(2) <= write_data0;
                    WHEN "011" => registers(3) <= write_data0;
                    WHEN "100" => registers(4) <= write_data0;
                    WHEN "101" => registers(5) <= write_data0;
                    WHEN "110" => registers(6) <= write_data0;
                    WHEN OTHERS => NULL; -- Invalid address
                END CASE;
            END IF;
            
            -- Write port 1 (with priority - executes second)
            IF write_en1 = '1' THEN
                CASE write_addr1 IS
                    WHEN "000" => registers(0) <= write_data1;
                    WHEN "001" => registers(1) <= write_data1;
                    WHEN "010" => registers(2) <= write_data1;
                    WHEN "011" => registers(3) <= write_data1;
                    WHEN "100" => registers(4) <= write_data1;
                    WHEN "101" => registers(5) <= write_data1;
                    WHEN "110" => registers(6) <= write_data1;
                    WHEN OTHERS => NULL;
                END CASE;
            END IF;
        END IF;
    END PROCESS reg_process;
    
    -- Read process (combinational)
    read_process: PROCESS(read_addr0, read_addr1, registers)
    BEGIN
        -- Read port 0
        CASE read_addr0 IS
            WHEN "000" => read_data0 <= registers(0);
            WHEN "001" => read_data0 <= registers(1);
            WHEN "010" => read_data0 <= registers(2);
            WHEN "011" => read_data0 <= registers(3);
            WHEN "100" => read_data0 <= registers(4);
            WHEN "101" => read_data0 <= registers(5);
            WHEN "110" => read_data0 <= registers(6);
            WHEN OTHERS => read_data0 <= (OTHERS => '0');
        END CASE;
        
        -- Read port 1
        CASE read_addr1 IS
            WHEN "000" => read_data1 <= registers(0);
            WHEN "001" => read_data1 <= registers(1);
            WHEN "010" => read_data1 <= registers(2);
            WHEN "011" => read_data1 <= registers(3);
            WHEN "100" => read_data1 <= registers(4);
            WHEN "101" => read_data1 <= registers(5);
            WHEN "110" => read_data1 <= registers(6);
            WHEN OTHERS => read_data1 <= (OTHERS => '0');
        END CASE;
    END PROCESS read_process;
    
END ARCHITECTURE behavioral;
