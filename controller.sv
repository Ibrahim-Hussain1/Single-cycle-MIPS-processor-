
module controller (
    input  logic [5:0] op,
    funct,
    input  logic       comparator_result,
    output logic       memtoreg,
    memwrite,
    output logic       pcsrc,
    alusrc,
    output logic       regdst,
    regwrite,
    output logic       jump,
    jump_register,
    i_type,
    if_srl,
    output logic [3:0] alucontrol,         //changed to accomudate the new operations
    output logic [1:0] branchcon
);

  logic [2:0] aluop;  // changed aluop to accomudate the immediate_type and branch_type expressions
  logic       branch;

  assign jump_register = (funct == 6'b001000);  // check if r_type is jump
  assign if_srl = op == 0 & funct == 2;
  maindec md (
      op,
      jump_register,
      memtoreg,
      memwrite,
      branch,
      i_type,
      alusrc,
      regdst,
      regwrite,
      jump,
      aluop
  );
  aludec ad (
      funct,
      aluop,
      alucontrol,
      branchcon
  );

  assign pcsrc = branch & comparator_result;   //replaced the zero requirment as we need to check zero in comparator
endmodule

module aludec (
    input  logic [5:0] funct,
    input  logic [2:0] aluop,
    output logic [3:0] alucontrol,  //changed to have more operations
    output logic [1:0] branchcon
);

  always_comb begin
    branchcon = 2'b00;
    case (aluop)
      3'b000: alucontrol <= 4'b010;  // add (for lw/sw/addi)
      3'b001: begin  // sub (for beq) 
        alucontrol <= 4'b1010;
        branchcon  <= 2'b01;
      end
      3'b100: alucontrol <= 4'b0000;  // ANDI
      3'b101: alucontrol <= 4'b0001;  // ORI
      3'b110: begin  // BLTZ
        alucontrol <= 4'b0101;  // result = a (for bltz , bgtz)
        branchcon  <= 2'b10;  // BLTZ
      end

      3'b111: begin  //BGTZ
        alucontrol <= 4'b0101;  // result = a (for bltz , bgtz)
        branchcon  <= 2'b11;  // BGTZ
      end

      default:
      case (funct)  // R-type instructions
        6'b100000: alucontrol <= 4'b010;  // add
        6'b100010: alucontrol <= 4'b1010;  // sub
        6'b100100: alucontrol <= 4'b000;  // and
        6'b100101: alucontrol <= 4'b001;  // or
        6'b101010: alucontrol <= 4'b1011;  // slt
        6'b100110: alucontrol <= 4'b0110;  // xor 
        6'b000010: alucontrol <= 4'b0100;  // srl
        6'b000110: alucontrol <= 4'b0100;  // srlv
        6'b001000: alucontrol <= 4'b0101;  // jr
        default:   alucontrol <= 4'bxxx;  // ???
      endcase
    endcase
  end
endmodule

module maindec (
    input  logic [5:0] op,
    input  logic       jump_register,
    output logic       memtoreg,
    memwrite,
    output logic       branch,
    i_type,
    alusrc,
    output logic       regdst,
    regwrite,
    output logic       jump,
    output logic [2:0] aluop
);

  logic [10:0] controls;

  assign {i_type, regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

  always_comb
    case (op)
      6'b000000: begin
        if (jump_register) controls <= 11'b01100001010;  // JR 
        else controls <= 11'b01100000010;  // RTYPE
      end
      6'b100011: controls <= 11'b01010010000;  // LW
      6'b101011: controls <= 11'b00010100000;  // SW
      6'b000100: controls <= 11'b00001000001;  // BEQ
      6'b000001: controls <= 11'b00001000110;  // bltz
      6'b000111: controls <= 11'b00001000111;  // bgtz
      6'b001000: controls <= 11'b01010000000;  // ADDI
      6'b000010: controls <= 11'b00000001000;  // J
      6'b001100: controls <= 11'b11010000100;  // ANDI
      6'b001101: controls <= 11'b11010000101;  //ORI
      default:   controls <= 11'bxxxxxxxxxxx;  // illegal op
    endcase
endmodule
