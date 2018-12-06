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
wire [31 : 0] imm_branch;
wire [31 : 0] ALU_result;
wire [31 : 0] sum;

wire [31 : 0] RTdata;
wire [31 : 0] RDdata;

wire [31 : 0] IF_ID_PC;

wire [4 : 0]  ID_EX_RSaddr;
wire [4 : 0]  ID_EX_RTaddr;
wire [4 : 0]  ID_EX_RDaddr;
wire [31 : 0] ID_EX_RSdata;
wire [31 : 0] ID_EX_RTdata;
wire          ID_EX_Branch;
wire          ID_EX_MemRead;
wire          ID_EX_MemWrite;
wire          ID_EX_RegWrite;
wire          ID_EX_MemtoReg;

wire [4 : 0]  EX_MEM_RDaddr;
wire          EX_MEM_RegWrite;
wire          EX_MEM_MemtoReg;

wire [4 : 0]  MEM_WB_RDaddr;
wire          MEM_WB_RegWrite;
wire          MEM_WB_MemtoReg;

Control Control
(
    .Op_i       (inst[6 : 0]),
    .ALUOp_o    (MUX_Control.ALUOp_i),
    .ALUSrc_o   (MUX_Control.ALUSrc_i),
    .Branch_o   (MUX_Control.Branch_i),
    .MemRead_o  (MUX_Control.MemRead_i),
    .MemWrite_o (MUX_Control.MemWrite_i),
    .RegWrite_o (MUX_Control.RegWrite_i),
    .MemtoReg_o (MUX_Control.MemtoReg_i)
);

MUX_Control MUX_Control
(
    .select_i   (Hazard.select_o),
    .ALUOp_i    (Control.ALUOp_o),
    .ALUOp_o    (ID_EX.ALUOp_i),
    .ALUSrc_i   (Control.ALUSrc_o),
    .ALUSrc_o   (ID_EX.ALUSrc_i),
    .Branch_i   (Control.Branch_o),
    .Branch_o   (branch),
    .MemRead_i  (Control.MemRead_o),
    .MemRead_o  (ID_EX.MemRead_i),
    .MemWrite_i (Control.MemWrite_o),
    .MemWrite_o (ID_EX.MemWrite_i),
    .RegWrite_i (Control.RegWrite_o),
    .RegWrite_o (ID_EX.RegWrite_i),
    .MemtoReg_i (Control.MemtoReg_o),
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
    .pc_write_i (Hazard.PC_write_o),
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
    .data1_i    (IF_ID_PC),
    .data2_i    (imm_branch << 1),
    .data_o     (sum)
);

And And
(
    .data1_i    (branch),
    .data2_i    ((ID_EX_RSdata == ID_EX_RTdata)? 1'b1 : 1'b0),
    .data_o     (taken)
);

MUX32 MUX_PC
(
    .data1_i    (Add_PC.data_o),
    .data2_i    (sum),
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
    .RSdata_o   (ID_EX_RSdata),
    .RTdata_o   (ID_EX_RTdata) 
);

Sign_Extend Sign_Extend
(
    .data_i     (inst),
    .data_o     (imm_branch)
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
    .Zero_o     (zero)
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
    .select_i   (MEM_WB_MemtoReg),
    .data_o     (RDdata)
);

IF_ID IF_ID
(
	.clk_i         (clk_i),
	.IF_ID_flush_i (taken),
	.IF_ID_write_i (Hazard.IF_ID_write_o),
	.PC_i          (inst_addr),
	.PC_o          (IF_ID_PC),
	.inst_i        (Instruction_Memory.instr_o),
	.inst_o        (inst)
);

ID_EX ID_EX
(
    .clk_i      (clk_i),
    .inst_i     (inst),
    .inst_o     (ALU_Control.funct_i),
    .RSdata_i   (ID_EX_RSdata),
    .RSdata_o   (MUX_ALU_data1.data1_i),
    .RTdata_i   (ID_EX_RTdata),
    .RTdata_o   (MUX_ALU_data2.data1_i),
    .imm_i      (imm_branch),
    .imm_o      (imm),
    .RSaddr_i   (inst[19 : 15]),
    .RSaddr_o   (ID_EX_RSaddr),
    .RTaddr_i   (inst[24 : 20]),
    .RTaddr_o   (ID_EX_RTaddr),
    .RDaddr_i   (inst[11 : 7]),
    .RDaddr_o   (ID_EX_RDaddr),
    .ALUOp_i    (MUX_Control.ALUOp_o),
    .ALUOp_o    (ALU_Control.ALUOp_i),
    .ALUSrc_i   (MUX_Control.ALUSrc_o),
    .ALUSrc_o   (MUX_ALUSrc.select_i),
    .MemRead_i  (MUX_Control.MemRead_o),
    .MemRead_o  (ID_EX_MemRead),
    .MemWrite_i (MUX_Control.MemWrite_o),
    .MemWrite_o (ID_EX_MemWrite),
    .RegWrite_i (MUX_Control.RegWrite_o),
    .RegWrite_o (ID_EX_RegWrite),
    .MemtoReg_i (MUX_Control.MemtoReg_o),
    .MemtoReg_o (ID_EX_MemtoReg)
);

EX_MEM EX_MEM
(
    .clk_i       (clk_i),
    .ALUResult_i (ALU.data_o),
    .ALUResult_o (ALU_result),
    .RTdata_i    (RTdata),
    .RTdata_o    (Data_Memory.data_i),
    .RDaddr_i    (ID_EX_RDaddr),
    .RDaddr_o    (EX_MEM_RDaddr),
    .MemRead_i   (ID_EX_MemRead),
    .MemRead_o   (Data_Memory.MemRead_i),
    .MemWrite_i  (ID_EX_MemWrite),
    .MemWrite_o  (Data_Memory.MemWrite_i),
    .RegWrite_i  (ID_EX_RegWrite),
    .RegWrite_o  (EX_MEM_RegWrite),
    .MemtoReg_i  (ID_EX_MemtoReg),
    .MemtoReg_o  (EX_MEM_MemtoReg)
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
    .MemtoReg_i  (EX_MEM_MemtoReg),
    .MemtoReg_o  (MEM_WB_MemtoReg)
);

Forward Forward
(
	.ID_EX_RSaddr_i    (ID_EX_RSaddr),
	.ID_EX_RTaddr_i    (ID_EX_RTaddr),
	.EX_MEM_RDaddr_i   (EX_MEM_RDaddr),
	.MEM_WB_RDaddr_i   (MEM_WB_RDaddr),
	.EX_MEM_RegWrite_i (EX_MEM_RegWrite),
	.MEM_WB_RegWrite_i (MEM_WB_RegWrite),
	.select1_o         (MUX_ALU_data1.select_i),
	.select2_o         (MUX_ALU_data2.select_i)
);

Hazard Hazard
(
	.ID_EX_MemRead_i (ID_EX_MemRead),
	.IF_ID_RSaddr_i  (inst[19 : 15]),
	.IF_ID_RTaddr_i  (inst[24 : 20]),
	.ID_EX_RDaddr_i  (ID_EX_RDaddr),
	.select_o        (MUX_Control.select_i),
	.PC_write_o      (PC.pc_write_i),
	.IF_ID_write_o   (IF_ID.IF_ID_write_i)
);

endmodule
