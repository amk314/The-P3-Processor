library ieee;
use ieee.std_logic_1164.all;

-- This design impleents the fetch stage of a 5 stage piplined processor
-- This design uses the following design elements and files:
-- mux, 4to1(Files: mux_4to1)
-- 8 bit adder(Files: cla_8bit, cla_2bit, clg_2bit, lab5)
-- instruction memory (Files: InstructionROM.vhd, InstructionROM.mif)
-- flops (Files: dflop, lab 8)


entity p3_fetch_no_bypass is

port(	--inputs
		clock:				in		std_logic;
		reset:				in		std_logic;
		clockEn:			in		std_logic;
		PCSrc_Fetch_IN:			in		std_logic_vector(1 downto 0);
		rdData1_Fetch_IN:		in		std_logic_vector(7 downto 0);
		immediate_Fetch_IN:		in		std_logic_vector(7 downto 0);
		PCBranch_Fetch_IN:		in		std_logic_vector(7 downto 0);
		
		--outputs
		PC_Seq_Decode_OUT:		out	std_logic_vector(7 downto 0);
		instruction_Decode_OUT:		out	std_logic_vector(31 downto 0));

end entity p3_fetch_no_bypass;


architecture structure of p3_fetch_no_bypass is

signal	PC_next, PC_present, PC_Seq_Fetch:		std_logic_vector(7 downto 0);
signal	Instruction_Fetch:							std_logic_vector(31 downto 0);

constant	thirty_two:		positive:=32;
constant	eight:	positive:=8;
constant one:		std_logic:='1';
constant zero:		std_logic:='0';
constant one_8bit:	std_logic_vector(7 downto 0):="00000001";

begin

PCMux: entity work.mux_4to1(behavior)
	generic map( SIZE=> eight)
	port map( w0 => PC_Seq_Fetch,
				w1 => rdData1_Fetch_IN,
				w2 => PCBranch_Fetch_IN,
				w3 => Immediate_Fetch_IN,
				sel => PCSrc_Fetch_IN,
				f => PC_next);

PCIncrementer: entity work.cla_8bit(structure)
	port map(x => PC_present,
				y => one_8bit,
				cin => zero,
				sum => PC_Seq_Fetch,
				cout =>	open,
				GG => open,
				GA => open);
				
InstructionMem: ENTITY work.instructionROM(syn)
	PORT MAP(address => PC_next,
				clken	=> clockEn,
				clock	=> clock,
				q => Instruction_Fetch);

-- flops for PC	 'shadow PC'
flop : process(reset, clock) is
	begin
		if reset = '1' then 
			PC_present <= (others => '1');
		elsif rising_edge(clock) then
			if clockEn = '1' then
				PC_present <= PC_next;
			end if;
		end if;
	end process flop;			
--Flop_Shadow: entity work.dflop(behavior)
--	generic map( SIZE => eight)
--	port map(clk => clock,
--				rst => reset, --asynchronous
--				clken => ClockEn,
--				din => PC_next,
--				q => PC_present);
--
----flops for pipelined PC
Flop_PC: entity work.dflop(behavior)
	generic map( SIZE => eight)
	port map(clk => clock,
				rst => reset, --asynchronous
				clken => ClockEn,
				din => PC_Seq_Fetch,
				q => PC_Seq_Decode_OUT);
				
--flops for pipelined instruction				
Flop_instruction: entity work.dflop(behavior)
	generic map( SIZE => thirty_two)
	port map(clk => clock,
				rst => reset, --asynchronous
				clken => ClockEn,
				din => Instruction_Fetch,
				q => Instruction_Decode_OUT);

end architecture structure;