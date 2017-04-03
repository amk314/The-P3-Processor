library ieee;
use ieee.std_logic_1164.all;

entity p3_piped_mcu_no_bypass is

port(	clock, reset, clockEn:	in	std_logic;

		PCSrc_pipe_IN:				in	std_logic_vector(1 downto 0);
		ComprSrc_pipe_IN:			in	std_logic_vector(0 downto 0);
		wrAddrSrc_pipe_IN:		in	std_logic_vector(1 downto 0);
		ExtndOp_pipe_IN:			in	std_logic_vector(0 downto 0);
		AluSrc1_pipe_IN:			in	std_logic_vector(1 downto 0);
		AluSrc2_pipe_IN:			in	std_logic_vector(1 downto 0);
		AluOp_pipe_IN:				in	std_logic_vector(3 downto 0);
		MemWrEn_pipe_IN:			in	std_logic_vector(0 downto 0);
		RegWrDataSrc_pipe_IN:	in	std_logic_vector(0 downto 0);
		RegWrEn_pipe_IN:			in	std_logic_vector(0 downto 0);
		
		PCSrc_Fetch_OUT:			out	std_logic_vector(1 downto 0);
		ComprSrc_Decode_OUT:		out	std_logic_vector(0 downto 0);
		wrAddrSrc_Decode_OUT:	out	std_logic_vector(1 downto 0);
		ExtndOp_Decode_OUT:		out	std_logic_vector(0 downto 0);
		AluSrc1_EXE_OUT:			out	std_logic_vector(1 downto 0);
		AluSrc2_EXE_OUT:			out	std_logic_vector(1 downto 0);
		AluOp_EXE_OUT:				out	std_logic_vector(3 downto 0);
		MemWrEn_MEM_OUT:			out	std_logic_vector(0 downto 0);
		RegWrDataSrc_WB_OUT:		out	std_logic_vector(0 downto 0);
		RegWrEn_WB_OUT:			out	std_logic_vector(0 downto 0));

end entity p3_piped_mcu_no_bypass;

architecture structure of p3_piped_mcu_no_bypass is

--signal 	AluSrc1_Dec:			std_logic_vector(1 downto 0);
--signal	AluSrc2_Dec:			std_logic_vector(1 downto 0);
--signal	AluOp_Dec:				std_logic_vector(3 downto 0);
signal	MemWrEn_EXE:			std_logic_vector(0 downto 0);
signal	RegWrDataSrc_EXE, RegWrDataSrc_MEM:		std_logic_vector(0 downto 0);
signal	RegWrEn_EXE, RegWrEn_MEM:			std_logic_vector(0 downto 0);

constant one: positive:=1;
constant two: positive:=2;
constant four: positive:=4;

begin

-- Fetch Stage
PCSrc_Fetch_OUT <= PCSrc_pipe_IN;

-- Decode Stage
ComprSrc_Decode_OUT <= ComprSrc_pipe_IN;
wrAddrSrc_Decode_OUT <= wrAddrSrc_pipe_IN;
ExtndOp_Decode_OUT <= ExtndOp_pipe_IN;

-- Execute Stage
exe_AluSrc1_flop: entity work.dflop(behavior)
	generic map( SIZE => two)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => AluSrc1_pipe_IN,
				q => AluSrc1_EXE_OUT);
				
exe_AluSrc2_flop: entity work.dflop(behavior)
	generic map( SIZE => two)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => AluSrc2_pipe_IN,
				q => AluSrc2_EXE_OUT);
				
exe_AluOp_flop: entity work.dflop(behavior)
	generic map( SIZE => four)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => AluOp_pipe_IN,
				q => AluOp_EXE_OUT);

--exe_MemWrEn_flop: entity work.dflop(behavior)
--	generic map( SIZE => one)
--	port map(clk => clock,
--				rst => reset,	--asynchronous
--				clken => clockEn,
--				din => MemWrEn_pipe_IN,
--				q => MemWrEn_EXE);
				
exe_RegWrData_flop: entity work.dflop(behavior)
	generic map( SIZE => one)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => RegWrDataSrc_pipe_IN,
				q => RegWrDataSrc_EXE);
				
exe_RegWrEn_flop: entity work.dflop(behavior)
	generic map( SIZE => one)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => RegWrEn_pipe_IN,
				q => RegWrEn_EXE);

-- Memory Stage
mem_MemWrEn_flop: entity work.dflop(behavior)
	generic map( SIZE => one)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => MemWrEn_pipe_IN,
				q => MemWrEn_MEM_OUT);
				
mem_RegWrData_flop: entity work.dflop(behavior)
	generic map( SIZE => one)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => RegWrDataSrc_EXE,
				q => RegWrDataSrc_MEM);

mem_regWrEN_flop: entity work.dflop(behavior)
	generic map( SIZE => one)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => RegWrEn_EXE,
				q => RegWrEn_MEM);
				
-- Write Back Stage
wb_RegWrData_flop: entity work.dflop(behavior)
	generic map( SIZE => one)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => RegWrDataSrc_MEM,
				q => RegWrDataSrc_WB_OUT);
				
wb_regWrEn_flop: entity work.dflop(behavior)
	generic map( SIZE => one)
	port map(clk => clock,
				rst => reset,	--asynchronous
				clken => clockEn,
				din => regWrEn_MEM,
				q => regWrEn_WB_OUT);
end architecture structure;