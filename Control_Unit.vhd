library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control_Unit is
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
end Control_Unit;

architecture Behavioral of Control_Unit is

begin

    process(instruction)
    begin
        case(instruction) is
        when "000" => -- R type instruction
            regDst <= '1';
		    extOp <= '0';
		    ALUSrc <= '0';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "000";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '1';
        when "001" => -- add immediate
            regDst <= '0';
		    extOp <= '0';
		    ALUSrc <= '0';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "000";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '1';
        when "010" => -- load word
            regDst <= '0';
		    extOp <= '1';
		    ALUSrc <= '0';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "000";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '1';
        when others =>
            regDst <= '0';
		    extOp <= '0';
		    ALUSrc <= '0';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "000";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '0';
        end case;
    end process;

end Behavioral;
