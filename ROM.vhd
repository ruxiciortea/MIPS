library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ROM is
  Port (address: in std_logic_vector(7 downto 0);
        data_out: out std_logic_vector(15 downto 0)
  );
end ROM;

architecture Behavioral of ROM is

    type rom_data is array(0 to 255) of std_logic_vector(15 downto 0);
    signal current_data: rom_data := (
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
        others => x"0000");

begin

    data_out <= current_data(to_integer(unsigned(address)));

end Behavioral;
