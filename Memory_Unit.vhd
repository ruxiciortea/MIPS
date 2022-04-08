library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Memory_Unit is
  Port (clk: in std_logic;
        enable: in std_logic;
        ALURes: in std_logic_vector(15 downto 0); 
        data2: in std_logic_vector(15 downto 0);
        memWrite: in std_logic;
        memData: out std_logic_vector(15 downto 0);
        ALUResOut: out std_logic_vector(15 downto 0)
  );
end Memory_Unit;

architecture Behavioral of Memory_Unit is

signal memAddress: std_logic_vector(7 downto 0);
type ram_type is array (0 to 255) of std_logic_vector (15 downto 0);
signal RAM: ram_type  := (
        x"000A",
        x"000B", 
        x"000C", 
        x"000D", 
        x"000E", 
        x"000F",
        others => x"0000");

begin

    memAddress <= ALURes(7 downto 0);

    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if memWrite = '1' then
                    RAM(to_integer(unsigned(memAddress))) <= data2;
                end if;
            end if;
        end if;
    end process;
    
    memData <= RAM(to_integer(unsigned(memAddress)));
    ALUResOut <= ALURes;

end Behavioral;
