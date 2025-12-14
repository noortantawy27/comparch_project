# assembler.py - Updated for your processor ISA
import sys

# Opcode definitions from control_unit.vhd (bits 31-27)
OPCODES = {
    "NOP": "00000",
    "HLT": "00001", 
    "SETC": "00010",
    "INC": "00100",
    "OUT": "00101",
    "IN": "00110",
    "NOT": "00111",
    "SWAP": "01000",
    "ADD": "01001",
    "MOV": "01011",
    "IADD": "01100",
    "SUB": "01110",
    "AND": "01111",
    "RESET": "10000",
    "PUSH": "10001",
    "POP": "10010",
    "INTERRUPT": "10011",
    "LDD": "10100",
    "STD": "10101",
    "LDM": "10111",
    "JC": "11000",
    "JMP": "11001",
    "JZ": "11010",
    "JN": "11011",
    "INT": "11100",
    "RTI": "11101",
    "CALL": "11110",
    "RET": "11111"
}

# Register mappings (3-bit encoding)
REGISTERS = {
    "R0": "000",
    "R1": "001", 
    "R2": "010",
    "R3": "011",
    "R4": "100",
    "R5": "101",
    "R6": "110",
    "R7": "111"
}

def assemble_instruction(instruction):
    """Convert assembly instruction to 32-bit machine code"""
    parts = instruction.upper().replace(',', ' ').split()
    
    if not parts:
        return "0" * 32  # NOP
    
    opcode = parts[0]
    
    if opcode not in OPCODES:
        raise ValueError(f"Unknown opcode: {opcode}")
    
    machine_code = OPCODES[opcode]  # 5 bits
    
    # Helper function to add bits with proper padding
    def add_bits(current, new_bits, total_needed):
        """Add new bits and pad with zeros to reach total_needed"""
        current += new_bits
        if len(current) < total_needed:
            current += "0" * (total_needed - len(current))
        return current
    
    if opcode == "IADD":
        # IADD Rdst,Rsrc,Imm: 3+3+3+16 = 25 bits used, need 2 zeros to reach 27
        if len(parts) != 4:
            raise ValueError(f"IADD expects 3 operands: Rdst,Rsrc,Immediate")
        rdst = REGISTERS[parts[1]]
        rsrc = REGISTERS[parts[2]]
        try:
            immediate = int(parts[3])
            immediate_bin = format(immediate & 0xFFFF, '016b')
        except:
            immediate_bin = "0" * 16
        
        machine_code = add_bits(machine_code, rdst + rsrc + "000" + immediate_bin, 32)
        
    elif opcode == "LDM":
        # LDM Rdst,imm: 3+6+16 = 25 bits, need 2 zeros
        if len(parts) != 3:
            raise ValueError(f"LDM expects 2 operands: Rdst,Immediate")
        rdst = REGISTERS[parts[1]]
        try:
            immediate = int(parts[2])
            immediate_bin = format(immediate & 0xFFFF, '016b')
        except:
            immediate_bin = "0" * 16
        
        machine_code = add_bits(machine_code, rdst + "000000" + immediate_bin, 32)
        
    elif opcode == "LDD":
        # LDD Rdst,offset(Rsrc): 3+3+3+16 = 25 bits, need 2 zeros
        if len(parts) != 3:
            raise ValueError(f"LDD expects 2 operands: Rdst,offset(Rsrc)")
        rdst = REGISTERS[parts[1]]
        offset_src_part = parts[2]
        
        if '(' in offset_src_part and ')' in offset_src_part:
            offset_part = offset_src_part.split('(')[0]
            rsrc_part = offset_src_part.split('(')[1].rstrip(')')
            rsrc = REGISTERS[rsrc_part]
            try:
                offset = int(offset_part)
                offset_bin = format(offset & 0xFFFF, '016b')
            except:
                offset_bin = "0" * 16
        else:
            raise ValueError(f"Invalid format: {offset_src_part}")
        
        machine_code = add_bits(machine_code, rdst + rsrc + "000" + offset_bin, 32)
        
    elif opcode == "STD":
        # STD Rsrc1,offset(Rsrc2): 3+3+3+16 = 25 bits, need 2 zeros
        if len(parts) != 3:
            raise ValueError(f"STD expects 2 operands: Rsrc1,offset(Rsrc2)")
        rsrc1 = REGISTERS[parts[1]]
        offset_src_part = parts[2]
        
        if '(' in offset_src_part and ')' in offset_src_part:
            offset_part = offset_src_part.split('(')[0]
            rsrc2_part = offset_src_part.split('(')[1].rstrip(')')
            rsrc2 = REGISTERS[rsrc2_part]
            try:
                offset = int(offset_part)
                offset_bin = format(offset & 0xFFFF, '016b')
            except:
                offset_bin = "0" * 16
        else:
            raise ValueError(f"Invalid format: {offset_src_part}")
        
        machine_code = add_bits(machine_code, rsrc1 + rsrc2 + "000" + offset_bin, 32)
        
    elif opcode in ["JZ", "JN", "JC", "JMP", "CALL"]:
        # 9+16 = 25 bits, need 2 zeros
        if len(parts) != 2:
            raise ValueError(f"{opcode} expects 1 operand: Immediate")
        
        try:
            immediate = int(parts[1])
            immediate_bin = format(immediate & 0xFFFF, '016b')
        except:
            immediate_bin = "0" * 16
        
        machine_code = add_bits(machine_code, "000000000" + immediate_bin, 32)
        
    elif opcode == "INT":
        # INT index: 000,000,000, 16 bits immediate
        if len(parts) != 2:
            raise ValueError(f"INT expects 1 operand: Index")
        
        try:
            index = int(parts[1])
            if index < 0 or index >= 2**16:
                raise ValueError(f"Index value out of range: {index}")
            index_bin = format(index, '016b')
        except ValueError:
            index_bin = "0" * 16
        
        machine_code += "000000000" + index_bin + "0" * 2
        
    elif opcode == "INTERRUPT":
        # INTERRUPT: fixed value 000,000,000,0000000000000001
        machine_code += "0000000000000000000000001" + "0" * 2
        
    else:
        # Default for unhandled instructions
        machine_code += "0" * 27
    
    # Ensure exactly 32 bits
    if len(machine_code) != 32:
        raise ValueError(f"Length error: {len(machine_code)} bits")
    
    return machine_code

def assemble_program(program_lines):
    """Assemble a complete program with label resolution"""
    # First pass: collect labels
    labels = {}
    instructions = []
    current_address = 0
    
    for line_num, line in enumerate(program_lines, 1):
        line = line.strip()
        # Remove comments
        if ';' in line:
            line = line.split(';')[0].strip()
        
        if not line:
            continue
        
        # Check for label (ends with :)
        if line.endswith(':'):
            label_name = line[:-1].strip()
            if label_name in labels:
                raise ValueError(f"Duplicate label: {label_name} at line {line_num}")
            labels[label_name] = current_address
            continue
        
        instructions.append((line_num, line))
        current_address += 1  # Each instruction takes one memory location
    
    # Second pass: assemble instructions with label resolution
    machine_codes = []
    errors = []
    
    for line_num, instruction in instructions:
        try:
            # Replace labels with their addresses
            parts = instruction.upper().replace(',', ' ').split()
            if len(parts) > 1 and parts[0] in ["JZ", "JN", "JC", "JMP", "CALL", "IADD", "LDM"]:
                # Check if operand is a label
                operand = parts[-1]
                if operand in labels:
                    # Replace label with address
                    instruction = instruction.replace(operand, str(labels[operand]))
            
            machine_code = assemble_instruction(instruction)
            machine_codes.append(machine_code)
            print(f"Line {line_num}: {instruction} -> {machine_code}")
            
        except Exception as e:
            errors.append(f"Error at line {line_num}: {e}")
            machine_codes.append("0" * 32)  # NOP on error
    
    return machine_codes, errors

def main():
    if len(sys.argv) != 2:
        print("Usage: python assembler.py <input_file.asm>")
        print("Output: Creates <input_file.mem> with hex values")
        return
    
    input_file = sys.argv[1]
    output_file = input_file.replace('.asm', '.mem')
    
    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        return
    
    print(f"Assembling: {input_file}")
    print("-" * 60)
    
    machine_codes, errors = assemble_program(lines)
    
    # Display errors
    if errors:
        print("\n" + "=" * 60)
        print("ASSEMBLY ERRORS:")
        for error in errors:
            print(f"  {error}")
        print("=" * 60)
    
    # Write to memory initialization file (hex format)
    try:
        with open(output_file, 'w') as f:
            for  code in enumerate(machine_codes):
                f.write(f"{code[1]}\n")
        
        print(f"\nAssembly complete. {len(machine_codes)} instructions assembled.")
        print(f"Output written to: {output_file}")
        
    except Exception as e:
        print(f"\nError writing output file: {e}")

if __name__ == "__main__":
    main()