library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Instruction_Fetch is
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
end Instruction_Fetch;

architecture Behavioral of Instruction_Fetch is

type rom_memory_type is array(0 to 255) of std_logic_vector(15 downto 0);
signal instruction_mem: rom_memory_type := 
        (B"000_010_011_100_1_000", -- add
         B"000_001_000_100_1_001", -- sub
         B"000_010_011_100_1_010", -- sll
         B"000_010_011_100_1_011", -- srl
         B"000_010_011_100_1_100", -- and
         B"000_010_011_100_1_101", -- or
         B"000_010_011_100_1_110", -- xor
         B"000_010_011_100_1_111", -- addu
         B"001_010_011_000001", -- addi
         B"010_110_100_0000001", -- sw
         B"011_110_111_0000001", -- lw
         B"100_001_000_0000010", -- beq
         B"101_010_011_1001001", -- andi
         B"110_010_011_0000100", -- lui (load upper imediate)
         B"111_0000000000011", -- jmp
         others => x"0000");
         
signal prog_counter: std_logic_vector(15 downto 0);
signal prog_counter_aux: std_logic_vector(15 downto 0);
signal next_address: std_logic_vector(15 downto 0);
signal aux_address: std_logic_vector(15 downto 0);

begin

    process(jump_control)
    begin
        case(jump_control) is
            when '0' => next_address <= aux_address;
            when '1' => next_address <= jump_address;
            when others => next_address <= x"0000";
        end case;
    end process;
    
    process(PCSrc_control)
    begin
        case(PCSrc_control) is
            when '0' => aux_address <= prog_counter_aux;
            when '1' => aux_address <= branch_address;
            when others => aux_address <= x"0000";
        end case;
    end process;

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                prog_counter <= x"0000";
            elsif write_enable = '1' then
                prog_counter <= next_address;
            end if;
        end if;
    end process;

    prog_counter_aux <= prog_counter + '1';
    instruction <= instruction_mem(to_integer(unsigned(prog_counter(7 downto 0))));
    PC <= prog_counter_aux;

end Behavioral;
