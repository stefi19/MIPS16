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
           nextSequentialInstruction : out STD_LOGIC_VECTOR (15 downto 0));
end InstructionFetch;

architecture Behavioral of InstructionFetch is
signal PC: STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal PCPlus1: STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
--signal outMUX: STD_LOGIC_VECTOR(15 downto 0);
signal nextPC: STD_LOGIC_VECTOR(15 downto 0);
type ROM_TYPE is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
signal ROM: ROM_TYPE:=(
    -- GCD Part
    B"010_101_001_0000000",  -- lw $t0, 0($s0)
    B"010_101_010_0000100",  -- lw $t1, 4($s0)
    B"000_001_010_011_0_001",-- sub $t2, $t0, $t1
    B"100_011_000_0010110",  -- beq $t2, $zero, done (+22)
    B"000_011_000_100_0_000",-- add $t3, $t2, $zero

    -- Shiftăm $t3 de 15 ori pentru semn
    B"000_100_100_100_1_011",-- srl $t3, $t3, 1
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",
    B"000_100_100_100_1_011",

    B"101_100_100_0000001",  -- andi $t3, $t3, 1
    B"100_100_000_0000010",  -- beq $t3, $zero, greater (+2)
    B"000_010_000_010_0_001",-- sub $t1, $t1, $t0
    B"111_1111_1110_1000",   -- j gcd_loop (-24)
    -- greater:
    B"000_001_001_001_0_001",-- sub $t0, $t0, $t1
    B"111_1111_1101_1010",   -- j gcd_loop (-26)

    -- done:
    B"011_101_001_0001000",  -- sw $t0, 8($s0)

    -- Reverse Part
    B"101_001_100_0001111",  -- andi $t3, $t0, 0xF
    B"000_011_011_011_1_010",-- sll $t2, $t2, 1
    B"000_011_011_011_1_010",
    B"000_011_011_011_1_010",
    B"000_011_011_011_1_010",
    B"000_011_100_011_0_101",-- or  $t2, $t2, $t3
    B"000_001_001_001_1_011",-- srl $t0, $t0, 1
    B"000_001_001_001_1_011",
    B"000_001_001_001_1_011",
    B"000_001_001_001_1_011",
    B"100_001_000_0000001",  -- beq $t0, $zero, end_reverse (+1)
    B"111_1111_1101_0100",   -- j reverse_loop (-12)
    -- end_reverse:
    B"011_101_011_0001100"   -- sw $t2, 12($s0)
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
PCPlus1get: PCplus1<=STD_LOGIC_VECTOR(unsigned(PC)+1);
nextSequentialInstruction<=PCplus1;
NextPCget: process(PCplus1,jumpCtrl,PCSrcCtrl,jumpTargetAddress,branchTargetAddress)
begin
if jumpCtrl='1' then
    nextPC<=jumpTargetAddress;
else
    if PCSrcCtrl='1' then
        nextPC<=branchTargetAddress;
    else
        nextPC<=PCplus1;
    end if;
end if;
end process; 
instructionToBeExecuted<=ROM(to_integer(unsigned(PC(7 downto 0))));-- we only need 8 bits for 0 to 255

end Behavioral;
