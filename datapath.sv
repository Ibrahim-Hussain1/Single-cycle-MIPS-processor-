module datapath (
    input  logic        clk,
    reset,
    input  logic        memtoreg,
    pcsrc,
    input  logic        alusrc,
    regdst,
    input  logic        regwrite,
    jump,
    jump_register,
    i_type,
    if_srl,
    input  logic [ 3:0] alucontrol,    //changed
    input  logic [ 1:0] branchcon,
    output logic        branchresult,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic [31:0] aluout,
    writedata,
    input  logic [31:0] readdata
);

  logic [4:0] writereg;
  logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  logic [31:0] signimm, signimmsh;
  logic [31:0] srca, srcb;
  logic [31:0] result;
  logic [31:0] jump_address, j;
  logic r_type_jump, zero;
  logic [31:0] srcA;
  assign jump_address = {pcplus4[31:28], instr[25:0], 2'b00};

  assign r_type_jump = jump_register & jump;
  assign srcA = if_srl ? {27'b0, instr[10:6]} : srca;
  // next PC logic
  flopr #(32) pcreg (
      clk,
      reset,
      pcnext,
      pc
  );
  adder pcadd1 (
      pc,
      32'b100,
      pcplus4
  );
  sl2 immsh (
      signimm,
      signimmsh
  );
  adder pcadd2 (
      pcplus4,
      signimmsh,
      pcbranch
  );
  mux2 #(32) pcbrmux (
      pcplus4,
      pcbranch,
      pcsrc,
      pcnextbr
  );  // branch if we recieve a control signal and we get a result from comparator
  mux2 #(32) pcmux (
      pcnextbr,
      j,
      jump,
      pcnext
  );  // change to acomudate j and jr 
  mux2 #(32) jumpmux (
      jump_address,
      aluout,
      r_type_jump,
      j
  );  // will jump using ALUresult if JR 
  // register file logic
  regfile rf (
      clk,
      regwrite,
      instr[25:21],
      instr[20:16],
      writereg,
      result,
      srca,
      writedata
  );
  mux2 #(5) wrmux (
      instr[20:16],
      instr[15:11],
      regdst,
      writereg
  );
  mux2 #(32) resmux (
      aluout,
      readdata,
      memtoreg,
      result
  );
  signext se (
      instr[15:0],
      i_type,
      signimm
  );

  // ALU logic
  mux2 #(32) srcbmux (
      writedata,
      signimm,
      alusrc,
      srcb
  );
  alu alu (
      srcA,
      srcb,
      alucontrol,
      aluout,
      zero
  );
  comparator COMPARATOR (
      srca,
      branchcon,
      zero,
      branchresult
  );  // sent to controller for branch
endmodule

module sl2(input  logic [31:0] a,
           output logic [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

module signext (
    input logic [15:0] a,
    input logic s,
    output logic [31:0] y
);

  always_comb begin
    if (s) y = {{16'b0}, a};  // if i-type do zero extention
    else y = {{16{a[15]}}, a};  // if branch type do signed extention 

  end
endmodule


module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [4:0]  ra1, ra2, wa3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clk
  // register 0 hardwired to 0
  // note: for pipelined processor, write third port
  // on falling edge of clk

  always_ff @(posedge clk)
    if (we3) rf[wa3] <= wd3;	

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module comparator (
    input logic [31:0] a,
    input logic [1:0] branchcon,
    input logic zero,
    output logic branchresult
);

  always_comb begin
    case (branchcon)
      2'b01: branchresult = zero;  // beq 
      2'b10: branchresult = (a[31]) & (~zero);  // bltz : if negative signed and a != 0 
      2'b11: branchresult = (~a[31]) & (~zero);  // bgtz : if positve signed and a != 0

      default: branchresult = 1'b0;
    endcase
  end

endmodule

module alu (
    input  logic [31:0] a,
    b,
    input  logic [ 3:0] alucontrol,
    output logic [31:0] result,
    output logic        zero
);

  logic [31:0] condinvb, sum;

  assign condinvb = alucontrol[3] ? ~b : b;
  assign sum = a + condinvb + alucontrol[3];  //check the signed add

  always_comb
    case (alucontrol[2:0])
      3'b000: result = a & b;
      3'b001: result = a | b;
      3'b010: result = sum;
      3'b011: result = sum[31];
      3'b100: result = b >> a;  // srl and srlv where srl is for immediate 
      3'b101: result = a;  // jr jump to regesiter ,  also for bltz and bgtz to check if zero
      3'b110: result = a ^ b;
    endcase

  assign zero = (result == 32'b0);
endmodule

module adder(input  logic [31:0] a, b,
             output logic [31:0] y);

  assign y = a + b;
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule