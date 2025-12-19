library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file_memory is
    generic( 
        N: integer := 32; 
        M: integer := 1024 
    );
    port(
        clk, rst : in std_logic;
        address, instruction_address  : in std_logic_vector(31 downto 0);
        mem_write, mem_read : in std_logic;
        writedata : in std_logic_vector(N-1 downto 0);
        mem_output : out std_logic_vector(N-1 downto 0);
        memory_busy : out std_logic  
    );
end reg_file_memory;

architecture structure of reg_file_memory is
    type mem_array is array (0 to M-1) of std_logic_vector(N-1 downto 0);
    signal memory : mem_array;
    signal readdata, instruction : std_logic_vector(N-1 downto 0);
    signal internal_memory_busy : std_logic;
begin
    -- Process for memory operations
    process(clk, rst)
        variable access_conflict : boolean;
    begin
        if rst = '1' then
            for i in 0 to M-1 loop
                memory(i) <= (others => '0');
            end loop;
            internal_memory_busy <= '0';
            
        elsif rising_edge(clk) then
            -- Check for memory access conflict
            -- Conflict occurs when both instruction fetch and data access happen
            access_conflict := false;
            
            -- Data memory access requested
            if mem_write = '1' or mem_read = '1' then
                -- Instruction fetch always happens (PC is always reading)
                -- In Von Neumann, both can't access memory simultaneously
                access_conflict := true;
            end if;
            
            if access_conflict then
                internal_memory_busy <= '1';
                -- Priority: data memory access over instruction fetch
                if mem_write = '1' then
                    memory(to_integer(unsigned(address))) <= writedata;
                end if;
                -- If mem_read = '1', readdata will be available next cycle
            else
                internal_memory_busy <= '0';
            end if;
        end if;
    end process;
    
    readdata <= memory(to_integer(unsigned(address))) when mem_read = '1' 
                else (others => '0');
    
    instruction <= memory(to_integer(unsigned(instruction_address)));
    
    -- Output selection
    mem_output <= readdata when mem_read = '1' 
                  else instruction;
    
    memory_busy <= internal_memory_busy;
    
end structure;