----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 12:50:01 PM
-- Design Name: 
-- Module Name: SevenSegmentDisplay - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SevenSegmentDisplay is
Port (
        clk : in  STD_LOGIC;
        sw : in  STD_LOGIC_VECTOR(7 downto 0);
        instr : in  STD_LOGIC_VECTOR(15 downto 0);
        pc_plus1 : in  STD_LOGIC_VECTOR(15 downto 0);
        rd1 : in  STD_LOGIC_VECTOR(15 downto 0);
        rd2 : in  STD_LOGIC_VECTOR(15 downto 0);
        ext_imm : in  STD_LOGIC_VECTOR(15 downto 0);
        alu_res : in  STD_LOGIC_VECTOR(15 downto 0);
        mem_data : in  STD_LOGIC_VECTOR(15 downto 0);
        write_data : in  STD_LOGIC_VECTOR(15 downto 0);
        instr_next : in STD_LOGIC_VECTOR(15 downto 0);
        cathodes : out STD_LOGIC_VECTOR(6 downto 0);
        anodes : out STD_LOGIC_VECTOR(3 downto 0)
    );
end SevenSegmentDisplay;

architecture Behavioral of SevenSegmentDisplay is
signal ssd_data : STD_LOGIC_VECTOR(15 downto 0);
signal outCount : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal outM1    : STD_LOGIC_VECTOR(3 downto 0);
begin
SSDMux: process(sw, instr, pc_plus1, rd1, rd2, ext_imm, alu_res, mem_data, write_data)
begin
case sw(7 downto 5) is
    when "000" => ssd_data<=instr;
    when "001" => ssd_data<=instr_next;
    when "010" => ssd_data<=rd1;
    when "011" => ssd_data<=rd2;
    when "100" => ssd_data<=ext_imm;
    when "101" => ssd_data<=alu_res;
    when "110" => ssd_data<=mem_data;
    when "111" => ssd_data<=write_data;
    when others => ssd_data<=(others=>'0');
end case;
end process;
-- Counter for multiplexing (slow down)
Counter:process(clk)
begin
    if rising_edge(clk) then
            outCount<=outCount+1;
    end if;
end process;
--select the digit based on the counter
SelectDigit: process(outCount, ssd_data)
begin
    case outCount(15 downto 14)is
        when "00" => outM1<=ssd_data(3 downto 0);
        when "01" => outM1<=ssd_data(7 downto 4);
        when "10" => outM1<=ssd_data(11 downto 8);
        when "11" => outM1<=ssd_data(15 downto 12);
        when others => outM1<="0000";
     end case;
end process;
--select the cathodes based on outM1
CathodesSelect: with outM1 select
       cathodes <= "1111001" when "0001",  -- 1
                   "0100100" when "0010",  -- 2
                   "0110000" when "0011",  -- 3
                   "0011001" when "0100",  -- 4
                   "0010010" when "0101",  -- 5
                   "0000010" when "0110",  -- 6
                   "1111000" when "0111",  -- 7
                   "0000000" when "1000",  -- 8
                   "0010000" when "1001",  -- 9
                   "0001000" when "1010",  -- A
                   "0000011" when "1011",  -- B
                   "1000110" when "1100",  -- C
                   "0100001" when "1101",  -- D
                   "0000110" when "1110",  -- E
                   "0001110" when "1111",  -- F
                   "1000000" when "0000",  -- 0
                   "1111111" when others;  -- off
--select anodes based on counter
AnodesSelect: process(outCount)
begin
    case outCount(15 downto 14) is
        when "00" => anodes<="1110";
        when "01" => anodes<="1101";
        when "10" => anodes<="1011";
        when "11" => anodes<="0111";
        when others => anodes<="1111";
     end case;
end process;
end Behavioral;
