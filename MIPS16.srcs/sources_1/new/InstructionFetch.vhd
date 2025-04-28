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
signal ROM : ROM_TYPE := (
B"010_000_011_0000000",  -- lw   $3, 0($zero)        ; 4180
B"001_000_010_0000000",  -- addi $2, $zero, 0        ; 2100
-- loop:
B"101_011_100_0000001",  -- andi $4, $3, 1           ; AE01
B"100_100_000_0000001",  -- beq  $4, $zero, skip_inc ; 9001
B"001_010_010_0000001",  -- addi $2, $2, 1           ; 2901
-- skip_inc:
B"000_000_011_011_1_011",-- srl  $3, $3, 1           ; 01BB
B"100_011_000_0000010",  -- beq  $3, $zero, exit     ; 8C02
B"111_0000000000010",      -- j loop (address 0x02)    ; E002
-- exit:
B"011_000_010_0000010",  -- sw   $2, 2($zero)        ; 6102
B"111_0000000001010",      -- j 0x00    ; E008
others => B"0000000000000000"
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
