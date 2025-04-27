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
B"010_101_001_0000000",  -- lw  $t0, 0($s0)     ; 5480

B"001_000_010_0000000",  -- addi $t1, $zero, 0  ; 2080

-- loop:
B"101_001_011_0001111",  -- andi $t2, $t0, 0xF  ; A18F (extrage cifra)
B"101_011_100_0000001",  -- andi $t3, $t2, 1    ; A601 (verifică paritate)
B"100_100_000_0000010",  -- beq  $t3, $zero, add; 9002 (dacă pară, sari la add)

-- skip_add:
B"000_001_001_001_1_011",-- srl $t0, $t0, 4     ; 049B (shift dreapta cu 4)
B"100_001_000_0000010",  -- beq  $t0, $zero, end; 8402 (dacă $t0==0, sari la end)
B"111_11111_1111_1000",   -- j loop              ; FFF8 (sari înapoi la loop)

-- add:
B"000_010_010_011_0_000",-- add $t1, $t1, $t2   ; 0898 (adaugă cifra la sumă)
B"111_11111_1111_1010",   -- j skip_add          ; FFFA (sari la skip_add)

-- end:
B"011_101_010_0000100",   -- sw  $t1, 4($s0)     ; 7484 (scrie suma)

    others=>B"0000000000000000"
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
    else
        nextPC<=PCplus1;
    end if;
end if;
end process; 
instructionToBeExecuted<=ROM(to_integer(unsigned(PC(7 downto 0))));-- we only need 8 bits for 0 to 255
nextInstruction <= ROM(to_integer(unsigned(PCPlus1(7 downto 0)))); -- instrucțiunea următoare pt afisat
end Behavioral;
