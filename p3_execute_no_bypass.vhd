
library ieee;
use ieee.std_logic_1164.all;

-- This component uses the following designs:
	-- Multiplexors, 3to1 and 4to1 (Files: mux_4to1, from Lab)
	-- 32bit_ALU (File: peregrine_alu_struct)
	-- Register file (Files: arf32_config, arf32, dec_3to8, arf8, mux_8to1, dflop, from Lab 8)
	

entity p3_execute_no_bypass is
  port(	--Inputs
	--	clock, reset:               in	std_logic;
	--	RegWrEn_InEXE:              in  std_logic;
	--	RegWrDataSrc_InEXE:         in  std_logic;
	--	MemWrite_InEXE:             in  std_logic;
		ALU_OP_InEXE:               in  std_logic_vector(3 downto 0);
		ALUSrc1_InEXE:              in  std_logic_vector(1 downto 0);
		ALUSrc2_InEXE:              in  std_logic_vector(1 downto 0);
		rdData1_InEXE:      	    in	std_logic_vector(31 downto 0);
		rdData2_InEXE:              in	std_logic_vector(31 downto 0);
		Immideate_Extd_InEXE:       in	std_logic_vector(31 downto 0);
		PC_seq_Extd_InEXE:          in	std_logic_vector(31 downto 0);
		Shamt_Extd_InEXE:           in	std_logic_vector(31 downto 0);
		wrAddr_InEXE:               in	std_logic_vector(4 downto 0);
				
		--Outputs
	--	RegWrEn_OutMEM:             out  std_logic;
	--	RegWrDataSrc_OutMEM:        out  std_logic;
	--	MemWrite_OutMEM:            out  std_logic;
		ALU_result_memAdder_OutMEM: out  std_logic_vector(7 downto 0);
		ALU_result_OutMEM:          out  std_logic_vector(31 downto 0);
		rdData2_OutMEM:             out	 std_logic_vector(31 downto 0);
		wrAddr_OutMEM:              out 	std_logic_vector(4 downto 0));
		
end entity p3_execute_no_bypass;

architecture structure of p3_execute_no_bypass is


signal	ALU_x_input:	std_logic_vector(31 downto 0);
signal	ALU_y_input:	std_logic_vector(31 downto 0);
signal ALU_result : std_logic_vector(31 downto 0);

constant one_vector:      std_logic_vector(31 downto 0) := x"00000001";
constant	thirty_two:      positive:= 32;
constant sixteen_vector:  std_logic_vector(31 downto 0) := x"00000010";
constant	zero_vector:	    std_logic_vector(31 downto 0) := (others=> '0');

begin

--Multiplexors
-- Select input to be sent to the ALU as X
ALU_src1: entity work.mux_4to1(behavior) 
	generic map( SIZE=> thirty_two)
	port map(w0=> rdData1_InEXE,          --input
				w1  => sixteen_vector,                 --constant -- this should be a std_logic vector DONE
				w2  => Shamt_Extd_InEXE,        --input
				w3  => one_vector,                     --constant -- this should be a std_logic_vector DONE
				sel => ALUSrc1_InEXE,           --input
				f   => ALU_x_input);            --signal


-- Select input to be sent to the ALU as Y
ALU_src2: entity work.mux_4to1(behavior)
	generic map( SIZE=> thirty_two)
	port map(w0=> rdData2_InEXE,          --input
		w1  => Immideate_Extd_InEXE,    --input
		w2  => PC_seq_Extd_InEXE,       --input
		w3  => zero_vector,              --constant
		sel => ALUSrc2_InEXE,           --input
		f   => ALU_y_input);            --signal



ALU: entity work.peregrine_alu_struct(structure)
  port map(	x	=>  ALU_x_input,         --signal
		y	=>  ALU_y_input,         --signal
		funct	=>  ALU_OP_InEXE,        --input
		result	=>  ALU_result,          --signal
		NZVC 	=> open);

ALU_result_memAdder_OutMEM  <= ALU_result(7 downto 0);	-- OK, gets floped inside mem.
ALU_result_OutMEM           <= ALU_result; 		-- need flop
rdData2_OutMEM              <= rdData2_InEXE;		-- no flop needed.

--RegWrEn_OutMEM      <= RegWrEn_InEXE;		--control unit., gets flopped there.
--RegWrDataSrc_OutMEM <= RegWrDataSrc_InEXE; 	-- control unit, gets flopped there.
--MemWrite_OutMEM     <= MemWrite_InEXE; 		--control unit, does not get flopped.
wrAddr_OutMEM       <= wrAddr_InEXE;		-- does need flop.

end architecture structure;