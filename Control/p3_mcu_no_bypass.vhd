library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This component behaviorally models the control signals of the perigrine processor.

entity p3_mcu_no_bypass is

port(	--inputs
		OpCode_Control_IN:	in		std_logic_vector(5 downto 0);
		z_GSE_Control_IN:		in		std_logic_vector(2 downto 0);
		Funct_Control_IN:		in		std_logic_vector(5 downto 0);
		rt_lsb_Control_IN:	in		std_logic;
		
		--outputs
		PCSrc_pipe_OUT:			out	std_logic_vector(1 downto 0);
		ComprSrc_pipe_OUT:		out	std_logic;
		wrAddrSrc_pipe_OUT:		out	std_logic_vector(1 downto 0);
		ExtndOp_pipe_OUT:			out	std_logic;
		AluSrc1_pipe_OUT:			out	std_logic_vector(1 downto 0);
		AluSrc2_pipe_OUT:			out	std_logic_vector(1 downto 0);
		AluOp_pipe_OUT:			out	std_logic_vector(3 downto 0);
		MemWrEn_pipe_OUT:			out	std_logic;
		RegWrDataSrc_pipe_OUT:	out	std_logic;
		RegWrEn_pipe_OUT:			out	std_logic);

end entity p3_mcu_no_bypass;

architecture behavior of p3_mcu_no_bypass is

signal OpCd_Funct:		std_logic_vector(11 downto 0);
signal OpCd_GSE_Funct:	std_logic_vector(14 downto 0);
signal OpCd_GSE_rt:		std_logic_vector(9 downto 0);

signal Branch:			std_logic;
signal Branch_Condition: 	std_logic;
signal Branch_mux_control:	std_logic;
signal Branch_PC_src:		std_logic_vector(1 downto 0);


signal Jump:			std_logic_vector(1 downto 0);


--signal JmpBrnchInc:		std_logic_vector(2 downto 0);

--alias jump: std_logic is JmpBrnchInc(2);
--alias jumpR: std_logic is JmpBrnchInc(0);
--alias branch: std_logic is JmpBrnchInc(1);
--alias increment: std_logic is JmpBrnchInc(0);

begin

OpCd_Funct <= OpCode_Control_IN&Funct_Control_IN;
--OpCd_GSE_Funct <= Opcode_Control_IN&z_GSE_Control_IN&Funct_Control_IN;
OpCd_GSE_rt <= OpCode_Control_IN&z_GSE_Control_IN&rt_lsb_Control_IN;

Jump <= 	"11" when OpCode_Control_IN = "000010" else -- op code 2
		"11" when OpCode_Control_IN = "000011" else -- op code 3
		"01" when OpCd_Funct = "000000001000" else -- op code 0, funct 8
		"01" when OpCd_Funct = "000000001001" else -- op code 0, funct 9
		"00";

Branch <= 	'1' when OpCode_Control_IN = "000100" else -- op code 4
		'1' when OpCode_Control_IN = "000101" else -- op code 5
		'1' when OpCode_Control_IN = "000001" else -- op code 1
		'1' when OpCode_Control_IN = "000110" else -- op code 6
		'1' when OpCode_Control_IN = "000111" else -- op code 7
		'0';

Branch_Condition <= z_GSE_Control_IN(0) when OpCode_Control_IN = "000100" else -- BEQ
		not(z_GSE_Control_IN(0)) when OpCode_Control_IN = "000101" else -- BNE
		(z_GSE_Control_IN(2) OR z_GSE_Control_IN(0)) when OPCode_Control_IN&rt_lsb_Control_IN = "0000011" else -- BGEZ
		z_GSE_Control_IN(2) when OpCode_Control_IN = "000111" else -- BGTZ
		(z_GSE_Control_IN(1) OR z_GSE_Control_IN(0)) when OpCode_Control_IN = "000110" else -- BLEZ
		z_GSE_Control_IN(1) when OpCode_Control_IN&rt_lsb_Control_IN = "0000010" else -- BLTZ
		'0';

Branch_Mux_Control <= Branch AND Branch_Condition;

Branch_PC_src <= "00" when Branch_Mux_Control = '0' else
		"10";

PCSrc_pipe_OUT <= Branch_PC_src when Jump = "00" else
		Jump;

--Jump <= 	'1' when OpCode_Control_IN = "000010" else -- op code 2
--			'1' when OpCode_Control_IN = "000011" else -- op code 3
--			'0';
--
--JumpR <= '1' when OpCd_Funct = "000000001000" else -- op code 0, funct 8
--			'1' when OpCd_Funct = "000000001001" else -- op code 0, funct 9
--			'0';
--			
--Branch <= 	'1' when std_match(OpCd_GSE_rt, "000100001-") else -- op code 4, z_gse = 001, rt d
--				'1' when std_match(OpCd_GSE_rt, "000101--0-") else -- op code 5, z_gse(0) = 0, rt d
--				'1' when OpCd_GSE_rt = "0000011001" else -- op code 1, z_gse = 100 , rt 1
--				'1' when OpCd_GSE_rt = "0000010011" else -- op code 1, z_gse = 001, rt 1
--				'1' when OpCd_GSE_rt = "0000010100" else -- op code 1, z_gse = 010, rt 0
--				'1' when std_match(OpCd_GSE_rt, "000110010-") else -- op code 6, z_gse = 010, rt d
--				'1' when std_match(OpCd_GSE_rt, "000110001-") else -- op code 6, z_gse = 001, rt d
--				'1' when std_match(OpCd_GSE_rt, "000111100-") else -- op code 7, z_gse = 100, rt d
--				'0';
--
----Increment <= 	'1' when OpCode_Control_IN = "000000" else -- op code 0
--					'1' when OpCode_Control_IN = "001000" else -- op code 8
--					'1' when OpCode_Control_IN = "001001" else -- op code 9
--					'1' when OpCode_Control_IN = "001010" else -- op code 10
--					'1' when OpCode_Control_IN = "001011" else -- op code 11
--					'1' when OpCode_Control_IN = "001100" else -- op code 12
--					'1' when OpCode_Control_IN = "001101" else -- op code 13
--					'1' when OpCode_Control_IN = "001110" else -- op code 14
--					'1' when OpCode_Control_IN = "001111" else -- op code 15
--					'1' when OpCode_Control_IN = "100011" else -- op code 35
--					'1' when OpCode_Control_IN = "101011" else -- op code 43
--					'0';

--PCSrc_pipe_OUT <= "11" when std_match(JmpBrnchInc, "1--") else -- jump
--						"01" when JmpBrnchInc = "001" else -- jumpR
--						"10" when JmpBrnchInc = "01-" else -- branch
--						"00"; -- increment
						
--						"01" when OpCd_Funct = "000000001000" else -- op code 0, funct 8, JR
--						"01" when OpCd_Funct = "000000001001" else -- op code 0, funct 9, JALR
--						
--						"10" when branch = '1' else
--						
--						"11" when std_match(OpCd_GSE_Funct, "000010---------") else -- op code 2, funct d, J
--						"11" when std_match(OpCd_GSE_Funct, "000011---------") else -- op code 3, funct d, JAL
--						
--						"00";
						
ComprSrc_pipe_OUT <= '1' when OpCode_Control_IN = "000100" else -- op code 4
							'1' when OpCode_Control_IN = "000101" else -- op code 5
							
							'0';
							
wrAddrSrc_pipe_OUT <="10" when OpCode_Control_IN = "000011" else -- op code 3 (JAL)
							"01" when OpCode_Control_IN = "000000" else -- op code 0 (all R format instructions)
							"00";
							
ExtndOp_pipe_OUT <= 	'0' when OpCode_Control_IN = "000000" else -- op code 0	
							'0' when Opcode_Control_IN = "001011" else -- op code 11
							'0' when OpCode_Control_IN = "001100" else -- op code 12
							'0' when Opcode_Control_IN = "001101" else -- op code 13
							'0' when Opcode_Control_IN = "001110" else -- op code 14
							
							'1';

AluSrc1_pipe_OUT <= 	"11" when std_match(OPCd_Funct, "000011------") else -- op code 3, funct d
							"11" when OpCd_Funct = "000000001001" else -- op code 0, funct 9
							
							"10" when OpCd_Funct = "000000000000" else -- op code 0, funct 0
							"10" when OpCd_Funct = "000000000010" else -- op code 0, funct 2
							"10" when Opcd_Funct = "000000000011" else -- op code 0, funct 3
							
							"01" when std_match(OpCd_Funct, "001111------") else -- op code 15, funct d
							
							"00";

AluSrc2_pipe_OUT <= 	"10" when std_match(OPCd_Funct, "000011------") else -- op code 3, funct d
							"10" when OpCd_Funct = "000000001001" else -- op code 0, funct 9
							
							"00" when std_match(OpCd_Funct, "000000------") else -- op code 0, funct d
							"00" when std_match(OpCd_Funct, "000100------") else -- op code 4, funct d
							"00" when std_match(OpCd_Funct, "000101------") else -- op code 5, funct d
							
							"01";

AluOp_pipe_OUT <= -- And Functions
						x"0" when OpCd_Funct = "000000100100" else -- op code 0, funct 36(24 hex)
						x"0" when std_match(OpCd_Funct, "001100------") else -- op code 12 (c hex), funct d
						
						-- Or Functions
						x"1" when OpCd_Funct = "000000100101" else -- op code 0, funct 37 (25 hex)
						x"1" when std_match(OpCd_Funct, "001101------") else -- op code 13 (d hex), funct d
						
						-- Xor Functions
						x"2" when OpCd_Funct = "000000100110" else -- op code 0, funct 38 (26 hex)
						x"2" when std_match(OpCd_Funct, "001110------") else -- op code 14 (e hex), funct d
						
						-- Nor Functions
						x"3" when OPCd_Funct = "000000100111" else -- op code 0, funct 39 (27 hex)
						
						-- Add Unsigned Functions
						x"4" when Opcd_Funct = "000000100001" else -- op code 0, funct 33 (21 hex)
						x"4" when std_match(OpCd_Funct, "001001------") else -- op code 9, funct d
						
						-- Subtract Unsigned Functions
						x"6" when OpCd_Funct = "000000100011" else -- op code 0, funct 35 (23 hex)
						
						-- Subtract Functions
						x"7" when OpCd_Funct = "000000100010" else -- op code 0, funct 34 (22 hex)
						
						-- Set Less Than Unsigned Functions
						x"a" when OpCd_Funct = "000000101011" else -- op code 0, funct 43 (2b hex)
						x"a" when std_match(OpCd_Funct, "001011------") else -- op code 11, funct d
						
						-- Set Less Than Functions
						x"b" when OpCd_Funct = "000000101010" else -- op code 0, funct 11 (b hex)
						x"b" when std_match(OpCd_Funct, "001010------") else -- op code 10 (a hex), funct d
						
						-- Shift Logical Left Functions
						x"c" when OpCd_Funct = "000000000000" else -- op code 0, funct 0
						x"c" when OpCd_Funct = "000000000100" else -- op code 0, funct 4
						x"c" when std_match(OpCd_Funct, "001111") else -- op code 15 (f hex), funct d
						
						-- Shift Right Logical Functions
						x"e" when OpCd_Funct = "000000000010" else -- op code 0, funct 2
						x"e" when OpCd_Funct = "000000000110" else -- op code 0, funct 6
						
						-- Shift Right Arithmetic Functions
						x"f" when OpCd_Funct = "000000000011" else -- op code 0, funct 3
						x"f" when OpCd_Funct = "000000000111" else -- op code 0, funct 7
						
						-- Add Functions
						x"5";
						

MemWrEn_pipe_OUT <= 	'1' when opCode_Control_IN = "101011" else -- op code 43 (store word)
							'0';

RegWrDataSrc_pipe_OUT <=	'0' when opCode_Control_IN = "100011" else -- op code 35 (load word)
									'1';

RegWrEn_pipe_OUT <= 	'0' when opCd_Funct = "000000001000" else	-- op code 0, funct 8 (jump register)
							'0' when std_match(opCd_Funct, "000010------") else -- op code 2, funct d
							'0' when std_match(opCd_Funct, "000001------") else -- op code 1, funct d
							'0' when std_match(opCd_Funct, "000100------") else -- op code 4, funct d
							'0' when std_match(Opcd_Funct, "000101------") else -- op code 5, funct d
							'0' when std_match(OpCd_Funct, "000110------") else -- op code 6, funct d
							'0' when std_match(OpCd_Funct, "000111------") else -- op code 7, funct d
							'0' when std_match(OpCd_Funct, "101011------") else -- op code 43, funct d
							
							'1';

end architecture behavior;