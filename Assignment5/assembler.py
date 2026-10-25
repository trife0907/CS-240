import ast

TEXT_START = 0x00400000
DATA_START = 0x10010000

registers = {
    "$zero": 0, "$at": 1, "$v0": 2, "$a0": 4,
    "$t0": 8, "$t1": 9, "$t2": 10, "$t3": 11,
    "$t4": 12, "$t5": 13
}

filename = input("Assembly file name: ")
lines = open(filename).readlines()

labels = {}
instructions = []
data = bytearray()
text_address = TEXT_START
in_data = False

for line_number, line in enumerate(lines, start=1):
    line = line.strip()
    if not line:
        continue

    # Record a label at the current address.
    if ":" in line:
        label, line = line.split(":", 1)
        labels[label.strip()] = (
            DATA_START + len(data) if in_data else text_address
        )
        line = line.strip()

    if not line:
        continue
    elif line == ".data":
        in_data = True
    elif line == ".text":
        in_data = False
    elif line.startswith(".globl"):
        pass
    elif line.startswith(".asciiz"):
        string = ast.literal_eval(line[len(".asciiz"):].strip())
        data.extend(string.encode("ascii") + b"\0")
    elif line.startswith(".byte"):
        values = line[len(".byte"):].split(",")

        for value in values:
            byte_value = int(value.strip(), 0)
            if not 0 <= byte_value <= 255:
                raise ValueError(f"Invalid byte on line {line_number}: {value}")
            data.append(byte_value)
    elif in_data:
        print(f"Unsupported data line {line_number}: {line}")
    else:
        instructions.append((text_address, line))
        text_address += 4

def encode_addi(line):
    parts = line.replace(",", "").split()
    # parts looks like: ["addi", "$t0", "$zero", "1"]

    rt = format(registers[parts[1]], "05b")
    rs = format(registers[parts[2]], "05b")
    immediate = format(int(parts[3]) & 0xFFFF, "016b")

    opcode = "001000"
    return opcode + rs + rt + immediate

def encode_addu(line):
    parts = line.replace(",", "").split()
    # parts looks like: ["addu", "$a0", "$t0", "$zero"]

    rd = format(registers[parts[1]], "05b")
    rs = format(registers[parts[2]], "05b")
    rt = format(registers[parts[3]], "05b")

    opcode = "000000"
    shamt = "00000"
    funct = "100001"

    return opcode + rs + rt + rd + shamt + funct

def encode_div(line):
    parts = line.replace(",", "").split()
    rs = format(registers[parts[1]], "05b")
    rt = format(registers[parts[2]], "05b")

    return "000000" + rs + rt + "00000" + "00000" + "011010"


def encode_mfhi(line):
    parts = line.replace(",", "").split()
    rd = format(registers[parts[1]], "05b")

    return "000000" + "00000" + "00000" + rd + "00000" + "010000"

def encode_beq(line, address):
    parts = line.replace(",", "").split()

    rs = format(registers[parts[1]], "05b")
    rt = format(registers[parts[2]], "05b")

    target_address = labels[parts[3]]
    offset = (target_address - (address + 4)) // 4
    immediate = format(offset & 0xFFFF, "016b")

    return "000100" + rs + rt + immediate

def encode_bne(line, address):
    parts = line.replace(",", "").split()

    rs = format(registers[parts[1]], "05b")
    rt = format(registers[parts[2]], "05b")

    target_address = labels[parts[3]]
    offset = (target_address - (address + 4)) // 4
    immediate = format(offset & 0xFFFF, "016b")

    return "000101" + rs + rt + immediate

def encode_j(line):
    parts = line.split()
    target_address = labels[parts[1]]
    target = format(target_address >> 2, "026b")

    return "000010" + target

def encode_lui(line):
    parts = line.replace(",", "").split()
    rt = format(registers[parts[1]], "05b")
    immediate = format(int(parts[2], 0) & 0xFFFF, "016b")

    return "001111" + "00000" + rt + immediate


def encode_ori(line):
    parts = line.replace(",", "").split()
    rt = format(registers[parts[1]], "05b")
    rs = format(registers[parts[2]], "05b")
    immediate = format(int(parts[3], 0) & 0xFFFF, "016b")

    return "001101" + rs + rt + immediate


def encode_syscall():
    return "00000000000000000000000000001100"

def encode_slt(line):
    parts = line.replace(",", "").split()

    rd = format(registers[parts[1]], "05b")
    rs = format(registers[parts[2]], "05b")
    rt = format(registers[parts[3]], "05b")

    return "000000" + rs + rt + rd + "00000" + "101010"

def encode(line, address):
    instruction = line.split()[0]

    if instruction == "addi":
        return encode_addi(line)
    elif instruction == "addu":
        return encode_addu(line)
    elif instruction == "div":
        return encode_div(line)
    elif instruction == "mfhi":
        return encode_mfhi(line)
    elif instruction == "beq":
        return encode_beq(line, address)
    elif instruction == "bne":
        return encode_bne(line, address)
    elif instruction == "j":
        return encode_j(line)
    elif instruction == "lui":
        return encode_lui(line)
    elif instruction == "ori":
        return encode_ori(line)
    elif instruction == "syscall":
        return encode_syscall()
    elif instruction == "slt":
        return encode_slt(line)
    else:
        raise ValueError("Unsupported instruction: " + instruction)

machine_code = []

for address, line in instructions:
    bits = encode(line, address)
    machine_code.append(bits)

# Turn each 32-bit instruction into 4 big-endian bytes.
text_bytes = bytearray()
for bits in machine_code:
    text_bytes.extend(int(bits, 2).to_bytes(4, "big"))

# Readable output: section headers, then instruction bits and data bits.
with open("fizzbuzz.mhc-ascii", "w") as file:
    file.write("MHC1\n")
    file.write(f"TEXT {TEXT_START:08X} {len(text_bytes)}\n")

    for bits in machine_code:
        file.write(bits + "\n")

    file.write(f"DATA {DATA_START:08X} {len(data)}\n")

    for value in data:
        file.write(format(value, "08b") + "\n")

# Binary output:
# "MHC1", then 4-byte text length, 4-byte data length, then both sections.
header = (
    b"MHC1"
    + len(text_bytes).to_bytes(4, "big")
    + len(data).to_bytes(4, "big")
)

with open("fizzbuzz.mhc-bin", "wb") as file:
    file.write(header)
    file.write(text_bytes)
    file.write(data)

print("Created fizzbuzz.mhc-ascii and fizzbuzz.mhc-bin")