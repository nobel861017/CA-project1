module CPU
(
    clk_i,
    rst_i,
    start_i
);

// Ports
input   clk_i;
input   rst_i;
input   start_i;

wire [31 : 0] inst;
wire [31 : 0] inst_addr;
wire          branch;
wire          zero;
wire          taken;
wire [31 : 0] imm;
wire [31 : 0] ALU_result;
wire [31 : 0] RTdata;
wire [31 : 0] RDdata;
wire [4 : 0]  EX_MEM_RDaddr;
wire [4 : 0]  MEM_WB_RDaddr;
wire          EX_MEM_RegWrite;
wire          MEM_WB_RegWrite;

Control Control
(
    .Op_i       (inst[6 : 0]),
    .ALUOp_o    (ID_EX.ALUOp_i),
    .ALUSrc_o   (ID_EX.ALUSrc_i),
    .Branch_o   (ID_EX.Branch_i),
    .MemRead_o  (ID_EX.MemRead_i),
    .MemWrite_o (ID_EX.MemWrite_i),
    .RegWrite_o (ID_EX.RegWrite_i),
    .MemtoReg_o (ID_EX.MemtoReg_i)
);

ALU_Control ALU_Control
(
    .funct_i    (ID_EX.inst_o),
    .ALUOp_i    (ID_EX.ALUOp_o),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);

PC PC
(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (MUX_PC.data_o),
    .pc_o       (inst_addr)
);

Adder Add_PC
(
    .data1_i    (inst_addr),
    .data2_i    (32'd4),
    .data_o     (MUX_PC.data1_i)
);

Adder Add_PC_branch
(
    .data1_i    (ID_EX.PC_o),
    .data2_i    (imm << 1),
    .data_o     (EX_MEM.sum_i)
);

And And
(
    .data1_i    (branch),
    .data2_i    (zero),
    .data_o     (taken)
);

MUX32 MUX_PC
(
    .data1_i    (Add_PC.data_o),
    .data2_i    (EX_MEM.sum_o),
    .select_i   (taken),
    .data_o     (PC.pc_i)
);

Instruction_Memory Instruction_Memory
(
    .addr_i     (inst_addr), 
    .instr_o    (IF_ID.inst_i)
);

Registers Registers
(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[19 : 15]),
    .RTaddr_i   (inst[24 : 20]),
    .RDaddr_i   (MEM_WB_RDaddr), 
    .RDdata_i   (RDdata),
    .RegWrite_i (MEM_WB_RegWrite), 
    .RSdata_o   (ID_EX.RSdata_i),
    .RTdata_o   (ID_EX.RTdata_i) 
);

Sign_Extend Sign_Extend
(
    .data_i     (inst),
    .data_o     (ID_EX.imm_i)
);

MUX3 MUX_ALU_data1
(
	.data1_i  (ID_EX.RSdata_o),
	.data2_i  (RDdata),
	.data3_i  (ALU_result),
	.select_i (Forward.select1_o),
	.data_o   (ALU.data1_i)
);

MUX3 MUX_ALU_data2
(
	.data1_i  (ID_EX.RTdata_o),
	.data2_i  (RDdata),
	.data3_i  (ALU_result),
	.select_i (Forward.select2_o),
	.data_o   (RTdata)
);

MUX32 MUX_ALUSrc
(
    .data1_i    (RTdata),
    .data2_i    (imm),
    .select_i   (ID_EX.ALUSrc_o),
    .data_o     (ALU.data2_i)
);

ALU ALU
(
    .data1_i    (MUX_ALU_data1.data_o),
    .data2_i    (MUX_ALUSrc.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (EX_MEM.ALUResult_i),
    .Zero_o     (EX_MEM.zero_i)
);

Data_Memory Data_Memory
(
    .clk_i      (clk_i),
    .MemWrite_i (EX_MEM.MemWrite_o),
    .MemRead_i  (EX_MEM.MemRead_o),
    .addr_i     (ALU_result),
    .data_i     (EX_MEM.RTdata_o),
    .data_o     (MEM_WB.mem_i)
);

MUX32 MUX_MemtoReg
(
    .data1_i    (MEM_WB.ALUResult_o),
    .data2_i    (MEM_WB.mem_o),
    .select_i   (MEM_WB.MemtoReg_o),
    .data_o     (RDdata)
);

IF_ID IF_ID
(
	.clk_i  (clk_i),
	.PC_i   (inst_addr),
	.PC_o   (ID_EX.PC_i),
	.inst_i (Instruction_Memory.instr_o),
	.inst_o (inst)
);

ID_EX ID_EX
(
    .clk_i      (clk_i),
    .PC_i       (IF_ID.PC_o),
    .PC_o       (Add_PC_branch.data1_i),
    .inst_i     (inst),
    .inst_o     (ALU_Control.funct_i),
    .RSdata_i   (Registers.RSdata_o),
    .RSdata_o   (MUX_ALU_data1.data1_i),
    .RTdata_i   (Registers.RTdata_o),
    .RTdata_o   (MUX_ALU_data2.data1_i),
    .imm_i      (Sign_Extend.data_o),
    .imm_o      (imm),
    .RSaddr_i   (inst[19 : 15]),
    .RSaddr_o   (Forward.ID_EX_RSaddr_i),
    .RTaddr_i   (inst[24 : 20]),
    .RTaddr_o   (Forward.ID_EX_RTaddr_i),
    .RDaddr_i   (inst[11 : 7]),
    .RDaddr_o   (EX_MEM.RDaddr_i),
    .ALUOp_i    (Control.ALUOp_o),
    .ALUOp_o    (ALU_Control.ALUOp_i),
    .ALUSrc_i   (Control.ALUSrc_o),
    .ALUSrc_o   (MUX_ALUSrc.select_i),
    .Branch_i   (Control.Branch_o),
    .Branch_o   (EX_MEM.Branch_i),
    .MemRead_i  (Control.MemRead_o),
    .MemRead_o  (EX_MEM.MemRead_i),
    .MemWrite_i (Control.MemWrite_o),
    .MemWrite_o (EX_MEM.MemWrite_i),
    .RegWrite_i (Control.RegWrite_o),
    .RegWrite_o (EX_MEM.RegWrite_i),
    .MemtoReg_i (Control.MemtoReg_o),
    .MemtoReg_o (EX_MEM.MemtoReg_i)
);

EX_MEM EX_MEM
(
    .clk_i       (clk_i),
    .sum_i       (Add_PC_branch.data_o),
    .sum_o       (MUX_PC.data2_i),
    .ALUResult_i (ALU.data_o),
    .ALUResult_o (ALU_result),
    .zero_i      (ALU.Zero_o),
    .zero_o      (zero),
    .RTdata_i    (RTdata),
    .RTdata_o    (Data_Memory.data_i),
    .RDaddr_i    (ID_EX.RDaddr_o),
    .RDaddr_o    (EX_MEM_RDaddr),
    .Branch_i    (ID_EX.Branch_o),
    .Branch_o    (branch),
    .MemRead_i   (ID_EX.MemRead_o),
    .MemRead_o   (Data_Memory.MemRead_i),
    .MemWrite_i  (ID_EX.MemWrite_o),
    .MemWrite_o  (Data_Memory.MemWrite_i),
    .RegWrite_i  (ID_EX.RegWrite_o),
    .RegWrite_o  (EX_MEM_RegWrite),
    .MemtoReg_i  (ID_EX.MemtoReg_o),
    .MemtoReg_o  (MEM_WB.MemtoReg_i)
);

MEM_WB MEM_WB
(
    .clk_i       (clk_i),
    .mem_i       (Data_Memory.data_o),
    .mem_o       (MUX_MemtoReg.data2_i),
    .ALUResult_i (ALU_result),
    .ALUResult_o (MUX_MemtoReg.data1_i),
    .RDaddr_i    (EX_MEM_RDaddr),
    .RDaddr_o    (MEM_WB_RDaddr),
    .RegWrite_i  (EX_MEM_RegWrite),
    .RegWrite_o  (MEM_WB_RegWrite),
    .MemtoReg_i  (EX_MEM.MemtoReg_o),
    .MemtoReg_o  (MUX_MemtoReg.select_i)
);

Forward Forward
(
	.ID_EX_RSaddr_i    (ID_EX.RSaddr_o),
	.ID_EX_RTaddr_i    (ID_EX.RTaddr_o),
	.EX_MEM_RDaddr_i   (EX_MEM_RDaddr),
	.MEM_WB_RDaddr_i   (MEM_WB_RDaddr),
	.EX_MEM_RegWrite_i (EX_MEM_RegWrite),
	.MEM_WB_RegWrite_i (MEM_WB_RegWrite),
	.select1_o         (MUX_ALU_data1.select_i),
	.select2_o         (MUX_ALU_data2.select_i)
);

endmodule
