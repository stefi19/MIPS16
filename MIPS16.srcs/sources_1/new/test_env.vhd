----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2025 01:09:24 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity test_env is
Port ( 
        clk : in  STD_LOGIC;
        btn_enable : in  STD_LOGIC;
        btn_reset  : in  STD_LOGIC;
        sw : in  STD_LOGIC_VECTOR(7 downto 0);
        cathodes : out STD_LOGIC_VECTOR(6 downto 0);
        anodes : out STD_LOGIC_VECTOR(3 downto 0);
        leds : out STD_LOGIC_VECTOR(7 downto 0)
    );
end test_env;

architecture Behavioral of test_env is
-- Internal signals for datapath connections
signal instr_next : STD_LOGIC_VECTOR(15 downto 0);
signal instr, PCPlus1 : STD_LOGIC_VECTOR(15 downto 0);
signal opcode, func : STD_LOGIC_VECTOR(2 downto 0);
signal rs,rt,rd : STD_LOGIC_VECTOR(2 downto 0);
signal shamt : STD_LOGIC;
signal ext_imm : STD_LOGIC_VECTOR(15 downto 0);
signal rd1, rd2 : STD_LOGIC_VECTOR(15 downto 0);
signal ALURes, MemData, WriteData : STD_LOGIC_VECTOR(15 downto 0);
signal branchTargetAddress : STD_LOGIC_VECTOR(15 downto 0);
signal zero : STD_LOGIC;
signal jumpCtrl : STD_LOGIC;
signal jumpTargetAddress : STD_LOGIC_VECTOR(15 downto 0);
-- Control signals
signal RegDst, RegWrite, ALUSrc, PCSrc, MemRead, MemWrite, MemtoReg : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
-- MPG validation signals
signal enable_MPG      : STD_LOGIC;
signal enable_PC       : STD_LOGIC;
signal enable_RegWrite : STD_LOGIC;
component InstructionFetch is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           branchTargetAddress : in STD_LOGIC_VECTOR (15 downto 0);
           jumpTargetAddress : in STD_LOGIC_VECTOR (15 downto 0);
           jumpCtrl : in STD_LOGIC;
           PCSrcCtrl : in STD_LOGIC;
           instructionToBeExecuted : out STD_LOGIC_VECTOR (15 downto 0);
           nextSequentialInstruction : out STD_LOGIC_VECTOR (15 downto 0);
           nextInstruction : out STD_LOGIC_VECTOR(15 downto 0));
end component;
component mpg is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : out STD_LOGIC);
end component;
component InstructionDecode is
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
        shamt : out STD_LOGIC;
        rs : out STD_LOGIC_VECTOR(2 downto 0); -- Added for display
        rt : out STD_LOGIC_VECTOR(2 downto 0); -- Added for display
        rd : out STD_LOGIC_VECTOR(2 downto 0)  -- Added for display
    );
end component;
component ExecutionUnit is
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
end component;
component MainControlUnit is
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
        ALUOp : out STD_LOGIC_VECTOR (1 downto 0);
        jump: out STD_LOGIC
    );
end component;
component MemoryUnit is
Port (
        clk : in  STD_LOGIC;
        MemWrite: in  STD_LOGIC;
        ALURes : in  STD_LOGIC_VECTOR(15 downto 0);  -- Address
        RD2 : in  STD_LOGIC_VECTOR(15 downto 0);  -- Data to write
        MemData : out STD_LOGIC_VECTOR(15 downto 0);  -- Data read
        ALURes_out : out STD_LOGIC_VECTOR(15 downto 0) -- ALURes passthrough
    );
end component;
component WriteBack is
Port (
        MemtoReg : in  STD_LOGIC;
        ALURes : in  STD_LOGIC_VECTOR(15 downto 0);
        MemData : in  STD_LOGIC_VECTOR(15 downto 0);
        WriteData : out STD_LOGIC_VECTOR(15 downto 0) --data to be written back into the register file
    );
end component;
component SevenSegmentDisplay is
Port (
        clk : in  STD_LOGIC;
        sw : in  STD_LOGIC_VECTOR(7 downto 0);
        instr : in  STD_LOGIC_VECTOR(15 downto 0);
        pc_plus1 : in  STD_LOGIC_VECTOR(15 downto 0);
        rd1 : in  STD_LOGIC_VECTOR(15 downto 0);
        rd2 : in  STD_LOGIC_VECTOR(15 downto 0);
        ext_imm : in  STD_LOGIC_VECTOR(15 downto 0);
        alu_res : in  STD_LOGIC_VECTOR(15 downto 0);
        mem_data : in  STD_LOGIC_VECTOR(15 downto 0);
        write_data : in  STD_LOGIC_VECTOR(15 downto 0);
        instr_next : in STD_LOGIC_VECTOR(15 downto 0);
        cathodes : out STD_LOGIC_VECTOR(6 downto 0);
        anodes : out STD_LOGIC_VECTOR(3 downto 0)
    );
end component;
begin
mpg_inst: mpg port map (clk=>clk, btn=>btn_enable,enable=>enable_MPG);
enable_PC<=enable_MPG;
enable_RegWrite<=enable_MPG and RegWrite;
InstructionFetch_inst: InstructionFetch port map(clk=>clk, reset=>btn_reset, enable=>enable_PC, branchTargetAddress=>branchTargetAddress, jumpTargetAddress=>jumpTargetAddress,jumpCtrl=>jumpCtrl,PCSrcCtrl=>PCSrc, instructionToBeExecuted=>instr, nextSequentialInstruction=>PCPlus1, nextInstruction => instr_next);
InstructionDecode_inst: InstructionDecode port map(rs=>rs,rt=>rt,rd=>rd,clk=>clk, instr=>instr, write_data=>WriteData, RegWrite=>enable_RegWrite, RegDst=>RegDst, ExtOp=>'1',rd1=>rd1,rd2=>rd2,ext_imm=>ext_imm,func=>func,shamt=>shamt);
MainControlUnit_inst: MainControlUnit port map(opcode=>opcode, RegDst=>RegDst, RegWrite=>RegWrite, ALUSrc=>ALUSrc, PCSrc=>PCSrc, MemRead=>MemRead, MemWrite=>MemWrite, MemtoReg=>MemtoReg,ALUOp=>ALUOp, jump=>jumpCtrl);
ExecutionUnit_inst: ExecutionUnit port map(PCPlus1=>PCPlus1, rd1=>rd1, rd2=>rd2, ext_imm=>ext_imm, func=>func, shamt=>shamt, ALUSrc=>ALUSrc, ALUOp=>ALUOp, branch_target_address=>branchTargetAddress, ALURes=>ALURes, Zero=>zero);
MemoryUnit_inst: MemoryUnit port map(clk=>clk, MemWrite=>MemWrite, ALURes=>ALURes, rd2=>rd2, MemData=>MemData, ALURes_out=>ALURes);
WriteBack_inst: WriteBack port map(MemtoReg=>MemtoReg, ALURes=>ALURes, MemData=>MemData, WriteData=>WriteData);
SSD_inst: SevenSegmentDisplay port map(instr_next => instr_next,clk=>clk, sw=>sw, instr=>instr, pc_plus1=>PCPlus1, rd1=>rd1, rd2=>rd2, ext_imm=>ext_imm, alu_res=>ALURes, mem_data=>MemData, write_data=>WriteData, cathodes=>cathodes, anodes=>anodes);
--leds<='0' & ALUOp & "00000" when sw(0)='1' else RegDst&RegWrite&ALUSrc&PCSrc&MemRead&MemWrite&MemtoReg&'0';
leds <= '0' & ALUOp & "00000" when sw(0) = '1' else RegDst & RegWrite & ALUSrc & PCSrc & MemRead & MemWrite & MemtoReg & '0';
jumpTargetAddress<=ext_imm;
--leds <= rd1(7 downto 0);  -- vezi dacă rd1 primește ceva
end Behavioral;
