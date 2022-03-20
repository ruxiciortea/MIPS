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

    signal s_counter: std_logic_vector(15 downto 0);
    signal s_counter_enable: std_logic_vector(4 downto 0);
    
    signal ssd_in: std_logic_vector(15 downto 0);
   
    signal branch_addr_signal: std_logic_vector(15 downto 0) := x"0004";
    signal jump_addr_signal: std_logic_vector(15 downto 0) := x"0000";
    signal jump_ctrl_signal: std_logic;
    signal PCSrc_ctrl_signal: std_logic;
    signal instruction_out: std_logic_vector(15 downto 0);
    signal PC_out: std_logic_vector(15 downto 0);
    
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
    
    process(sw(7))
    begin
        case(sw(7)) is
            when '0' => ssd_in <= instruction_out;
            when '1' => ssd_in <= PC_out;
        end case;
    end process;
    
    jump_ctrl_signal <= sw(0);
    PCSrc_ctrl_signal <= sw(1);
    
    led <= sw;

end Behavioral;