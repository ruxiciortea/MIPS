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
    signal write_data_signal: std_logic_vector(15 downto 0);
    signal ext_imm_signal: std_logic_vector(15 downto 0);
    signal func_signal: std_logic_vector(2 downto 0);
    signal shift_ammount_signal: std_logic;
    
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
         write_data => write_data_signal,
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
    
    process(sw(7 downto 5))
    begin
        case(sw(7 downto 5)) is
            when "000" => ssd_in <= instruction_out;
            when "001" => ssd_in <= PC_out;
            when "010" => ssd_in <= data1_out;
            when "011" => ssd_in <= data2_out;
            when "100" => ssd_in <= write_data_signal;
            when others => ssd_in <= x"0000";
        end case;
    end process;
    
    -- instruction fetch
    jump_ctrl_signal <= sw(0);
    PCSrc_ctrl_signal <= sw(1);
    
    -- instruction decode
    write_data_signal <= data1_out + data2_out;
    
    led <= sw;

end Behavioral;