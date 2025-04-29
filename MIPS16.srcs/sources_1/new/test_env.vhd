library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_env is
  Port (
    clk         : in  STD_LOGIC;                    -- 100 MHz board clock
    btn_enable  : in  STD_LOGIC;                    -- step button
    btn_reset   : in  STD_LOGIC;                    -- async reset
    sw          : in  STD_LOGIC_VECTOR(7 downto 0); -- user switches
    cathodes    : out STD_LOGIC_VECTOR(6 downto 0);
    anodes      : out STD_LOGIC_VECTOR(3 downto 0);
    leds        : out STD_LOGIC_VECTOR(7 downto 0)
  );
end entity;

architecture Behavioral of test_env is

  ----------------------------------------------------------------------------
  -- Step-pulse generator
  ----------------------------------------------------------------------------
  signal enable_MPG   : STD_LOGIC;

  ----------------------------------------------------------------------------
  -- PC / IFetch
  ----------------------------------------------------------------------------
  signal instr                     : STD_LOGIC_VECTOR(15 downto 0);
  signal instr_next                : STD_LOGIC_VECTOR(15 downto 0);
  signal PCPlus1                   : STD_LOGIC_VECTOR(15 downto 0);
  signal branchTargetAddress       : STD_LOGIC_VECTOR(15 downto 0);
  signal jumpTargetAddress         : STD_LOGIC_VECTOR(15 downto 0);
  signal jumpCtrl, PCSrc           : STD_LOGIC;

  ----------------------------------------------------------------------------
  -- Register-Decode
  ----------------------------------------------------------------------------
  signal rd1, rd2                  : STD_LOGIC_VECTOR(15 downto 0);
  signal ext_imm                   : STD_LOGIC_VECTOR(15 downto 0);
  signal func                      : STD_LOGIC_VECTOR(2 downto 0);
  signal shamt                     : STD_LOGIC;

  ----------------------------------------------------------------------------
  -- Control signals
  ----------------------------------------------------------------------------
  signal RegDst, RegWrite, ALUSrc, ExtOp : STD_LOGIC;
  signal MemRead, MemWrite         : STD_LOGIC;
  signal MemtoReg                  : STD_LOGIC;
  signal ALUOp                     : STD_LOGIC_VECTOR(1 downto 0);

  ----------------------------------------------------------------------------
  -- Execution / Memory
  ----------------------------------------------------------------------------
  signal ALURes, MemData           : STD_LOGIC_VECTOR(15 downto 0);
  signal zero                      : STD_LOGIC;

  ----------------------------------------------------------------------------
  -- Write-back
  ----------------------------------------------------------------------------
  signal WriteData                 : STD_LOGIC_VECTOR(15 downto 0);
  
  ----------------------------------------------------------------------------
  -- Gated control-writes for RF and RAM
  ----------------------------------------------------------------------------
  signal RegWrite_en, MemWrite_en  : STD_LOGIC;
  signal dbg_vector : std_logic_vector(7 downto 0);

begin

  ----------------------------------------------------------------------------
  -- 1) Generate one-cycle "step" from push-button
  ----------------------------------------------------------------------------
  mpg_inst : entity work.mpg
    port map(
      btn    => btn_enable,
      clk    => clk,
      enable => enable_MPG
    );

  ----------------------------------------------------------------------------
  -- 2) Wire up gated enables
  ----------------------------------------------------------------------------
  RegWrite_en <= enable_MPG and RegWrite;
  MemWrite_en <= enable_MPG and MemWrite;

  ----------------------------------------------------------------------------
  -- 3) Instruction Fetch
  ----------------------------------------------------------------------------
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

  ----------------------------------------------------------------------------
  -- 4) Instruction Decode + Register File + Extender
  ----------------------------------------------------------------------------
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

  ----------------------------------------------------------------------------
  -- 5) Main Control Unit
  ----------------------------------------------------------------------------
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
  
  ----------------------------------------------------------------------------
  -- compute 16-bit jump target:
  --   top 3 bits come from PCPlus1(15 downto 13),
  --   low 13 bits from instr(12 downto 0)
  ----------------------------------------------------------------------------
  jumpTargetAddress <= PCPlus1(15 downto 13) & instr(12 downto 0);


  ----------------------------------------------------------------------------
  -- 6) Execute Unit
  ----------------------------------------------------------------------------
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

  ----------------------------------------------------------------------------
  -- 7) Memory Unit
  ----------------------------------------------------------------------------
  MemoryUnit_inst : entity work.MemoryUnit
    port map(
      clk        => clk,
      MemWrite   => MemWrite_en,
      ALURes     => ALURes,
      RD2        => rd2,
      MemData    => MemData,
      ALURes_out => open
    );

  ----------------------------------------------------------------------------
  -- 8) Write-Back Mux
  ----------------------------------------------------------------------------
  WriteBack_inst : entity work.WriteBack
    port map(
      MemtoReg  => MemtoReg,
      ALURes    => ALURes,
      MemData   => MemData,
      WriteData => WriteData
    );

  ----------------------------------------------------------------------------
  -- 9) Seven-Segment Display
  ----------------------------------------------------------------------------
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

  ----------------------------------------------------------------------------
  -- 10) Debug LEDs = [ALUOp,RegDst,RegWrite,ALUSrc,PCSrc,MemWrite,MemtoReg,Zero]
  ----------------------------------------------------------------------------
--  jumpTargetAddress <= "000" & instr(12 downto 0);
    ----------------------------------------------------------------------------
  -- 10) Debug LEDs = [RegDst,RegWrite,ALUSrc,PCSrc,MemRead,MemWrite,MemtoReg,jump]
  --    or else show ALUOp in the bottom two bits
  ----------------------------------------------------------------------------
  dbg_vector <= 
       RegDst   &    -- LED 7
       RegWrite &    -- LED 6
       ALUSrc   &    -- LED 5
       PCSrc    &    -- LED 4
       MemRead  &    -- LED 3
       MemWrite &    -- LED 2
       MemtoReg &    -- LED 1
       jumpCtrl;     -- LED 0

  leds <= dbg_vector 
         when sw(0) = '0' else
         ("000000" & ALUOp);  -- pad ALUOp into LEDs(1 downto 0), upper LEDs = '0'

end architecture;