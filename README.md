# 5-Stage Pipelined Von-Neumann Processor

A 32-bit RISC-like processor designed with a 5-stage pipeline, implemented in VHDL. 

## Architecture Design
- **Type**: Von-Neumann (Single memory for program and data).
- **Registers**: Eight 32-bit general-purpose registers (R0-R7), PC, and SP (initial value: 2^20-1).
- **Memory**: 1 MB address space with 32-bit width. 

### https://lucid.app/lucidspark/c142883f-288e-4f57-9a3c-7bcea2d290d8/edit?invitationId=inv_5b71bc48-80fe-4592-9855-08f51faea22d

## Instruction Set Architecture (ISA)
The processor supports the following operations: 

### One-Operand Instructions
- **NOP**: No operation.
- **HLT**: Freezes the Program Counter until reset. 
- **SETC**: Sets the carry flag to 1.
- **NOT / INC**: Logical bitwise NOT and increment operations. 
- **IN / OUT**: Data transfer from/to I/O ports. 

### Two-Operand Instructions
- **MOV / SWAP**: Move or exchange values between registers. 
- **ADD / SUB / AND**: Arithmetic and logical operations with carry, zero, and negative flag updates. 
- **IADD**: Add immediate value to a register. 

### Memory & Branching
- **PUSH / POP**: Stack operations using the Stack Pointer.
- **LDM / LDD / STD**: Loading immediate values or memory contents, and storing to memory. 
- **JZ / JN / JC / JMP**: Conditional jumps (Zero, Negative, Carry) and unconditional jumps.
- **CALL / RET**: Subroutine execution and return.
- **INT / RTI**: Software interrupt handling and return from interrupt.

## Pipeline Implementation
- **Stages**: Fetch, Decode, Execute, Memory, and Write-back. 
- **Hazards**: Includes Data Forwarding and Static Branch Prediction logic to manage pipeline hazards. 
