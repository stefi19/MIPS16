----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 12:42:05 PM
-- Design Name: 
-- Module Name: MemoryUnit - Behavioral
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

entity MemoryUnit is
Port (
        clk : in  STD_LOGIC;
        MemWrite: in  STD_LOGIC;
        ALURes : in  STD_LOGIC_VECTOR(15 downto 0);  -- Address
        RD2 : in  STD_LOGIC_VECTOR(15 downto 0);  -- Data to write
        MemData : out STD_LOGIC_VECTOR(15 downto 0);  -- Data read
        ALURes_out : out STD_LOGIC_VECTOR(15 downto 0) -- ALURes passthrough
    );
end MemoryUnit;

architecture Behavioral of MemoryUnit is
type ram_type is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
--signal RAM : ram_type := (others => (others => '0'));  -- Initialize all to 0
signal RAM : RAM_TYPE := (
    0 => x"0001",
    1 => x"0002",
    2 => x"0004",
   -- 2 => x"000C",  -- 12
    others => (others => '0')
);
signal addr : integer range 0 to 255;
begin
AddressDecode: addr<=to_integer(unsigned(ALURes(7 downto 0)));
AsynchronousRead: MemData<=RAM(addr);
SynchronousWrite: process(clk)
begin
    if rising_edge (clk) then
        if MemWrite='1' then
            RAM(addr)<=rd2;
        end if;
    end if;
end process;
PassALURES: ALURes_out<=ALURes;
end Behavioral;
