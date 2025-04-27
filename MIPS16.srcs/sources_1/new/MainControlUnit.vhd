----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 12:22:59 PM
-- Design Name: 
-- Module Name: MainControlUnit - Behavioral
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

entity MainControlUnit is
Port (
        opcode : in  STD_LOGIC_VECTOR (2 downto 0);  -- 3-bit opcode
        -- selects destination register, rd for R-type and rt for I-type
        RegDst : out STD_LOGIC;
        -- enables writing to the register file
        RegWrite : out STD_LOGIC;
        -- selects between second register or immediate for ALU operand
        ALUSrc : out STD_LOGIC;
        -- controls PC update, sequential or branch target
        PCSrc : out STD_LOGIC;
        -- enables memory read, for load word
        MemRead : out STD_LOGIC;
        -- enables memory write, for store word
        MemWrite : out STD_LOGIC;
        -- selects ALU result or memory data for writing back to register file
        MemtoReg : out STD_LOGIC;
        -- decides ALU operation type (00 - lw, 01 - sw  or 10 - R type)
        ALUOp : out STD_LOGIC_VECTOR (1 downto 0)
    );
end MainControlUnit;

architecture Behavioral of MainControlUnit is

begin
SetFlags: process(opcode)
begin
    case opcode is
        when "000" => --R type
            RegDst<='1';
            RegWrite<='1';
            ALUSrc<='0';
            PCSrc<='0';
            MemRead<='0';
            MemWrite<='0';
            MemtoReg<='0';
            ALUOp<="10";
        when "001" => --ADDI
            RegDst<='0';
            RegWrite<='1';
            ALUSrc<='1'; -- use immediate
            PCSrc<='0';
            MemRead<='0';
            MemWrite<='0';
            MemtoReg<='0';
            ALUOp<="10";
        when "010" => --LW
            RegDst<='0';
            RegWrite<='1';
            ALUSrc<='1';
            PCSrc<='0';
            MemRead<='1';
            MemWrite<='0';
            MemtoReg<='1';
            ALUOp<="00";
        when "011" => --SW
            RegDst<='0';
            RegWrite<='0';
            ALUSrc<='1';
            PCSrc<='0';
            MemRead<='0';
            MemWrite<='1';
            MemtoReg<='0';
            ALUOp<="00";
        when "100" => --BEQ
            RegDst<='0';
            RegWrite<='0';
            ALUSrc<='0';
            PCSrc<='1';
            MemRead<='0';
            MemWrite<='0';
            MemtoReg<='0';
            ALUOp<="01";
        when "101" => --ANDI
            RegDst<='0';
            RegWrite<='1';
            ALUSrc<='1';
            PCSrc<='0';
            MemRead<='0';
            MemWrite<='0';
            MemtoReg<='0';
            ALUOp<="10";
        when "110" => --ORI
            RegDst<='0';
            RegWrite<='1';
            ALUSrc<='1';
            PCSrc<='0';
            MemRead<='0';
            MemWrite<='0';
            MemtoReg<='0';
            ALUOp<="10";
        when "111" => --JUMP
            RegDst<='0';
            RegWrite<='0';
            ALUSrc<='0';
            PCSrc<='1';
            MemRead<='0';
            MemWrite<='0';
            MemtoReg<='0';
            ALUOp<="00";
         when others =>
            RegDst<='0';
            RegWrite<='0';
            ALUSrc<='0';
            PCSrc<='0';
            MemRead<='0';
            MemWrite<='0';
            MemtoReg<='0';
            ALUOp<="00";   
    end case;
end process;
end Behavioral;
