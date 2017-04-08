library ieee;
use ieee.std_logic_1164.all;

-- This component uses the following designs:
	-- RAM
	-- D Flops

entity p3_mem_no_bypass is
  port(	--Inputs
	clock, reset, clkEn:    in  std_logic;
--	RegWrEnInMEM:           in  std_logic_vector(0 downto 0);
--	RegWrDataSrcInMEM:      in  std_logic_vector(0 downto 0);
	MemWriteInMEM:          in  std_logic_vector(0 downto 0);
	ALUResultMemAdderOutMEM:in  std_logic_vector(7 downto 0);
	ALUResultInMEM:         in  std_logic_vector(31 downto 0);
	rdData2InMEM:           in  std_logic_vector(31 downto 0);
	wrAddrInMEM:            in  std_logic_vector(4 downto 0);

	--Outputs
--	RegWrEnOutWB:		out  std_logic_vector(0 downto 0);
--	RegWrDataSrcOutWB:	out  std_logic_vector(0 downto 0);
	RdMemDataOutWB:		out  std_logic_vector(31 downto 0);
	ALUResultOutWB:		out  std_logic_vector(31 downto 0);
	wrAddrOutWB:		out  std_logic_vector(4 downto 0));
		
end entity p3_mem_no_bypass;

architecture structure of p3_mem_no_bypass is

signal RegWrEnMEM:	 std_logic_vector(0 downto 0);
signal RegWrDataSrcMEM:  std_logic_vector(0 downto 0);
signal RdMemDataMEM:	 std_logic_vector(31 downto 0);
signal ALUResultMEM:	 std_logic_vector(31 downto 0);
signal wrAddrMEM:	 std_logic_vector(4 downto 0);

--signal RegWrDataSrc_OutWB:  std_logic;
--signal RegWrEn_OutWB:	    std_logic;		
--signal RdMemData:	    std_logic_vector(31 downto 0);
--signal ALU_result_OutWB:    std_logic_vector(31 downto 0);
--signal wrAddr_OutWB:	    std_logic_vector(4 downto 0)


constant thirty_two:	positive:= 32;
constant five:		positive:= 5;
constant one:		positive:= 1;

begin

--RegWrEnFlopInMEM:	entity work.dflop(behavior)
--		generic map( SIZE => one)
--		port map( clk =>  clock,
--	      		rst   =>  reset,
--	     		clken =>  clkEn,
--			din   =>  RegWrEnInMEM,
--			q     =>  RegWrEnMEM);
--
--RegWrDataSrcFlopInMEM: entity work.dflop(behavior)
--		generic map( SIZE => one)
--		port map( clk =>  clock,
--	      		rst   =>  reset,
--	     		clken =>  clkEn,
--			din   =>  RegWrDataSrcInMEM,
--			q     =>  RegWrDataSrcMEM);

RAM: 		ENTITY work.dataRAM(SYN)
		PORT map( address => ALUResultMemAdderOutMEM,
			clken	  => clkEn,
			clock	  => clock,
			data	  => rdData2InMEM,
			wren	  => MemWriteInMEM(0),
			q	  => RdMemDataMEM); 


ALUresultFlopInMEM:	entity work.dflop(behavior)
		generic map( SIZE => thirty_two)
		port map( clk =>  clock,
	      		rst   =>  reset,
	     		clken =>  clkEn,
			din   =>  ALUResultInMEM,
			q     =>  ALUResultMEM);

wrAddrFlopInMEM: entity work.dflop(behavior)
		generic map( SIZE => five)
		port map( clk =>  clock,
	      		rst   =>  reset,
	     		clken =>  clkEn,
			din   =>  wrAddrInMEM,
			q     =>  wrAddrMEM);

-- WB Flops

--RegWrEnFlopOutWB:	entity work.dflop(behavior)
--		generic map( SIZE => one)
--		port map( clk =>  clock,
--	      		rst   =>  reset,
--	     		clken =>  clkEn,
--			din   =>  RegWrEnMEM,
--			q(0)     =>  RegWrEnOutWB(0));
--
--RegWrDataSrcFlopOutWB: entity work.dflop(behavior)
--		generic map( SIZE => one)
--		port map( clk =>  clock,
--	      		rst   =>  reset,
--	     		clken =>  clkEn,
--			din   =>  RegWrDataSrcMEM,
--			q     =>  RegWrDataSrcOutWB);

RAM_OutWB: entity work.dflop(behavior)
		generic map( SIZE => thirty_two)
		port map( clk =>  clock,
	      		rst   =>  reset,
	     		clken =>  clkEn,
			din   =>  RdMemDataMEM,
			q     =>  RdMemDataOutWB);

ALUresultFlopOutWB:	entity work.dflop(behavior)
		generic map( SIZE => thirty_two)
		port map( clk =>  clock,
	      		rst   =>  reset,
	     		clken =>  clkEn,
			din   =>  ALUResultMEM,
			q     =>  ALUResultOutWB);

wrAddrFlopOutWB: entity work.dflop(behavior)
		generic map( SIZE => five)
		port map( clk =>  clock,
	      		rst   =>  reset,
	     		clken =>  clkEn,
			din   =>  wrAddrMEM,
			q     =>  wrAddrOutWB);



end architecture structure;






