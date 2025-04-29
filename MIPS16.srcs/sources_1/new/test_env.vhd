library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_env is
  Port (
    clk : in  STD_LOGIC;                  
    btn_enable : in  STD_LOGIC;                   
    btn_reset : in  STD_LOGIC;                    
    sw : in  STD_LOGIC_VECTOR(7 downto 0);
    cathodes : out STD_LOGIC_VECTOR(6 downto 0);
    anodes : out STD_LOGIC_VECTOR(3 downto 0);
    leds : out STD_LOGIC_VECTOR(7 downto 0)
  );
end entity;

architecture Behavioral of test_env is
  signal enable_MPG : STD_LOGIC;
  signal instr : STD_LOGIC_VECTOR(15 downto 0);
  signal instr_next : STD_LOGIC_VECTOR(15 downto 0);
  signal PCPlus1 : STD_LOGIC_VECTOR(15 downto 0);
  signal branchTargetAddress : STD_LOGIC_VECTOR(15 downto 0);
  signal jumpTargetAddress : STD_LOGIC_VECTOR(15 downto 0);
  signal jumpCtrl, PCSrc : STD_LOGIC;
  signal rd1, rd2 : STD_LOGIC_VECTOR(15 downto 0);
  signal ext_imm : STD_LOGIC_VECTOR(15 downto 0);
  signal func : STD_LOGIC_VECTOR(2 downto 0);
  signal shamt : STD_LOGIC;
  signal RegDst, RegWrite, ALUSrc, ExtOp : STD_LOGIC;
  signal MemRead, MemWrite : STD_LOGIC;
  signal MemtoReg : STD_LOGIC;
  signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
  signal ALURes, MemData : STD_LOGIC_VECTOR(15 downto 0);
  signal zero : STD_LOGIC;
  signal WriteData : STD_LOGIC_VECTOR(15 downto 0);
  signal RegWrite_en, MemWrite_en  : STD_LOGIC;
  signal dbg_vector : std_logic_vector(7 downto 0);

begin
 mpg_inst : entity work.mpg
    port map(
      btn    => btn_enable,
      clk    => clk,
      enable => enable_MPG
    );
RegWrite_en <= enable_MPG and RegWrite;
MemWrite_en <= enable_MPG and MemWrite;
InstructionFetch_inst : entity work.InstructionFetch
    port map(
      clk                       => clk,
      reset                     => btn_reset,
      enable                    => enable_MPG,
      branchTargetAddress       => branchTargetAddress,
      jumpTargetAddress         => jumpTargetAddress,
      jumpCtrl                  => jumpCtrl,
      PCSrcCtrl                 => PCSrc,
      instructionToBeExecuted   => instr,
      nextSequentialInstruction => PCPlus1,
      nextInstruction           => instr_next
    );
InstructionDecode_inst : entity work.InstructionDecode
    port map(
      clk        => clk,
      instr      => instr,
      write_data => WriteData,
      RegWrite   => RegWrite_en,
      RegDst     => RegDst,
      ExtOp      => ExtOp,
      rd1        => rd1,
      rd2        => rd2,
      ext_imm    => ext_imm,
      func       => func,
      shamt      => shamt,
      rs         => open,
      rt         => open,
      rd         => open
    );
 MainControlUnit_inst : entity work.MainControlUnit
    port map(
      opcode    => instr(15 downto 13),
      RegDst    => RegDst,
      RegWrite  => RegWrite,
      ALUSrc    => ALUSrc,
      PCSrc     => PCSrc,
      MemRead   => MemRead,
      MemWrite  => MemWrite,
      MemtoReg  => MemtoReg,
      ALUOp     => ALUOp,
      jump      => jumpCtrl,
      ExtOp => ExtOp
    );
 jumpTargetAddress <= PCPlus1(15 downto 13) & instr(12 downto 0);
 ExecutionUnit_inst : entity work.ExecutionUnit
    port map(
      PCPlus1               => PCPlus1,
      rd1                   => rd1,
      rd2                   => rd2,
      ext_imm               => ext_imm,
      func                  => func,
      shamt                 => shamt,
      ALUSrc                => ALUSrc,
      ALUOp                 => ALUOp,
      branch_target_address => branchTargetAddress,
      ALURes                => ALURes,
      Zero                  => zero
    );
MemoryUnit_inst : entity work.MemoryUnit
    port map(
      clk        => clk,
      MemWrite   => MemWrite_en,
      ALURes     => ALURes,
      RD2        => rd2,
      MemData    => MemData,
      ALURes_out => open
    );
WriteBack_inst : entity work.WriteBack
    port map(
      MemtoReg  => MemtoReg,
      ALURes    => ALURes,
      MemData   => MemData,
      WriteData => WriteData
    );
SevenSegmentDisplay_inst : entity work.SevenSegmentDisplay
    port map(
      clk         => clk,
      sw          => sw,
      instr       => instr,
      pc_plus1    => PCPlus1,
      rd1         => rd1,
      rd2         => rd2,
      ext_imm     => ext_imm,
      alu_res     => ALURes,
      mem_data    => MemData,
      write_data  => WriteData,
      instr_next  => instr_next,
      cathodes    => cathodes,
      anodes      => anodes
    );

--LEDs display
dbg_vector <= 
       RegDst   &    -- LED 7
       RegWrite &    -- LED 6
       ALUSrc   &    -- LED 5
       PCSrc    &    -- LED 4
       MemRead  &    -- LED 3
       MemWrite &    -- LED 2
       MemtoReg &    -- LED 1
       jumpCtrl;     -- LED 0

leds <= dbg_vector when sw(0) = '0' else ("000000" & ALUOp);
end architecture;