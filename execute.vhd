library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity execute is 
    port(
        clk,rst :in std_logic; 
        --output of register id/ex
        immediate_q: in std_logic_vector(31 downto 0);
        pc1_q: in std_logic_vector(31 downto 0);
        inputport_q:in std_logic_vector(31 downto 0);
        readdata1_q:in std_logic_vector(31 downto 0);
        readdata2_q:in std_logic_vector(31 downto 0);
        writeaddress1_q:in std_logic_vector(2 downto 0);
        writeaddress2_q:in std_logic_vector(2 downto 0);
        memtoreg_q: in std_logic;
        outputenable_q: in std_logic;
        regwrite1_q: in std_logic;
        regwrite2_q: in std_logic;
        inputenable_q:in std_logic;
        memwrite_q:in std_logic;
        memread_q:in std_logic;
        mem_add_src_q: in std_logic;
        mem_data_src_q: in std_logic;
        sp_dec_q: in std_logic; --meen da??? ha pass it for now then nebaa neshouf
        pc_src_q: in std_logic;
        alu_control_q: in std_logic_vector(2 downto 0);
        alu_src_q: in std_logic;
        branch_q: in std_logic;
        branch_type_q: in std_logic_vector(1 downto 0);
        inc_sp_q: in std_logic;
        set_carry_q: in std_logic;
        ccr_store_q: in std_logic;
        ccr_restore_q: in std_logic;
        flag_enable_q: in std_logic;
        --outputs of mem el  2 lines ely dakhleen lel sp men odam
        exmem_sp: in std_logic_vector(31 downto 0);
        exmem_decsp: in std_logic;
        --inputs of ex/mem
       
        sp_d: out std_logic_vector(31 downto 0);
        pc1_d: out std_logic_vector(31 downto 0);
        alu_d:out std_logic_vector(31 downto 0);
        inputport_d:out std_logic_vector(31 downto 0);
        readdata1_d:out std_logic_vector(31 downto 0);
        readdata2_d:out std_logic_vector(31 downto 0);
        writeaddress1_d: out std_logic_vector(2 downto 0);
        writeaddress2_d: out std_logic_vector(2 downto 0);
        memtoreg_d:out std_logic;
        outputenable_d:out std_logic;
        regwrite1_d:out std_logic;
        regwrite2_d:out std_logic;
        inputenable_d:out std_logic;
        memwrite_d:out std_logic;
        memread_d:out std_logic;
        mem_add_src_d: out std_logic;
        mem_data_src_d: out std_logic;
        sp_dec_d: out std_logic; 
        pc_src_d: out std_logic;

        --adder ely fo2
        pc_plus1_plus_sign_extend: out std_logic_vector(31 downto 0);

        --branch 
        do_branch: out std_logic;
        ---- forwarding input from the register------
        rs_q: in std_logic_vector(2 downto 0);
        rt_q: in std_logic_vector(2 downto 0);

        -------- info form ex/mem ------------------ --- forward from alu--
        ex_mem_regwrite1: in std_logic;
        ex_mem_regwrite2: in std_logic;
        ex_mem_writeaddress1:in std_logic_vector(2 downto 0);
        ex_mem_writeaddress2: in std_logic_vector(2 downto 0);
        ex_mem_alu_output: in std_logic_vector(31 downto 0);
        ex_mem_readdata1: in std_logic_vector(31 downto 0);
        ex_mem_readdata2: in std_logic_vector(31 downto 0);
        ex_mem_inputport, ex_mem_memory_readdate: in std_logic_vector(31 downto 0);
        ex_mem_memtoreg,ex_mem_input_enable: in std_logic;
        -------- info from mem/wb ------------------- -- full forward---
        mem_wb_regwrite1: in std_logic;
        mem_wb_regwrite2: in std_logic;
        mem_wb_writeaddress1: in std_logic_vector(2 downto 0);
        mem_wb_writeaddress2:in std_logic_vector(2 downto 0);
        mem_wb_writedata: in std_logic_vector(31 downto 0);
        mem_wb_readdata1:in std_logic_vector(31 downto 0);
        ---------------------------------------------
        id_ex_interrupt_signal: in std_logic;
        ex_mem_interrupt_signal: out std_logic
        );

end execute;

architecture exec of execute is
    signal alu_result: std_logic_vector(31 downto 0);
    signal alu_cin: std_logic;
    signal alu_zero_flag, alu_negative_flag, alu_carry_flag: std_logic;
    signal carry: std_logic;
    -- ALU inputs
    signal alu_a, alu_b: std_logic_vector(31 downto 0);
    
    -- CCR signals
    signal Z_reg, N_reg, C_reg: std_logic;
    signal ccr_z, ccr_n, ccr_c: std_logic;
    signal input_c_ccr, input_z_ccr, input_n_ccr: std_logic;
    -- Branch calculation
    
    signal branchtype: std_logic;
    signal branch_target: std_logic_vector(31 downto 0);

    -- output of sp
    signal sp_q: std_logic_vector(31 downto 0);
    signal sp_d_temp: std_logic_vector(31 downto 0);
    signal sp_inc_amount: std_logic_vector(31 downto 0);
    
    -- ALU signals
    signal alu_cin_signal: std_logic;

    ---- forward control-------
    signal forwardA,forwardB: std_logic_vector(2 downto 0);
    ---- forwarded operands----
    signal alu_srcA,alu_srcB: std_logic_vector(31 downto 0);

    --instatniate ccr - Based on CCR.vhd file
    component CCR is
        Port (
            clk: in std_logic;
            rst: in std_logic;
            flag_enable: in std_logic;
            alu_Z: in std_logic;
            alu_N: in std_logic;
            alu_C: in std_logic;
            Z: out std_logic;
            N: out std_logic;
            C: out std_logic
        );
    end component;
    
    --intsantiate alu - Based on ALU.vhd file
    component alu is
        generic (N : integer);
        port (
            A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            S : in std_logic_vector(2 downto 0);
            Cin : in std_logic;
            F : out std_logic_vector(N-1 downto 0);
            zero_flag: out std_logic;
            negative_flag: out std_logic;
            Cout : out std_logic
        );
    end component;
    
    --instantiate register sp - Based on sp.vhd file
    component sp is
        generic (n: integer := 32);
        port(
            Rst, Clk: in std_logic;
            d: in std_logic_vector(n-1 downto 0);
            q: out std_logic_vector(n-1 downto 0)
        );
    end component;

    signal ex_mem_en1,ex_mem_en2,mem_wb_en1,mem_wb_en2 : std_logic;
    signal ex_mem_waddress1,ex_mem_waddress2,mem_wb_waddress1,mem_wb_waddress2 : std_logic_vector(2 downto 0);
    signal ex_mem_output : std_logic_vector(31 downto 0);

    signal readdata1_output, readdata2_output : std_logic_vector(31 downto 0);
begin
    -- Instantiate CCR unit for main flags
    ccr_main: CCR
        port map (
            clk => clk,
            rst => rst,
            flag_enable => flag_enable_q,
            alu_Z => input_z_ccr,
            alu_N => input_n_ccr,
            alu_C => input_c_ccr,
            Z => Z_reg,
            N => N_reg,
            C => C_reg
        );

    -- Instantiate CCR unit for storing flags (backup copy)
    ccr_store: CCR
        port map (
            clk => clk,
            rst => rst,
            flag_enable => ccr_store_q,
            alu_Z => Z_reg,  -- Store from main CCR
            alu_N => N_reg,
            alu_C => C_reg,
            Z => ccr_z,
            N => ccr_n,
            C => ccr_c
        );
    -------------- process of forwarding-----------

    ex_mem_en1<=ex_mem_regwrite1 or ex_mem_regwrite2;
    ex_mem_en2<=ex_mem_regwrite1 and ex_mem_regwrite2;

    ex_mem_waddress1<= ex_mem_writeaddress2 when ex_mem_regwrite1='1' and ex_mem_regwrite2='1'
    else ex_mem_writeaddress1;
    ex_mem_waddress2<= ex_mem_writeaddress1 when ex_mem_regwrite1='1' and ex_mem_regwrite2='1'
    else ex_mem_writeaddress2;

    mem_wb_en1<=mem_wb_regwrite1 or mem_wb_regwrite2;
    mem_wb_en2<=mem_wb_regwrite1 and mem_wb_regwrite2;

    mem_wb_waddress1<= mem_wb_writeaddress2 when mem_wb_regwrite1='1' and mem_wb_regwrite2='1'
    else mem_wb_writeaddress1;
    mem_wb_waddress2<= mem_wb_writeaddress1 when mem_wb_regwrite1='1' and mem_wb_regwrite2='1'
    else mem_wb_writeaddress2;

    ex_mem_output <= ex_mem_readdata2 when ex_mem_regwrite2 = '1'
    else ex_mem_inputport when ex_mem_input_enable = '1'
    else ex_mem_memory_readdate when ex_mem_memtoreg = '1'
    else ex_mem_alu_output;

    process (rs_q,rt_q,ex_mem_en1,ex_mem_en2,ex_mem_waddress1,ex_mem_waddress2,mem_wb_en1,mem_wb_en2,mem_wb_waddress1,mem_wb_waddress2)
    begin
        -- default----------
        forwardA<="000";
        forwardB<="000";
        -- OperandA---------
        if ex_mem_en1='1' and ex_mem_waddress1=rs_q then
            forwardA<="001";
        elsif ex_mem_en2= '1' and ex_mem_waddress2=rs_q then
            forwardA<="011";
        elsif mem_wb_en1='1' and mem_wb_waddress1=rs_q then
            forwardA<="010";
        elsif mem_wb_en2='1' and mem_wb_waddress2=rs_q then 
            forwardA<="100";
        end if;
        -- operandB------------
        if ex_mem_en1='1' and ex_mem_waddress1=rt_q then
            forwardB<="001";
        elsif ex_mem_en2= '1' and ex_mem_waddress2=rt_q then
            forwardB<="011";
        elsif mem_wb_en1='1' and mem_wb_waddress1=rt_q then
            forwardB<="010";
        elsif mem_wb_en2='1' and mem_wb_waddress2=rt_q then 
            forwardB<="100";
        end if;
    end process;
    -------------- alu operands-----------------------
    with forwardA select 
        alu_srcA<= 
            readdata1_q when "000",
            ex_mem_output when "001",
            mem_wb_writedata when "010",
            ex_mem_readdata1 when "011",
            mem_wb_readdata1 when "100",
            readdata1_q when others;
    with forwardB select
        alu_srcB<= 
            readdata2_q when "000",
            ex_mem_output when "001",
            mem_wb_writedata when "010",
            ex_mem_readdata1 when "011",
            mem_wb_readdata1 when "100",
            readdata2_q when others;

    with forwardA select 
        readdata1_output<= 
            readdata1_q when "000",
            ex_mem_output when "001",
            mem_wb_writedata when "010",
            ex_mem_readdata1 when "011",
            mem_wb_readdata1 when "100",
            readdata1_q when others;
    with forwardB select
        readdata2_output<= 
            readdata2_q when "000",
            ex_mem_output when "001",
            mem_wb_writedata when "010",
            ex_mem_readdata1 when "011",
            mem_wb_readdata1 when "100",
            readdata2_q when others;
    
    --alusrc da elmafrood beyekhtar ya ben add data readdata2 or immediate value(gay men sign extend)
    -- ALU A input: always readdata1_q
    alu_a <= alu_srcA;
    
    -- ALU B input: MUX between readdata2_q and immediate_q
    alu_b <= alu_srcB when alu_src_q = '1' else immediate_q;
    -- Instantiate ALU unit
    alu_inst: alu
        generic map (N => 32)
        port map (
            A => alu_a,
            B => alu_b,
            S => alu_control_q,
            Cin => alu_cin_signal,
            F => alu_result,
            zero_flag => alu_zero_flag,
            negative_flag => alu_negative_flag,
            Cout => alu_carry_flag
        );

    -- Instantiate SP register
    sp_inst: sp
        generic map (n => 32)
        port map (
            Clk => clk,
            Rst => rst,
            d => sp_d_temp,
            q => sp_q
        );

    -- --alusrc da elmafrood beyekhtar ya ben add data readdata2 or immediate value(gay men sign extend)
    -- -- ALU A input: always readdata1_q
    -- alu_a <= readdata1_q;
    
    -- -- ALU B input: MUX between readdata2_q and immediate_q
    -- alu_b <= readdata2_q when alu_src_q = '1' else immediate_q;
    
    -- Calculate branch target: PC + 1 + sign-extended immediate
    branch_target <= std_logic_vector(unsigned(pc1_q) + unsigned(immediate_q));
    pc_plus1_plus_sign_extend <= immediate_q;

    --ccr store
    --akeno ccr atany bi mux ya2ema yakhod haget alu ya2ema yakhod ccr elmawgood
    --restore--> set signal lel hagat beta3t ccr
    --else store --> haget alu 3ady
    carry <= '1' when set_carry_q ='1' else alu_carry_flag;
   
    -- Process for CCR mux selection
    process(ccr_restore_q, alu_zero_flag, carry, alu_negative_flag, ccr_z, ccr_c, ccr_n)
    begin
        if ccr_restore_q = '1' then --outputs of store
            input_z_ccr <= ccr_z;
            input_c_ccr <= ccr_c; 
            input_n_ccr <= ccr_n;
        else --haget alu
            input_z_ccr <= alu_zero_flag;
            input_c_ccr <= carry;
            input_n_ccr <= alu_negative_flag;
        end if;
    end process;

    -- ALU Cin selection
    alu_cin_signal <= C_reg;

    --do branch
    process(branch_type_q, carry, Z_reg, N_reg)
    begin
        if branch_type_q = "00" then
            branchtype <= '1';
        elsif branch_type_q = "11" then
            branchtype <= carry;
        elsif branch_type_q = "01" then
            branchtype <= Z_reg;
        elsif branch_type_q = "10" then
            branchtype <= N_reg;
        else
            branchtype <= '0';
        end if;
    end process;
    
    --law bi zero ben3ady 1
    --law heya bi 10
    --law heya 01 zero
    --ben and el brancht with branch control signal
    do_branch <= branchtype and branch_q;
    
    --sp
    sp_inc_amount <= std_logic_vector(unsigned(sp_q) + 1) when inc_sp_q = '1' else sp_q;
    sp_d_temp <= std_logic_vector(unsigned(exmem_sp) - 1) when exmem_decsp = '1' else sp_inc_amount;
    sp_d <= sp_d_temp;
    
    --el4 lines ely taht 
    readdata1_d <= readdata1_output;
    readdata2_d <= readdata2_output;
    writeaddress1_d <= writeaddress1_q;
    writeaddress2_d <= writeaddress2_q;
    inputport_d <= inputport_q;
    
    --hagat not used
    memtoreg_d <= memtoreg_q;
    outputenable_d <= outputenable_q;
    regwrite1_d <= regwrite1_q;
    regwrite2_d <= regwrite2_q;
    inputenable_d <= inputenable_q;
    memwrite_d <= memwrite_q;
    memread_d <= memread_q;
    mem_add_src_d <= mem_add_src_q;
    mem_data_src_d <= mem_data_src_q;
    sp_dec_d <= sp_dec_q;
    pc_src_d <= pc_src_q;
    
    -- Pass through signals
    pc1_d <= pc1_q;
    alu_d <= alu_result;
    
    --pass interrupt signal
    ex_mem_interrupt_signal <= id_ex_interrupt_signal;

end exec;