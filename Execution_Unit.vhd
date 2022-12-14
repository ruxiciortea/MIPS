library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Execution_Unit is
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
        zero: out std_logic
  );
end Execution_Unit;

architecture Behavioral of Execution_Unit is

signal ALUOperand1: std_logic_vector(15 downto 0);
signal ALUOperand2: std_logic_vector(15 downto 0);
signal ALUControl: std_logic_vector(3 downto 0);
signal ALUResAux: std_logic_vector(15 downto 0);
signal zeroAux: std_logic;

begin

    ALUOperand1 <= data1;
    
    process(ALUSrc)
    begin
        case(ALUSrc) is
            when '0' => ALUOperand2 <= data2;
            when '1' => ALUOperand2 <= extended_immediate;
            when others => ALUOperand2 <= x"0000";
        end case;
    end process;
    
    process(ALUOp, func)
    begin
        case(ALUOp) is
            when "010" => -- R type instruction
                case(func) is
                    when "000" => ALUControl <= "0000"; -- add
                    when "001" => ALUControl <= "0001"; -- sub
                    when "010" => ALUControl <= "0010"; -- sll
                    when "011" => ALUControl <= "0011"; -- slr
                    when "100" => ALUControl <= "0100"; -- and
                    when "101" => ALUControl <= "0101"; -- or
                    when "110" => ALUControl <= "0110"; -- xor
                    when "111" => ALUControl <= "0111"; -- addu
                    when others => ALUControl <= "0000"; -- add
                end case;
            when "000" => ALUControl <= "0000"; -- addi & lw & sw
            when "001" => ALUControl <= "0001"; -- beq
            when "011" => ALUControl <= "0100"; -- andi
            when "100" => ALUControl <= "1000"; -- lui
            when others => ALUControl <= "0000"; -- add
        end case;
    end process;

    ALU: process(ALUControl, ALUOperand1, ALUOperand2, shift_ammount)
    begin
        case(ALUControl) is
            when "0000" => ALUResAux <= ALUOperand1 + ALUOperand2; -- add OR addi
            when "0001" => ALUResAux <= ALUOperand1 - ALUOperand2; -- sub
            when "0010" => -- sll
                case(shift_ammount) is
                    when '1' => ALUResAux <= data1(14 downto 0) & "0";
                    when others => ALUResAux <= data1;
                end case;
            when "0011" => -- slr
                case(shift_ammount) is
                    when '1' => ALUResAux <= "0" & data1(15 downto 1);
                    when others => ALUResAux <= data1;
                end case;
            when "0100" => ALUResAux <= ALUOperand1 and ALUOperand2; -- and OR andi
            when "0101" => ALUResAux <= ALUOperand1 or ALUOperand2; -- or
            when "0110" => ALUResAux <= ALUOperand1 xor ALUOperand2; -- xor
            when "0111" => ALUResAux <= unsigned(ALUOperand1) + unsigned(ALUOperand2); -- addu
            when "1000" => ALUResAux <= ALUOperand2(7 downto 0) & x"00"; -- lui
            when others => ALUResAux <= x"0000";
        end case;
    end process;
    
    process(ALUResAux)
    begin
        case(ALUResAux) is
            when x"0000" => zeroAux <= '1';
            when others => zeroAux <= '0';
        end case;
    end process;
    
    branch_address <= PC + extended_immediate;
    ALURes <= ALUResAux;
    zero <= zeroAux;

end Behavioral;
