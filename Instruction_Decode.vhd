library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Instruction_Decode is
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
end Instruction_Decode;

architecture Behavioral of Instruction_Decode is

    component Register_File is
        Port (clk: in std_logic;
              read_address1: in std_logic_vector(2 downto 0);
              read_address2: in std_logic_vector(2 downto 0);
              write_enable: in std_logic;
              write_address: in std_logic_vector(2 downto 0);
              write_data: in std_logic_vector(15 downto 0);
              read_data1: out std_logic_vector(15 downto 0);
              read_data2: out std_logic_vector(15 downto 0) 
        );
    end component;

    signal write_address_signal: std_logic_vector(2 downto 0);
    signal ext_imm_signal: std_logic_vector(15 downto 0);
    signal data1_signal: std_logic_vector(15 downto 0);
    signal data2_signal: std_logic_vector(15 downto 0);
    
begin

    register_map: Register_File port map 
        (clk => clk, 
         read_address1 => instruction(12 downto 10),
         read_address2 => instruction(9 downto 7),
         write_enable => regWrite,
         write_address => write_address_signal,
         write_data => write_data,
         read_data1 => data1_signal, 
         read_data2 => data2_signal);

    process(regDst, instruction)
    begin
        case(regDst) is
            when '0' => write_address_signal <= instruction(9 downto 7);
            when '1' => write_address_signal <= instruction(6 downto 4);
            when others => write_address_signal <= "000";
        end case;
    end process;
    
    process(extOp, instruction)
    begin
        case(extOp) is
            when '0' => ext_imm_signal <= B"000000000" &instruction(6 downto 0);
            when '1' =>
                case(instruction(6)) is
                    when '0' => ext_imm_signal <= B"000000000" &instruction(6 downto 0);
                    when '1' => ext_imm_signal <= B"111111111" & instruction(6 downto 0);
                    when others => ext_imm_signal <= x"0000";
                end case;
            when others => ext_imm_signal <= x"0000";
        end case;
    end process;

    extended_immediate <= ext_imm_signal;
    func <= instruction(2 downto 0);
    shift_ammount <= instruction(3);
    data1 <= data1_signal;
    data2 <= data2_signal;

end Behavioral;
