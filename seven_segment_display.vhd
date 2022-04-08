library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seven_segment_display is
    Port (
        clk: in  std_logic;
        digit0: in  std_logic_vector(3 downto 0);
        digit1: in  std_logic_vector(3 downto 0);
        digit2: in  std_logic_vector(3 downto 0);
        digit3: in  std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(3 downto 0)
    );
end seven_segment_display;

architecture Behavioral of seven_segment_display is

    signal counter: std_logic_vector(15 downto 0) := X"0000";
    signal cathodes_mux: std_logic_vector(3 downto 0)  := X"0";
    
begin

    counter_process: process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    cathodes_mux_process : process(counter(15 downto 14))
    begin
        case counter(15 downto 14) is
            when "00" => cathodes_mux <= digit3;
            when "01" => cathodes_mux <= digit2;
            when "10" => cathodes_mux <= digit1;
            when "11" => cathodes_mux <= digit0;
            when others => cathodes_mux <= digit3;
        end case;
    end process;                          

    decoder_process: process(cathodes_mux)
    begin
        case cathodes_mux is
            when "0001" => cat <= B"111_1001";
            when "0010" => cat <= B"010_0100";
            when "0011" => cat <= B"011_0000";
            when "0100" => cat <= B"001_1001";
            when "0101" => cat <= B"001_0010";
            when "0110" => cat <= B"000_0010";
            when "0111" => cat <= B"111_1000";
            when "1000" => cat <= B"000_0000";
            when "1001" => cat <= B"001_0000"; 
            when "1010" => cat <= B"000_1000";
            when "1011" => cat <= B"000_0011";
            when "1100" => cat <= B"100_0110";
            when "1101" => cat <= B"010_0001";
            when "1110" => cat <= B"000_0110";
            when "1111" => cat <= B"000_1110";
            when others => cat <= B"100_0000";
        end case;
    end process;
    
    anodes_mux_process: process(counter(15 downto 14))
    begin
        case counter(15 downto 14) is
            when "00" => an <= "1110";
            when "01" => an <= "1101";
            when "10" => an <= "1011";
            when "11" => an <= "0111";
            when others => an <= "1110";
        end case;
    end process;  

end Behavioral;