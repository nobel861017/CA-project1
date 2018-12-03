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
wire [31 : 0] RTdata;
wire [31 : 0] ALU_result;

Control Control
(
    .Op_i       (inst[6 : 0]),
    .ALUOp_o    (ALU_Control.ALUOp_i),
    .ALUSrc_o   (MUX_ALUSrc.select_i),
    .Branch_o   (branch),
    .MemRead_o  (Data_Memory.MemRead_i),
    .MemWrite_o (Data_Memory.MemWrite_i),
    .RegWrite_o (Registers.RegWrite_i),
    .MemtoReg_o (MUX_MemtoReg.select_i)
);

ALU_Control ALU_Control
(
    .funct_i    (inst),
    .ALUOp_i    (Control.ALUOp_o),
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
    .data1_i    (inst_addr),
    .data2_i    (Sign_Extend.data_o << 1),
    .data_o     (MUX_PC.data2_i)
);

and And(taken , branch , zero);

MUX32 MUX_PC
(
    .data1_i    (Add_PC.data_o),
    .data2_i    (Add_PC_branch.data_o),
    .select_i   (taken),
    .data_o     (PC.pc_i)
);

Instruction_Memory Instruction_Memory
(
    .addr_i     (inst_addr), 
    .instr_o    (inst)
);

Registers Registers
(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[19 : 15]),
    .RTaddr_i   (inst[24 : 20]),
    .RDaddr_i   (inst[11 : 7]), 
    .RDdata_i   (MUX_MemtoReg.data_o),
    .RegWrite_i (Control.RegWrite_o), 
    .RSdata_o   (ALU.data1_i),
    .RTdata_o   (RTdata) 
);

Sign_Extend Sign_Extend
(
    .data_i     (inst),
    .data_o     (MUX_ALUSrc.data2_i)
);

MUX32 MUX_ALUSrc
(
    .data1_i    (RTdata),
    .data2_i    (Sign_Extend.data_o),
    .select_i   (Control.ALUSrc_o),
    .data_o     (ALU.data2_i)
);

ALU ALU
(
    .data1_i    (Registers.RSdata_o),
    .data2_i    (MUX_ALUSrc.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (ALU_result),
    .Zero_o     (zero)
);

Data_Memory Data_Memory
(
    .clk_i      (clk_i),
    .MemWrite_i (Control.MemWrite_o),
    .MemRead_i  (Control.MemRead_o),
    .addr_i     (ALU_result),
    .data_i     (RTdata),
    .data_o     (MUX_MemtoReg.data2_i)
);

MUX32 MUX_MemtoReg
(
    .data1_i    (ALU_result),
    .data2_i    (Data_Memory.data_o),
    .select_i   (Control.MemtoReg_o),
    .data_o     (Registers.RDdata_i)
);

endmodule
