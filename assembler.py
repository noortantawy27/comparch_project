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

# ---------------- REGISTERS ----------------
REG = {
    "R0": "000", "R1": "001", "R2": "010", "R3": "011",
    "R4": "100", "R5": "101", "R6": "110", "R7": "111"
}

def imm16(x):
    return format(int(x) & 0xFFFF, "016b")

# ---------------- ASSEMBLE ONE INSTRUCTION ----------------
def assemble_instruction(line):
    line = line.split(";")[0].strip()
    if not line:
        return None

    tokens = re.split(r"[,\s()]+", line.upper())
    op = tokens[0]

    if op not in OPCODES:
        raise ValueError(f"Unknown opcode: {op}")

    code = OPCODES[op]

    # -------- NO OPERAND --------
    if op in ("NOP", "HLT", "SETC", "RET", "RTI", "RESET"):
        return code + "0" * 27

    if op in ("INC", "OUT", "IN", "PUSH", "POP"):
        rd = REG[tokens[1]]
        if op == "INC":
            return code + rd + rd + "000000000000000000100"
        elif op in ("IN", "POP"):
            # IN, POP: Rdst right after opcode, rest zeros
            return code + rd + "0" * 24
        else:
            # OUT, PUSH remain unchanged
            return code + "000000" + rd + "0" * 18


    # -------- NOT --------
    if op == "NOT":
        rd = REG[tokens[1]]
        return code + rd + rd + "0" * 21

    # -------- MOV --------
    if op == "MOV":
        rs, rd = REG[tokens[1]], REG[tokens[2]]
        return code + rd + "000" + rs + "0" * 18

    # -------- SWAP --------
    if op == "SWAP":
        rs, rd = REG[tokens[1]], REG[tokens[2]]
        return code + rs + rd + rs + "0" * 18

    # -------- R-TYPE (ADD/SUB/AND) --------
    if op in ("ADD", "SUB", "AND"):
        rd, r1, r2 = REG[tokens[1]], REG[tokens[2]], REG[tokens[3]]
        return code + rd + r1 + r2 + "0" * 18

    # -------- IADD --------
    if op == "IADD":
        rd, rs = REG[tokens[1]], REG[tokens[2]]
        return code + rd + rs + "000" + imm16(tokens[3]) + "0" * 2

    # -------- LDM --------
    if op == "LDM":
        rd = REG[tokens[1]]
        return code + rd + "000000" + imm16(tokens[2]) + "0" * 2

    # -------- LDD --------
    if op == "LDD":
        rd, offset, rs = REG[tokens[1]], tokens[2], REG[tokens[3]]
        return code + rd + rs + "000" + imm16(offset) + "0" * 2

    # -------- STD --------
    if op == "STD":
        rs1, offset, rs2 = REG[tokens[1]], tokens[2], REG[tokens[3]]
        return code + "000" + rs2 + rs1 + imm16(offset) + "0" * 2

    # -------- JUMPS / CALL / INT --------
    if op in ("JZ", "JN", "JC", "JMP", "CALL", "INT"):
        return code + "000000000" + imm16(tokens[1]) + "0" * 2

    raise ValueError("Unhandled instruction")

# ---------------- ASSEMBLE FILE ----------------
def assemble_program(lines):
    output = []
    for ln, line in enumerate(lines, 1):
        mc = assemble_instruction(line)
        if mc:
            if len(mc) != 32:
                raise ValueError(f"Line {ln}: Instruction not 32 bits")
            output.append(mc)
    return output

# ---------------- MAIN ----------------
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python assembler.py program.asm")
        sys.exit(1)

    asm_file = sys.argv[1]
    out_file = asm_file.replace(".asm", ".mem")

    with open(asm_file) as f:
        lines = f.readlines()

    machine = assemble_program(lines)

    with open(out_file, "w") as f:
        for code in machine:
            f.write(code + "\n")

    print(f"Assembly complete.")
    print(f"Output written to: {out_file}")

