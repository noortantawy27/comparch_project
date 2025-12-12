library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- WB itself only cares about signals needed to 
-- 1) write data to the register file
-- 2) input/output ports

-- Need all outputs from the MEM/WB pipeline register
-- alu_q: ALU result to write back in register file
-- memory_q: Memory result to write back in register file
-- memtoreg_q: control signal (memToReg) to select ALU or memory
-- writeaddress1_q: register file address to write into
-- regwrite1_q: enable writing to register file
-- inputport_q: data to write to input port if enabled
-- inputenable_q: enable writing to input port
-- outputenable_q: enable writing to output port


entity writeBack is
    port (
        memData: in std_logic_vector(31 downto 0); -- Memory read
        aluResult: in std_logic_vector(31 downto 0); -- ALU output
        readData1_in: in std_logic_vector(31 downto 0); -- Read data 1
        readData1_out: out std_logic_vector(31 downto 0); -- Read data 1
        readData2_in: in std_logic_vector(31 downto 0); -- Read data 2
        readData2_out: out std_logic_vector(31 downto 0); -- Read data 2
        writeAddress1_in: in std_logic_vector(2 downto 0); -- Write address 1
        writeAddress1_out: out std_logic_vector(2 downto 0); -- Write address 1
        writeAddress2_in: in std_logic_vector(2 downto 0); -- Write address 2
        writeAddress2_out: out std_logic_vector(2 downto 0); -- Write address 2
        memToReg: in std_logic; -- control signal to select memory or ALU
        regWrite1_in: in std_logic; -- control signal for write port 1
        regWrite1_out: out std_logic; -- control signal for write port 1
        regWrite2_in: in std_logic; -- control signal for write port 2
        regWrite2_out: out std_logic; -- control signal for write port 2
        -- memWrite_in: in std_logic; -- control signal for memory write
        -- memWrite_out: out std_logic; -- control signal for memory write

        inputPortData: in std_logic_vector(31 downto 0); -- Input port data
        inputPortEnable: in std_logic; -- Input port enable
        outputPortEnable: in std_logic; -- Output port enable
        outputPort: out std_logic_vector(31 downto 0);

        writeBack_out: out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of writeBack is
begin
    output_port: process
    begin
        if outputPortEnable = '1' then
            outputPort <= readData2_in;
        else
            outputPort <= (others => '0');
        end if ;
    end process;

    write_back: process
    begin
        if regWrite2_in = '1' then
            writeBack_out <= readData2_in;
        elsif inputPortEnable = '1' then
            writeBack_out <= inputPortData;
        elsif memToReg = '1' then
            writeBack_out <= memData;
        else
            writeBack_out <= aluResult;
        end if;
    end process;
end architecture;