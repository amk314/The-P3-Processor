library ieee;
use ieee.std_logic_1164.all;

-- This component uses the following designs:
	-- Comparator (Files: btc_32bit, btc_8bit,cpc_2bit, from Lab 4)
	-- Bit Extnsion Unit (Files: elu, from Lab3)
	-- Multiplexors, 2to1 and 3to1 (Files: mux_2to1, from Lab3)
	-- 8 bit Adder(Files: cla_8bit, cla_2bit, clg_2bit, from Lab 5 & Lab 1)
	-- Register file (Files: arf32_config, arf32, dec_3to8, arf8, mux_8to1, dflop, from Lab 8)
	-- Control Unit (Files: )
	-- flops (Files: dflop, from Lab 8)

entity p3_decode_wb_no_bypass is

port(	--Inputs
		clock, reset, clockEN:		in		std_logic;
		Instruction_Decode_IN: 		in		std_logic_vector(31 downto 0);
		PC_seq_Decode_IN:				in		std_logic_vector(7 downto 0);
		wrAddrSrc_Decode_IN:			in		std_logic_vector(1 downto 0);
		extend_Option_Decode_IN:	in		std_logic;
		compareSrc_Decode_IN:		in		std_logic;
		
		wrAddr_WB_IN:					in		std_logic_vector(4 downto 0);
		--wrData_WB_IN:					in		std_logic_vector(31 downto 0);
		wrEN_WB_IN:						in		std_logic;
		result_WB_IN:					in		std_logic_vector(31 downto 0);
		rdMemData_WB_IN:				in		std_logic_vector(31 downto 0);
		wrDataSrc_WB_IN:				in		std_logic;
		
		--Outputs
		-- To execution stage
		rdData1_EXE_OUT:			out	std_logic_vector(31 downto 0);
		rdData2_EXE_OUT:			out	std_logic_vector(31 downto 0);
		Immideate_Extd_EXE_OUT:	out	std_logic_vector(31 downto 0);
		Shamt_Extd_EXE_OUT:		out	std_logic_vector(31 downto 0);
		PC_seq_Extd_EXE_OUT:		out	std_logic_vector(31 downto 0);
		wrAddr_EXE_OUT:			out	std_logic_vector(4 downto 0);
		
		-- to fetch stage
		rdData1_Fetch_OUT:		out	std_logic_vector(7 downto 0);
		PC_Branch_Fetch_OUT:		out	std_logic_vector(7 downto 0);
		immediate_Fetch_OUT:		out	std_logic_vector(7 downto 0);

		-- to main control unit
		z_GSE_Control_OUT:		out	std_logic_vector(2 downto 0);
		Funct_Control_OUT:		out	std_logic_vector(5 downto 0);
		OPCode_Control_OUT:		out	std_logic_vector(5 downto 0);
		rt_lsb_Control_OUT:		out	std_logic);

end entity p3_decode_wb_no_bypass;

architecture structure of p3_decode_wb_no_bypass is

signal	compare_x_input:	std_logic_vector(31 downto 0);
signal	rdData1_Decode:	std_logic_vector(31 downto 0);
signal	rdData2_Decode:	std_logic_vector(31 downto 0);
signal	Immideate_Extd_Decode:	std_logic_vector(31 downto 0);
signal	Shamt_Extd_Decode:		std_logic_vector(31 downto 0);
signal	PC_seq_Extd_Decode:		std_logic_vector(31 downto 0);
signal	wrAddr_Decode:				std_logic_vector(4 downto 0);

signal	wrData_WB:					std_logic_vector(31 downto 0);

constant	thirty_two:		positive:= 32;
constant sixteen:			positive:= 16;
constant	five:				positive:= 5;
constant	eight:			positive:= 8;
constant	zero_vector:	std_logic_vector(31 downto 0):= (others=> '0');
constant zero:				std_logic:= '0';
constant	reg_32_addr:	std_logic_vector(4 downto 0):= (others=> '1');

begin

--Send instruciton op code and function code out of decode to main unit to be sent to control unit
Funct_Control_OUT <= Instruction_Decode_IN(5 downto 0);
OPCode_Control_OUT <= Instruction_Decode_IN(31 downto 26);
rt_lsb_Control_OUT <= Instruction_Decode_IN(16);

--Comparator
Branch_Comparisons: entity work.btc_32bit(structure)
	generic map(SIGNED_OPS=> true)
	port map(x=> rdData1_Decode, --compare_x_input,
				y=> compare_x_input, --rdData1_Decode,
				z_GSE=> z_GSE_Control_OUT);

-- Extnsion Logic Unit
-- Extend Immediate instruction bits from 16 to 32
imm_exntd: entity work.elu(dataflow)
	generic map(ISIZE=> sixteen,
					OSIZE=> thirty_two)
	port map(A=> Instruction_Decode_IN(15 downto 0),
				twos_cmp=> extend_Option_Decode_IN,
				Y=> Immideate_Extd_Decode);
				
-- Extnsion Logic Unit
-- Extend shift amount (shamt) from 5 bits to 32
shamtExtd: entity work.elu(dataflow)
	generic map(ISIZE=> five,
					OSIZE=> thirty_two)
	port map(A=> Instruction_Decode_IN(10 downto 6),
				twos_cmp=> zero,
				Y=> Shamt_Extd_Decode);
				
-- Extnsion Logic Unit
-- Extend PC_Seq from 8 bits to 32 bits
pcExtd: entity work.elu(dataflow)
	generic map(ISIZE=> eight,
					OSIZE=> thirty_two)
	port map(A=> PC_seq_Decode_IN,
				twos_cmp=> zero,
				Y=> PC_seq_Extd_Decode);

--Adder/Subtractor for PC branches
PCAddrCalc: entity work.cla_8bit(structure)
	port map(x=> PC_seq_Decode_IN,
				y=> Instruction_Decode_IN(7 downto 0),
				cin=> zero,
				sum=> PC_Branch_Fetch_OUT,
				cout=> open,
				GG=> open,
				GA=> open);

--Register File, configurable
registers: entity work.arf32_config(mixed)
	generic map(SIZE=> thirty_two,
					r0_HW=> true,
					FWD=> true)
	port map(clk=> clock, 
				rst=> reset,
				wrEn=> wrEN_WB_IN,
				rdAddr1=> Instruction_Decode_IN(25 downto 21),
				rdAddr2=> Instruction_Decode_IN(20 downto 16),
				wrAddr=> wrAddr_WB_IN,
				wrData=> wrData_WB,
				rdData1=> rdData1_Decode,
				rdData2=> rdData2_Decode);
				
rdData1_Fetch_OUT <= rdData1_Decode(7 downto 0);
--rdData2_EXE_OUT <= rdData2_Decode;-- needs to be a flop

--Multiplexors
-- Select input to be sent to the comparator
CompMux: entity work.mux_2to1(mixed) 
	generic map( SIZE=> thirty_two)
	port map(w0=> zero_vector,
				w1=> rdData2_Decode,
				s=> compareSrc_Decode_IN,
				f=> compare_x_input);

-- Select Register Write Addres to send into pipeline
WrAddrMux: entity work.mux_4to1(behavior)
	generic map( SIZE=> five)
	port map(w0=> Instruction_Decode_IN(20 downto 16),
				w1=> Instruction_Decode_IN(15 downto 11),
				w2=> Reg_32_addr,
				w3=> zero_vector(4 downto 0),
				sel=> wrAddrSrc_Decode_IN,
				f=> wrAddr_Decode);
				
-- Select data to be written to register during write back stage.
WBMux: entity work.mux_2to1(mixed) 
	generic map( SIZE=> thirty_two)
	port map(w0=> rdMemData_WB_IN,
				w1=> result_WB_IN,
				s=> wrDataSrc_WB_IN,
				f=> wrData_WB);

-- send jump address to fetch component, immediately.
immediate_Fetch_OUT <= Instruction_Decode_IN(7 downto 0);

-- flop rdData1
data1Flop: entity work.dflop(behavior)
	generic map( SIZE => thirty_two)
	port map(clk => clock,
				rst => reset,--asynchronous
				clken => clockEN,
				din => rdData1_Decode,
				q => rdData1_EXE_OUT);
				
--flop rdData2				
data2Flop: entity work.dflop(behavior)
	generic map( SIZE => thirty_two)
	port map(clk => clock,
				rst => reset,--asynchronous
				clken => clockEN,
				din => rdData2_Decode,
				q => rdData2_EXE_OUT);
				
--flop Immidate extedned signal
immFlop: entity work.dflop(behavior)
	generic map( SIZE => thirty_two)
	port map(clk => clock,
				rst => reset,--asynchronous
				clken => clockEN,
				din => Immideate_Extd_Decode,
				q => Immideate_Extd_EXE_OUT);

--flop shamt exntend	
shamtFlop: entity work.dflop(behavior)
	generic map( SIZE => thirty_two)
	port map(clk => clock,
				rst => reset,--asynchronous
				clken => clockEN,
				din => Shamt_Extd_Decode,
				q => Shamt_Extd_EXE_OUT);

--PCSeq Extension Flop				
PCSeqExtdFlop: entity work.dflop(behavior)
	generic map( SIZE => thirty_two)
	port map(clk => clock,
				rst => reset,--asynchronous
				clken => clockEN,
				din => PC_seq_Extd_Decode,
				q => PC_seq_Extd_EXE_OUT);

--wrADDr flop				
wrAddrFlop: entity work.dflop(behavior)
	generic map( SIZE => five)
	port map(clk => clock,
				rst => reset,--asynchronous
				clken => clockEN,
				din => wrAddr_Decode,
				q => wrAddr_EXE_OUT);

end architecture structure;