# Single-cycle-MIPS-processor-

In this project, I extended a single-cycle MIPS-based processor to support eight additional instructions: R-type operations (srl, srlv, jr, xor), conditional branches (bgtz, bltz), and immediate operations (lh, xori, sb, andi, ori, lhu). This enhancement was built on an initial design that supported basic instructions like add, sub, and, or, slt, lw, sw, beq, addi, and j, featuring a data-path and a controller divided into a main decoder and an ALU decoder.

Key modifications included:

Data-path Enhancements: New pathways were added to accommodate operations such as shift right logical and exclusive OR, among others.
Decoder Updates: The main and ALU decoders were updated to recognize and decode the new instruction set, involving new control signals for operation guidance.
Memory Interface Adjustments: The memory interface was refined for variable-sized data accesses to support byte and half-word operations.
Control Signal Expansion: Control logic was expanded for accurate signal generation for conditional branches and immediate operations.
The design was implemented in SystemVerilog using the Xilinx Vivado tool, focusing on a hierarchical structure for modularity and maintainability. To validate the enhanced processor's functionality, I developed an extensive testbench that covered all original and new instructions. This testbench confirmed correct processor operation for the expanded instruction set, demonstrating the success of the design enhancements. 

![Screenshot (145)](https://github.com/Ibrahim-Hussain1/Single-cycle-MIPS-processor-/assets/161763368/692e7bc0-6c1b-462b-b26a-1462d0df8415)

![Screenshot (144)](https://github.com/Ibrahim-Hussain1/Single-cycle-MIPS-processor-/assets/161763368/1c8dfec6-bbc2-4f9a-b046-3225d123bdc0)

![Screenshot (143)](https://github.com/Ibrahim-Hussain1/Single-cycle-MIPS-processor-/assets/161763368/ad317011-b3b7-444f-8216-ecb298a6bfff)

![Screenshot (142)](https://github.com/Ibrahim-Hussain1/Single-cycle-MIPS-processor-/assets/161763368/905bd370-c679-48df-bf00-c50edb0fdce0)

Schematic of controller and datapath: ![image](https://github.com/Ibrahim-Hussain1/Single-cycle-MIPS-processor-/assets/161763368/aaf5d35d-907f-43f1-95bf-73b969b1b19b)

Simulation: ![image](https://github.com/Ibrahim-Hussain1/Single-cycle-MIPS-processor-/assets/161763368/40c38bd7-88b3-4e6f-b617-692481a73ef9)



