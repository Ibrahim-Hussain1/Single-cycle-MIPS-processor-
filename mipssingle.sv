// mipssingle.sv

// Single-cycle MIPS processor

module mips (
    input  logic        clk,
    reset,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic        memwrite,
    output logic [31:0] aluout,
    writedata,
    input  logic [31:0] readdata
);

  logic
      memtoreg,
      alusrc,
      regdst,
      i_type,  // added i_type for the chosing of zero extention in andi and ori of immediate
      regwrite,
      jump,
      pcsrc,
      comparator_result,
      jump_register;
  logic [3:0] alucontrol;
  logic [1:0] branchcon;
  logic if_srl;
  controller controller_instance (
      .op               (instr[31:26]),
      .funct            (instr[5:0]),
      .comparator_result(comparator_result),
      .memtoreg         (memtoreg),
      .memwrite         (memwrite),
      .pcsrc            (pcsrc),
      .alusrc           (alusrc),
      .regdst           (regdst),
      .regwrite         (regwrite),
      .jump             (jump),
      .jump_register    (jump_register),
      .i_type           (i_type),
      .if_srl           (if_srl),
      .alucontrol       (alucontrol),
      .branchcon        (branchcon)
  );
  datapath dp (
      .clk(clk),
      .reset(reset),
      .memtoreg(memtoreg),
      .pcsrc(pcsrc),
      .alusrc(alusrc),
      .regdst(regdst),
      .regwrite(regwrite),
      .jump(jump),
      .jump_register(jump_register),
      .i_type(i_type),
      .if_srl(if_srl),
      .alucontrol(alucontrol),
      .branchcon(branchcon),
      .branchresult(comparator_result),
      .pc(pc),
      .instr(instr),
      .aluout(aluout),
      .writedata(writedata),
      .readdata(readdata)
  );
endmodule








