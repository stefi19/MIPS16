----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 11:54:25 AM
-- Design Name: 
-- Module Name: ExecutionUnit - Behavioral
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

entity ExecutionUnit is
Port (
        PCPlus1 : in  STD_LOGIC_VECTOR(15 downto 0);
        rd1 : in  STD_LOGIC_VECTOR(15 downto 0);
        rd2 : in  STD_LOGIC_VECTOR(15 downto 0);
        ext_imm : in  STD_LOGIC_VECTOR(15 downto 0);
        func : in  STD_LOGIC_VECTOR(2 downto 0);
        shamt : in  STD_LOGIC;
        ALUSrc : in  STD_LOGIC;
        ALUOp : in  STD_LOGIC_VECTOR(1 downto 0);
        branch_target_address : out STD_LOGIC_VECTOR(15 downto 0);
        ALURes : out STD_LOGIC_VECTOR(15 downto 0);
        Zero : out STD_LOGIC
    );
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is
signal ALUControl: STD_LOGIC_VECTOR(2 downto 0);
signal operand2: STD_LOGIC_VECTOR(15 downto 0);
begin
ALUControlUnit: process(ALUOp, func)
begin
    case ALUOp is 
        when "00" => ALUControl<="010";-- LW/SW, so we need addition, for the computation of the memory address
        when "01" => ALUControl<="110"; -- BEQ, so we need substraction, to compare the contents of 2 rgisters
        when others => --"10" for R type, for jump we don't care
            -- check the func bits for the R type operations
            case func is
                when "000" => ALUControl <= "010";  -- ADD
                    when "001" => ALUControl <= "110";  -- SUB
                    when "010" => ALUControl <= "100";  -- SLL
                    when "011" => ALUControl <= "101";  -- SRL
                    when "100" => ALUControl <= "000";  -- AND
                    when "101" => ALUControl <= "001";  -- OR
                    when "110" => ALUControl <= "011";  -- XOR
                    when "111" => ALUControl <= "111";  -- NOR
                    when others => ALUControl <= "010";  -- Default AND
            end case;
     end case;
end process;
--select between rd2 and ext_imm
operand2<=rd2 when ALUSrc='0' else ext_imm;
ALUOperations: process(rd1,ALUControl,shamt,operand2)
variable result: STD_LOGIC_VECTOR(15 downto 0);
begin
    case ALUControl is
        when "000" => result:=rd1 and operand2; 
        when "001" => result:=rd1 or operand2;
        when "010" => result:=std_logic_vector(signed(rd1)+signed(operand2));
        when "011" => result:=rd1 xor operand2;
        when "100" => 
            if shamt='1' then
                result:=rd1(14 downto 0) & '0';
            else
                result:=rd1;
            end if;
        when "101" =>
            if shamt='1' then
                result:='0'&rd1(15 downto 1);
            else
                result:=rd1;
            end if;
         when "110" => result:=std_logic_vector(signed(rd1)-signed(operand2));
         when "111" => result:=not(rd1 or operand2);
         when others => result:=(others=>'0');
   end case;
   ALURes<=result;
   if result=x"0000" then
        Zero<='1';
   else
        Zero<='0';
   end if;
   --Zero<='1' when result=x"0000" else '0';
end process;
BranchTargetAddress: branch_target_address<=std_logic_vector(unsigned(PCPlus1)+unsigned(ext_imm));
end Behavioral;
