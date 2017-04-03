library ieee;
use ieee.std_logic_1164.all;

entity p3_core_no_bypass is

port(clk, rst, clkEn:		in		std_logic);

end entity p3_core_no_bypass;

architecture structure of p3_core_no_bypass is

--Signals originating in FETCH Stage
signal instruction_FETCHtoDEC:		std_logic_vector(31 downto 0);
signal PC_seq_FETCHtoDEC:				std_logic_vector(7 downto 0);

--Signals originating in the MCU
signal PCSrc_MCUtoMCUPipe:				std_logic_vector(1 downto 0);
signal ComprSrc_MCUtoMCUPipe:			std_logic_vector(0 downto 0);
signal wrAddrSrc_MCUtoMCUPipe:		std_logic_vector(1 downto 0);
signal ExtndOp_MCUtoMCUPipe:			std_logic_vector(0 downto 0);
signal AluSrc1_MCUtoMCUPipe:			std_logic_vector(1 downto 0);
signal AluSrc2_MCUtoMCUPipe:			std_logic_vector(1 downto 0);
signal AluOp_MCUtoMCUPipe:				std_logic_vector(3 downto 0);
signal MemWrEn_MCUtoMCUPipe:			std_logic_vector(0 downto 0);
signal RegWrDataSrc_MCUtoMCUPipe:	std_logic_vector(0 downto 0);
signal RegWrEn_MCUtoMCUPipe:			std_logic_vector(0 downto 0);


--Signals originating in MCU Pipeline
signal PCSrc_MCUPipetoFETCH:			std_logic_vector(1 downto 0);

signal wrAddrSrc_MCUPipetoDEC:		std_logic_vector(1 downto 0);
signal extend_Option_MCUPipetoDEC:	std_logic_vector(0 downto 0);
signal compareSrc_MCUPipetoDEC:		std_logic_vector(0 downto 0);

signal AluSrc1_MCUPipetoEXE:			std_logic_vector(1 downto 0);
signal AluSrc2_MCUPipetoEXE:			std_logic_vector(1 downto 0);
signal AluOp_MCUPipetoEXE:				std_logic_vector(3 downto 0);

signal MemWrEn_MCUPipetoMEM:			std_logic_vector(0 downto 0);

signal RegwrEN_MCUPipetoWB:			std_logic_vector(0 downto 0);
signal RegwrDataSrc_MCUPipetoWB:		std_logic_vector(0 downto 0);

--Signals originating in Decode stage
signal rdData1_DECtoFETCH:				std_logic_vector(7 downto 0);
signal immediate_DECtoFETCH:			std_logic_vector(7 downto 0);
signal PCBranch_DECtoFETCH:			std_logic_vector(7 downto 0);

signal z_GSE_DECtoMCU:					std_logic_vector(2 downto 0);
signal Funct_DECtoMCU:					std_logic_vector(5 downto 0);
signal OPCode_DECtoMCU:					std_logic_vector(5 downto 0);
signal rt_lsb_DECtoMCU:					std_logic;

signal rdData1_DECtoEXE:				std_logic_vector(31 downto 0);
signal rdData2_DECtoEXE:				std_logic_vector(31 downto 0);
signal Immideate_Extd_DECtoEXE:		std_logic_vector(31 downto 0);
signal Shamt_Extd_DECtoEXE:			std_logic_vector(31 downto 0);
signal PC_seq_Extd_DECtoEXE:			std_logic_vector(31 downto 0);
signal wrAddr_DECtoEXE:					std_logic_vector(4 downto 0);

--Signals originating in Execution Stage
--signal MemWrite_:             std_logic;
signal ALU_result_memAdder_EXEtoMEM:  std_logic_vector(7 downto 0);
signal ALU_result_EXEtoMEM:           std_logic_vector(31 downto 0);
signal rdData2_EXEtoMEM:             	std_logic_vector(31 downto 0);
signal wrAddr_EXEtoMEM:               std_logic_vector(4 downto 0);


--Signals originating in Memory Stage		
signal wrAddr_MEMtoWB:							std_logic_vector(4 downto 0);
signal result_MEMtoWB:							std_logic_vector(31 downto 0);
signal rdMemData_MEMtoWB:						std_logic_vector(31 downto 0);

begin

---------------------------------------------------------------------------
-- Fetch Stage
---------------------------------------------------------------------------
Fetch: entity work.p3_fetch_no_bypass(structure)
	port map(	--inputs
				clock => clk,
				reset => rst,
				clockEn => clkEn,
				PCSrc_Fetch_IN => PCSrc_MCUPipetoFETCH,
				rdData1_Fetch_IN => rdData1_DECtoFETCH,
				immediate_Fetch_IN => immediate_DECtoFETCH,
				PCBranch_Fetch_IN => PCBranch_DECtoFETCH,
		
				--outputs
				PC_Seq_Decode_OUT => PC_seq_FETCHtoDEC,
				instruction_Decode_OUT => Instruction_FETCHtoDEC);
				
---------------------------------------------------------------------------
--Decode Stage
---------------------------------------------------------------------------
Decode: entity work.p3_decode_wb_no_bypass(structure)
	port map(	--Inputs
				clock => clk,
				reset => rst,
				clockEN => clkEn,
				Instruction_Decode_IN => Instruction_FETCHtoDEC,
				PC_seq_Decode_IN => PC_seq_FETCHtoDEC,
			
				wrAddrSrc_Decode_IN => wrAddrSrc_MCUPipetoDEC,
				extend_Option_Decode_IN => extend_Option_MCUPipetoDEC(0),
				compareSrc_Decode_IN => compareSrc_MCUPipetoDEC(0),
			
				wrAddr_WB_IN => wrAddr_MEMtoWB,
				wrEN_WB_IN => RegWrEN_MCUPipetoWB(0),
				result_WB_IN => result_MEMtoWB,
				rdMemData_WB_IN => rdMemData_MEMtoWB,
				wrDataSrc_WB_IN => RegWrDataSrc_MCUPipetoWB(0),
		
				--Outputs
				-- To execution stage
				rdData1_EXE_OUT => rdData1_DECtoEXE,
				rdData2_EXE_OUT => rdData2_DECtoEXE,
				Immideate_Extd_EXE_OUT => Immideate_Extd_DECtoEXE,
				Shamt_Extd_EXE_OUT => Shamt_Extd_DECtoEXE,
				PC_seq_Extd_EXE_OUT => PC_Seq_Extd_DECtoEXE,
				wrAddr_EXE_OUT => wrAddr_DECtoEXE,
		
				-- to fetch stage
				rdData1_Fetch_OUT => rdData1_DECtoFETCH,
				PC_Branch_Fetch_OUT => PCBranch_DECtoFETCH,
				immediate_Fetch_OUT => Immediate_DECtoFETCH,

				-- to main control unit
				z_GSE_Control_OUT => z_GSE_DECtoMCU,
				Funct_Control_OUT => Funct_DECtoMCU,
				OPCode_Control_OUT => OpCode_DECtoMCU,
				rt_lsb_Control_OUT => rt_lsb_DECtoMCU);

---------------------------------------------------------------------------
--Execute Stage
---------------------------------------------------------------------------
Execute: entity work.p3_execute_no_bypass(structure)
  port map(	--Inputs
				--MemWrite_InEXE => MemWrEn_MCUPipeto
				ALU_OP_InEXE => AluOp_MCUPipetoEXE,
				ALUSrc1_InEXE => AluSrc1_MCUPipetoEXE,
				ALUSrc2_InEXE => AluSrc2_MCUPipetoEXE,
				rdData1_InEXE => rdData1_DECtoEXE,
				rdData2_InEXE => rdData2_DECtoEXE,
				Immideate_Extd_InEXE => Immideate_Extd_DECtoEXE,
				PC_seq_Extd_InEXE => PC_seq_Extd_DECtoEXE,
				Shamt_Extd_InEXE => Shamt_Extd_DECtoEXE,
				wrAddr_InEXE => WrAddr_DECtoEXE,
				
				--Outputs
				--MemWrite_OutMEM =
				ALU_result_memAdder_OutMEM => ALU_result_memAdder_EXEtoMEM,
				ALU_result_OutMEM => ALU_result_EXEtoMEM,
				rdData2_OutMEM => rdData2_EXEtoMEM,
				wrAddr_OutMEM => wrAddr_EXEtoMEM);

---------------------------------------------------------------------------
--Memory Stage
---------------------------------------------------------------------------
Memory:entity work.p3_mem_no_bypass(structure)
  port map(	--Inputs
				clock => clk,
				reset => rst,
				clkEn => clkEn,
				MemWriteInMEM => MemWrEn_MCUPipetoMEM,
				ALUResultMemAdderOutMEM => ALU_result_memAdder_EXEtoMEM,
				ALUResultInMEM => ALU_result_EXEtoMEM,
				rdData2InMEM => rdData2_EXEtoMEM,
				wrAddrInMEM => wrAddr_EXEtoMEM,

				--Outputs
				RdMemDataOutWB => rdMemData_MEMtoWB,
				ALUResultOutWB => result_MEMtoWB,
				wrAddrOutWB => wrAddr_MEMtoWB);

---------------------------------------------------------------------------
--MCU
---------------------------------------------------------------------------
MainControl: entity work.p3_mcu_no_bypass(behavior)
	port map(	--inputs
				OpCode_Control_IN => OpCode_DECtoMCU,
				z_GSE_Control_IN => z_GSE_DECtoMCU,
				Funct_Control_IN => Funct_DECtoMCU,
				rt_lsb_Control_IN => rt_lsb_DECtoMCU,
		
				--outputs
				PCSrc_pipe_OUT => PCSrc_MCUtoMCUPipe,
				ComprSrc_pipe_OUT => ComprSrc_MCUtoMCUPipe(0),
				wrAddrSrc_pipe_OUT => wrAddrSrc_MCUtoMCUPipe,
				ExtndOp_pipe_OUT => ExtndOp_MCUtoMCUPipe(0),
				AluSrc1_pipe_OUT => AluSrc1_MCUtoMCUPipe,
				AluSrc2_pipe_OUT => AluSrc2_MCUtoMCUPipe,
				AluOp_pipe_OUT => AluOp_MCUtoMCUPipe,
				MemWrEn_pipe_OUT => MemWrEn_MCUtoMCUPipe(0),
				RegWrDataSrc_pipe_OUT => RegWrDataSrc_MCUtoMCUPipe(0),
				RegWrEn_pipe_OUT => RegWrEn_MCUtoMCUPipe(0));


---------------------------------------------------------------------------
--MCU Pipe
---------------------------------------------------------------------------
ControlPipe: entity work.p3_piped_mcu_no_bypass(structure)
	port map(
				clock => clk,
				reset => rst,
				clockEn=> clkEn,
	
				PCSrc_pipe_IN => PCSrc_MCUtoMCUPipe,
				ComprSrc_pipe_IN => ComprSrc_MCUtoMCUPipe,
				wrAddrSrc_pipe_IN => wrAddrSrc_MCUtoMCUPipe,
				ExtndOp_pipe_IN => ExtndOp_MCUtoMCUPipe,
				AluSrc1_pipe_IN => AluSrc1_MCUtoMCUPipe,
				AluSrc2_pipe_IN => AluSrc2_MCUtoMCUPipe,
				AluOp_pipe_IN => AluOp_MCUtoMCUPipe,
				MemWrEn_pipe_IN => MemWrEn_MCUtoMCUPipe,
				RegWrDataSrc_pipe_IN => RegWrDataSrc_MCUtoMCUPipe,
				RegWrEn_pipe_IN => RegWrEn_MCUtoMCUPipe,
			
				PCSrc_Fetch_OUT => PCSrc_MCUPipetoFETCH,
				ComprSrc_Decode_OUT => CompareSrc_MCUPipetoDEC,
				wrAddrSrc_Decode_OUT => wrAddrSrc_MCUPipetoDEC,
				ExtndOp_Decode_OUT => Extend_Option_MCUPipetoDEC,
				AluSrc1_EXE_OUT => AluSrc1_MCUPipetoEXE,
				AluSrc2_EXE_OUT => AluSrc2_MCUPipetoEXE,
				AluOp_EXE_OUT => AluOp_MCUPipetoEXE,
				MemWrEn_MEM_OUT => MemWrEn_MCUPipetoMEM,
				RegWrDataSrc_WB_OUT => RegWrDataSrc_MCUPipetoWB,
				RegWrEn_WB_OUT => RegWrEN_MCUPipetoWB);

end architecture structure;