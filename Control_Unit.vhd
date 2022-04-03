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
		    ALUOp <= "010";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '1';
        when "001" => -- add immediate
            regDst <= '0';
		    extOp <= '1';
		    ALUSrc <= '1';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "000";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '1';
        when "010" => -- load word (from memory to register)
            regDst <= '0';
		    extOp <= '1';
		    ALUSrc <= '1';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "000";
		    memWrite <= '0';
		    memtoReg <= '1';
		    regWrite <= '1';
        when "011" => -- store word (from register to memory)
            regDst <= 'X';
		    extOp <= '1';
		    ALUSrc <= '1';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "000";
		    memWrite <= '1';
		    memtoReg <= '0';
		    regWrite <= '0';
		when "100" => -- brench on equal
            regDst <= 'X';
		    extOp <= '1';
		    ALUSrc <= '1';
		    branch <= '1';
		    jump <= '0';
		    ALUOp <= "001";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '0';
		when "101" => -- and immediate
            regDst <= '0';
		    extOp <= '1';
		    ALUSrc <= '1';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "011";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '1';
		when "110" => -- load upper immediate
            regDst <= '0';
		    extOp <= '1';
		    ALUSrc <= '1';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "100";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '1';
		when "111" => -- jump
            regDst <= 'X';
		    extOp <= '1';
		    ALUSrc <= '1';
		    branch <= '0';
		    jump <= '1';
		    ALUOp <= "101";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '0';
        when others =>
            regDst <= '0';
		    extOp <= '0';
		    ALUSrc <= '0';
		    branch <= '0';
		    jump <= '0';
		    ALUOp <= "00";
		    memWrite <= '0';
		    memtoReg <= '0';
		    regWrite <= '0';
        end case;
    end process;

end Behavioral;
