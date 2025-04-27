----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 12:46:32 PM
-- Design Name: 
-- Module Name: WriteBack - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WriteBack is
Port (
        MemtoReg : in  STD_LOGIC;
        ALURes : in  STD_LOGIC_VECTOR(15 downto 0);
        MemData : in  STD_LOGIC_VECTOR(15 downto 0);
        WriteData : out STD_LOGIC_VECTOR(15 downto 0) --data to be written back into the register file
    );
end WriteBack;

architecture Behavioral of WriteBack is
begin
--just a simple MUX that selects between ALURes and MemData
MUX: WriteData<=MemData when MemtoReg='1' else ALURes;
end Behavioral;
