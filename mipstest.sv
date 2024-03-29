// mipstest.sv

// Testbench for MIPS processor

module mipstest ();

  logic clk;
  logic reset;

  logic [31:0] writedata, dataadr;
  logic memwrite;

  // instantiate device to be tested
  top dut (
      clk,
      reset,
      writedata,
      dataadr,
      memwrite
  );
  // initial begin
  //   $monitor("pc=%d instr=%h aluctrl=%h a=%h b=%h result=%h", dut.mips.dp.pc, dut.mips.instr,
  //            dut.mips.dp.alucontrol, dut.mips.dp.alu.a, dut.mips.dp.alu.b, dut.mips.dp.alu.result);
  // end
  // initialize test
  initial begin
    reset <= 1;
    #22;
    reset <= 0;
  end

  // generate clock to sequence tests
  always begin
    clk <= 1;
    #5;
    clk <= 0;
    #5;
  end

  // check results
  always @(negedge clk) begin
    if (memwrite) begin
      if (dataadr === 88 & writedata === 32'hc) begin
        $display("Simulation succeeded");
        $stop;
      end else if (dataadr !== 80 & dataadr !== 84) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end
endmodule

module top (
    input  logic        clk,
    reset,
    output logic [31:0] writedata,
    dataadr,
    output logic        memwrite
);

  logic [31:0] pc, instr, readdata;

  // instantiate processor and memories
  mips mips (
      clk,
      reset,
      pc,
      instr,
      memwrite,
      dataadr,
      writedata,
      readdata
  );
  imem imem (
      pc[7:2],
      instr
  );
  dmem dmem (
      clk,
      memwrite,
      dataadr,
      writedata,
      readdata
  );
endmodule

module dmem (
    input  logic        clk,
    we,
    input  logic [31:0] a,
    wd,
    output logic [31:0] rd
);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]];  // word aligned

  always_ff @(posedge clk) if (we) RAM[a[31:2]] <= wd;
endmodule

module imem (
    input  logic [ 5:0] a,
    output logic [31:0] rd
);

  logic [31:0] RAM[63:0];

  initial $readmemh("code_test.dat", RAM);
  assign rd = RAM[a];  // word aligned
endmodule
