----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 10:59:27 AM
-- Design Name: 
-- Module Name: InstructionDecode - Behavioral
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

entity InstructionDecode is
Port (
        clk : in  STD_LOGIC;
        instr : in  STD_LOGIC_VECTOR(15 downto 0);
        write_data : in  STD_LOGIC_VECTOR(15 downto 0);
        RegWrite : in  STD_LOGIC;
        RegDst : in  STD_LOGIC;
        ExtOp : in  STD_LOGIC;
        rd1 : out STD_LOGIC_VECTOR(15 downto 0);
        rd2 : out STD_LOGIC_VECTOR(15 downto 0);
        ext_imm : out STD_LOGIC_VECTOR(15 downto 0);
        func : out STD_LOGIC_VECTOR(2 downto 0);
        shamt : out STD_LOGIC
    );
end InstructionDecode;

architecture Behavioral of InstructionDecode is
component RegisterFile is
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
end component;
signal rs_addr : STD_LOGIC_VECTOR(2 downto 0);
signal rt_addr : STD_LOGIC_VECTOR(2 downto 0);
signal rd_addr : STD_LOGIC_VECTOR(2 downto 0);
begin
RS: rs_addr<=instr(12 downto 10);
RT: rt_addr<=instr(9 downto 7);
RD: rd_addr<=instr(6 downto 4);
RegisterFile_inst: RegisterFile port map(clk=>clk, RegWrite=>RegWrite, RegDst=> RegDst, rs_addr=>rs_addr, rt_addr=>rt_addr, rd_addr=>rd_addr, write_data=>write_data, rd1=>rd1, rd2=>rd2);
Extend: process(instr, ExtOp)
begin
    if ExtOp='1' then
        --sign extend
        ext_imm<=(8 downto 0 => instr(6))&instr(6 downto 0);
    else
        --zero extend
        ext_imm<=(8 downto 0 => '0')&instr(6 downto 0);
    end if;
end process;
ExtractFunc: func<=instr(2 downto 0);
ExtractShiftAmount: shamt<=instr(3);
end Behavioral;
