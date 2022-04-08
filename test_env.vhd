library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port (clk: in std_logic;
          btn: in std_logic_vector(4 downto 0);
          sw: in std_logic_vector(15 downto 0);
          led: out std_logic_vector(15 downto 0);
          an: out std_logic_vector(3 downto 0);
          cat: out std_logic_vector(6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

    component mono_pulse_gen
        Port (clk: in std_logic;
              btn: in std_logic_vector(4 downto 0);
              enable: out std_logic_vector(4 downto 0)
        );
    end component;
    
    component seven_segment_display is
        Port (clk: in  std_logic;
              digit0: in  std_logic_vector(3 downto 0);
              digit1: in  std_logic_vector(3 downto 0);
              digit2: in  std_logic_vector(3 downto 0);
              digit3: in  std_logic_vector(3 downto 0);
              cat: out std_logic_vector(6 downto 0);
              an: out std_logic_vector(3 downto 0)
        );
    end component;
    
    component Instruction_Fetch is
        Port (clk: in std_logic;
              reset: in std_logic;
              write_enable: in std_logic;
              branch_address: in std_logic_vector(15 downto 0);
              jump_address: in std_logic_vector(15 downto 0);
              jump_control: in std_logic;
              PCSrc_control: in std_logic;
              instruction: out std_logic_vector(15 downto 0);
              PC: out std_logic_vector(15 downto 0)
         );
    end component;
    
    component Instruction_Decode is
        Port (clk: in std_logic;
              instruction: in std_logic_vector(15 downto 0);
              regWrite: in std_logic;
              write_data: in std_logic_vector(15 downto 0);
              regDst: in std_logic;
              extOp: in std_logic;
              data1: out std_logic_vector(15 downto 0);
              data2: out std_logic_vector(15 downto 0);
              extended_immediate: out std_logic_vector(15 downto 0);
              func: out std_logic_vector(2 downto 0);
              shift_ammount: out std_logic
        );
    end component;
    
    component Control_Unit is
        Port (instruction:in std_logic_vector(2 downto 0);
		      regDst: out std_logic;
		      extOp: out std_logic;
		      ALUSrc: out std_logic;
		      branch: out std_logic;
		      jump: out std_logic;
		      ALUOp: out std_logic_vector(2 downto 0);
		      memWrite: out std_logic;
		      memtoReg: out std_logic;
		      regWrite: out std_logic);
    end component;
    
    component Execution_Unit is
        Port (PC: in std_logic_vector(15 downto 0);
              data1: in std_logic_vector(15 downto 0);
              data2: in std_logic_vector(15 downto 0);
              extended_immediate: in std_logic_vector(15 downto 0);
              func: in std_logic_vector(2 downto 0);
              shift_ammount: in std_logic;
              ALUSrc: in std_logic;
              ALUOp: in std_logic_vector(2 downto 0);
              branch_address: out std_logic_vector(15 downto 0);
              ALURes: out std_logic_vector(15 downto 0);
              zero: out std_logic);
    end component;
    
    component Memory_Unit is
        Port (clk: in std_logic;
              enable: in std_logic;
              ALURes: in std_logic_vector(15 downto 0); 
              data2: in std_logic_vector(15 downto 0);
              memWrite: in std_logic;
              memData: out std_logic_vector(15 downto 0);
              ALUResOut: out std_logic_vector(15 downto 0)
        );
    end component;

    signal s_counter: std_logic_vector(15 downto 0);
    signal s_counter_enable: std_logic_vector(4 downto 0);
    
    signal ssd_in: std_logic_vector(15 downto 0);
   
    -- instruction fetch unit signals
    signal branch_addr_signal: std_logic_vector(15 downto 0) := x"0004";
    signal jump_addr_signal: std_logic_vector(15 downto 0) := x"0000";
    signal jump_ctrl_signal: std_logic;
    signal PCSrc_ctrl_signal: std_logic;
    signal instruction_out: std_logic_vector(15 downto 0);
    signal PC_out: std_logic_vector(15 downto 0);
    
    -- instruction decode unit signals
    signal data1_out: std_logic_vector(15 downto 0);
    signal data2_out: std_logic_vector(15 downto 0);
    signal ext_imm_signal: std_logic_vector(15 downto 0);
    signal func_signal: std_logic_vector(2 downto 0);
    signal shift_ammount_signal: std_logic;
    signal register_write_data: std_logic_vector(15 downto 0);
    
    -- control unit signals
    signal regDst_signal: std_logic;
    signal extOp_signal: std_logic;
    signal ALUSrc_signal: std_logic;
    signal branch_signal: std_logic;
    signal jump_signal: std_logic;
    signal ALUOp_signal: std_logic_vector(2 downto 0);
    signal memWrite_signal: std_logic;
    signal memtoReg_signal: std_logic;
    signal regWrite_signal: std_logic;
    
    -- execution unit signals
    signal zero_detector_signal: std_logic;
    signal ALURes: std_logic_vector(15 downto 0);
    signal mem_data_out: std_logic_vector(15 downto 0);
    signal ALURes_out: std_logic_vector(15 downto 0);
    
begin

    mpg: mono_pulse_gen port map
        (clk => clk,
         btn => btn,
         enable => s_counter_enable);
        
    ssd: seven_segment_display port map 
        (clk => clk, 
         digit0 => ssd_in(15 downto 12), 
         digit1 => ssd_in(11 downto 8),
         digit2 => ssd_in(7 downto 4),
         digit3 => ssd_in(3 downto 0),
         cat => cat,
         an => an);
              
    I_F: Instruction_Fetch port map
        (clk => clk,
         reset => s_counter_enable(0),
         write_enable => s_counter_enable(1),
         branch_address => branch_addr_signal,
         jump_address => jump_addr_signal,
         jump_control => jump_ctrl_signal,
         PCSrc_control => PCSrc_ctrl_signal,
         instruction => instruction_out,
         PC => PC_out);                 
    
    I_D: Instruction_Decode port map
        (clk => clk,
         instruction => instruction_out,
         regWrite => regWrite_signal,
         write_data => register_write_data,
         regDst => regDst_signal,
         extOp => extOp_signal,
         data1 => data1_out,
         data2 => data2_out,
         extended_immediate => ext_imm_signal,
         func => func_signal,
         shift_ammount => shift_ammount_signal);

    ctrl_unit: Control_Unit port map
        (instruction => instruction_out(15 downto 13),
		 regDst => regDst_signal,
		 extOp => extOp_signal,
		 ALUSrc => ALUSrc_signal,
		 branch => branch_signal,
		 jump => jump_signal,
		 ALUOp => ALUOp_signal,
		 memWrite => memWrite_signal,
		 memtoReg => memtoReg_signal,
		 regWrite => regWrite_signal);
		 
    exec_unit: Execution_Unit port map
        (PC => PC_out,
         data1 => data1_out,
         data2 => data2_out,
         extended_immediate => ext_imm_signal,
         func => func_signal,
         shift_ammount => shift_ammount_signal,
         ALUSrc => ALUSrc_signal,
         ALUOp => ALUOp_signal,
         branch_address => branch_addr_signal,
         ALURes => ALURes,
         zero => zero_detector_signal);
         
    memory: Memory_Unit port map
        (clk => clk,
         enable => s_counter_enable(1),
         ALURes => ALURes,
         data2 => data2_out,
         memWrite => memWrite_signal,
         memData => mem_data_out,
         ALUResOut => ALURes_out);
         
    process(memtoReg_signal)
    begin
        case(memtoReg_signal) is
            when '0' => register_write_data <= ALURes;
            when '1' => register_write_data <= mem_data_out;
            when others => register_write_data <= x"0000";
        end case;
    end process;  
    
    process(sw(7 downto 5), instruction_out, PC_out, ext_imm_signal)
    begin
        case(sw(7 downto 5)) is
            when "000" => ssd_in <= instruction_out;
            when "001" => ssd_in <= PC_out;
            when "010" => ssd_in <= data1_out;
            when "011" => ssd_in <= data2_out;
            when "100" => ssd_in <= ext_imm_signal;
            when "101" => ssd_in <= ALURes;
            when "110" => ssd_in <= mem_data_out;
            when others => ssd_in <= x"0000";
        end case;
    end process;
    
    -- instruction fetch
    jump_ctrl_signal <= sw(0);
    PCSrc_ctrl_signal <= sw(1);
    
    process(sw(0))
    begin
        if (sw(0) = '0') then
           led(7) <= regDst_signal;
           led(6) <= extOp_signal;
           led(5) <= ALUSrc_signal;
           led(4) <= branch_signal;
           led(3) <= jump_signal;
           led(2) <= memWrite_signal;
           led(1) <= memtoReg_signal;
           led(0) <= regWrite_signal;
	    else
	       led(2) <= ALUOp_signal(2);
	       led(1) <= ALUOp_signal(1);
	       led(0) <= ALUOp_signal(0);
	       led(15 downto 3) <= "0000000000000";
	    end if;
    end process;

end Behavioral;