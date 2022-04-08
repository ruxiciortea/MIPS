library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Register_File is
  Port (clk: in std_logic;
        read_address1: in std_logic_vector(2 downto 0);
        read_address2: in std_logic_vector(2 downto 0);
        write_enable: in std_logic;
        write_address: in std_logic_vector(2 downto 0);
        write_data: in std_logic_vector(15 downto 0);
        read_data1: out std_logic_vector(15 downto 0);
        read_data2: out std_logic_vector(15 downto 0) 
  );
end Register_File;

architecture Behavioral of Register_File is

    type register_data is array (0 to 15) of std_logic_vector(15 downto 0);
    signal register_file: register_data := (
        x"0001",
        x"0002", 
        x"0003", 
        x"0004", 
        x"0005", 
        x"0006", 
        x"0007", 
        x"0008", 
        x"0009", 
        x"000A",
        x"000B", 
        x"000C", 
        x"000D", 
        x"000E",
        x"000F",
        x"0010",  
        others => x"0000");

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                register_file(to_integer(unsigned(write_address))) <= write_data;
            end if;
        end if;
    end process;
    
    read_data1 <= register_file(to_integer(unsigned(read_address1)));
    read_data2 <= register_file(to_integer(unsigned(read_address2)));

end Behavioral;
