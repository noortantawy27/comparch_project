import sys
import re

# ---------------- OPCODES (bits 31–27) ----------------
OPCODES = {
    "NOP":  "00000",
    "HLT":  "00001",
    "SETC": "00010",
    "INC":  "00100",
    "OUT":  "00101",
    "IN":   "00110",
    "NOT":  "00111",
    "SWAP": "01000",
    "ADD":  "01001",
    "MOV":  "01011",
    "IADD": "01100",
    "SUB":  "01110",
    "AND":  "01111",
    "RESET":"10000",
    "PUSH": "10001",
    "POP":  "10010",
    "LDD":  "10100",
    "STD":  "10101",
    "LDM":  "10111",
    "JC":   "11000",
    "JMP":  "11001",
    "JZ":   "11010",
    "JN":   "11011",
    "INT":  "11100",
    "RTI":  "11101",
    "CALL": "11110",
    "RET":  "11111",
}

REG = {
    "R0": "000", "R1": "001", "R2": "010", "R3": "011",
    "R4": "100", "R5": "101", "R6": "110", "R7": "111"
}

# ---------------- IMMEDIATE (HEX) ----------------
def imm16(x):
    return format(int(x, 16) & 0xFFFF, "016b")

# ---------------- PASS 1: FIND LAST INSTRUCTION ----------------
def pass1_find_last_instruction(lines):
    current_address = 0
    max_address = -1

    for line in lines:
        line = line.strip().split("#")[0]
        if not line:
            continue

        if line.upper().startswith(".ORG"):
            current_address = int(line.split()[1], 16)
            continue

        max_address = max(max_address, current_address)
        current_address += 1

    return max_address

# ---------------- RAW HEX WORD CHECK ----------------
def is_raw_hex_word(line):
    return re.fullmatch(r"[0-9A-F]+", line, re.I)

# ---------------- ASSEMBLE ONE INSTRUCTION ----------------
def assemble_instruction(line, DATA_BASE):
    tokens = re.split(r"[,\s()]+", line.upper())
    op = tokens[0]
    code = OPCODES[op]

    if op in ("NOP", "HLT", "SETC", "RET", "RTI", "RESET"):
        return code + "0" * 27

    if op in ("INC", "OUT", "IN", "PUSH", "POP"):
        rd = REG[tokens[1]]
        if op == "INC":
            return code + rd + rd + "000000000000000000100"
        elif op in ("IN", "POP"):
            return code + rd + "0" * 24
        else:
            return code + "000000" + rd + "0" * 18

    if op == "NOT":
        rd = REG[tokens[1]]
        return code + rd + rd + "0" * 21

    if op == "MOV":
        rs, rd = REG[tokens[1]], REG[tokens[2]]
        return code + rd + "000" + rs + "0" * 18

    if op == "SWAP":
        rs, rd = REG[tokens[1]], REG[tokens[2]]
        return code + rs + rd + rs + "0" * 18

    if op in ("ADD", "SUB", "AND"):
        rd, r1, r2 = REG[tokens[1]], REG[tokens[2]], REG[tokens[3]]
        return code + rd + r1 + r2 + "0" * 18

    if op == "IADD":
        rd, rs = REG[tokens[1]], REG[tokens[2]]
        return code + rd + rs + "000" + imm16(tokens[3]) + "0" * 2

    # -------- DATA INSTRUCTIONS (DATA_BASE OFFSET) --------
    if op == "LDM":
        rd = REG[tokens[1]]
        imm = imm16(tokens[2])
        return code + rd + "000000" + imm + "0" * 2

    if op == "LDD":
        rd, offset, rs = REG[tokens[1]], tokens[2], REG[tokens[3]]
        addr = int(offset, 16) + DATA_BASE
        return code + rd + rs + "000" + imm16(hex(addr)[2:]) + "0" * 2

    if op == "STD":
        rs1, offset, rs2 = REG[tokens[1]], tokens[2], REG[tokens[3]]
        addr = int(offset, 16) + DATA_BASE
        return code + "000" + rs2 + rs1 + imm16(hex(addr)[2:]) + "0" * 2

    # -------- JUMPS (NO OFFSET) --------
    if op in ("JZ", "JN", "JC", "JMP", "CALL", "INT"):
        return code + "000000000" + imm16(tokens[1]) + "0" * 2

    raise ValueError(f"Unknown instruction: {op}")

# ---------------- PASS 2: ASSEMBLE ----------------
def assemble_program(lines):
    LAST_INSTR = pass1_find_last_instruction(lines)
    DATA_BASE = LAST_INSTR + 1

    memory = {}
    current_address = 0

    for line in lines:
        line = line.strip().split("#")[0]
        if not line:
            continue

        if line.upper().startswith(".ORG"):
            current_address = int(line.split()[1], 16)
            continue

        # -------- RAW HEX WORD --------
        if is_raw_hex_word(line):
            memory[current_address] = format(int(line, 16) & 0xFFFFFFFF, "032b")
            current_address += 1
            continue

        # -------- INSTRUCTION --------
        mc = assemble_instruction(line, DATA_BASE)
        memory[current_address] = mc
        current_address += 1

    MEMORY_SIZE = 4000
    output = [memory.get(addr, "0" * 32) for addr in range(MEMORY_SIZE)]

    print(f"Instruction memory ends at: 0x{LAST_INSTR:X}")
    print(f"Data memory starts at:     0x{DATA_BASE:X}")

    return output

# ---------------- MAIN ----------------
if __name__ == "__main__":
    asm_file = sys.argv[1]
    out_file = asm_file.replace(".asm", ".mem")

    with open(asm_file) as f:
        lines = f.readlines()

    machine = assemble_program(lines)

    with open(out_file, "w") as f:
        for code in machine:
            f.write(code + "\n")

    print("Assembly complete.")
