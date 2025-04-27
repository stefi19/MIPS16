----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 11:19:13 AM
-- Design Name: 
-- Module Name: RegisterFile - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
Port (
        clk : in  STD_LOGIC;
        RegWrite : in  STD_LOGIC;
        RegDst : in  STD_LOGIC;
        rs_addr : in  STD_LOGIC_VECTOR(2 downto 0);
        rt_addr : in  STD_LOGIC_VECTOR(2 downto 0);
        rd_addr : in  STD_LOGIC_VECTOR(2 downto 0);
        write_data : in  STD_LOGIC_VECTOR(15 downto 0);
        rd1 : out STD_LOGIC_VECTOR(15 downto 0);
        rd2 : out STD_LOGIC_VECTOR(15 downto 0)
    );
end RegisterFile;

architecture Behavioral of RegisterFile is
--8 registers of 16 bits
type reg_file_type is array (0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
--signal reg_file : reg_file_type := (others => (others => '0'));
signal reg_file : reg_file_type := (
    0 => x"0014",  -- $zero
    1 => x"0020",  -- $t0 = 32
    2 => x"000C",  -- $t1 = 12
    5 => x"0000",
    others => (others => '0')
);

begin
Read1: rd1<=reg_file(to_integer(unsigned(rs_addr)));
Read2: rd2<=reg_file(to_integer(unsigned(rt_addr)));
WriteOperation: process(clk)
begin
    if rising_edge (clk) then
        if RegWrite='1' then
            if RegDst='1' then
                reg_file(to_integer(unsigned(rd_addr)))<=write_data;
            else
                reg_file(to_integer(unsigned(rt_addr)))<=write_data;
            end if;
        end if;
    end if;
end process;
end Behavioral;
