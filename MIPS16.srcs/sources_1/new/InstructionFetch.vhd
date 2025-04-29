----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 09:44:24 AM
-- Design Name: 
-- Module Name: InstructionFetch - Behavioral
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

entity InstructionFetch is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           branchTargetAddress : in STD_LOGIC_VECTOR (15 downto 0);
           jumpTargetAddress : in STD_LOGIC_VECTOR (15 downto 0);
           jumpCtrl : in STD_LOGIC;
           PCSrcCtrl : in STD_LOGIC;
           instructionToBeExecuted : out STD_LOGIC_VECTOR (15 downto 0);
           nextSequentialInstruction : out STD_LOGIC_VECTOR (15 downto 0);
           nextInstruction : out STD_LOGIC_VECTOR(15 downto 0));  -- added to be able to display PCPlus1);
end InstructionFetch;

architecture Behavioral of InstructionFetch is
signal PC: STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal PCPlus1: STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
--signal outMUX: STD_LOGIC_VECTOR(15 downto 0);
signal nextPC: STD_LOGIC_VECTOR(15 downto 0);
type ROM_TYPE is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
  --                addr   
signal  rom : ROM_Type := (
        B"001_000_001_0000000",   --X"2080"	  --addi $1,$0,0
		B"001_000_010_0000001",	  --X"2101"	  --addi $2,$0,1	
		B"001_000_011_0000000",	  --X"2180"	  --addi $3,$0,0	
		B"001_000_100_0000001",	  --X"2201"	  --addi $4,$0,1
		B"011_011_001_0000000",   --X"6C80"   --sw $1,0($3)
		B"011_100_010_0000000",   --X"7100"   --sw $2,0($4)
		B"010_011_001_0000000",   --X"4C80"   --lw $1,0($3)
		B"010_100_010_0000000",   --X"5100"   --lw $2,0($4)
		B"000_001_010_101_0_000", --X"0550"   --add $5,$1,$2
		B"000_000_010_001_0_000", --X"0110"   --add $1,$0,$2
		B"000_000_101_010_0_000", --X"02A0"   --add $2,$0,$5
		B"111_000_000_0001000",   --X"E008"   --j 8
		others => x"0000"
  );

begin
PCget: process(clk, reset)
begin
if reset='1' then
    PC<=(others=>'0');
else
    if rising_edge (clk) then
        if enable='1' then
            PC<=nextPc;
        end if;
    end if;
end if;
end process;
PCPlus1get: PCPlus1 <= STD_LOGIC_VECTOR(unsigned(PC) + to_unsigned(1, 16));
nextSequentialInstruction<=PCplus1;
NextPCget: process(PCplus1,jumpCtrl,PCSrcCtrl,jumpTargetAddress,branchTargetAddress)
begin
if jumpCtrl='1' then
    nextPC<=jumpTargetAddress;
else
    if PCSrcCtrl='1' then
        nextPC<=branchTargetAddress;
        --nextPC<=branchTargetAddress+PC;
    else
        nextPC<=PCplus1;
    end if;
end if;
end process; 
instructionToBeExecuted<=ROM(to_integer(unsigned(PC(7 downto 0))));-- we only need 8 bits for 0 to 255
nextInstruction <= ROM(to_integer(unsigned(PCPlus1(7 downto 0)))); -- next instruction to display
end Behavioral;
