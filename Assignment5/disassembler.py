from pathlib import Path

TEXT_START = 0x00400000
DATA_START = 0x10010000

register_names = [
    "$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3",
    "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7",
    "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7",
    "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp", "$ra"
]


def load_ascii(path):
    lines = path.read_text().splitlines()
    if lines[0] != "MHC1":
        raise ValueError("Not an MHC-ASCII file")

    text_header = lines[1].split()
    text_start = int(text_header[1], 16)
    text_size = int(text_header[2])
    i = 2

    text_words = []
    while i < len(lines) and not lines[i].startswith("DATA "):
        text_words.append(int(lines[i], 2))
        i += 1

    data_header = lines[i].split()
    data_size = int(data_header[2])
    data = [int(bits, 2) for bits in lines[i + 1:]]

    if len(text_words) * 4 != text_size or len(data) != data_size:
        raise ValueError("The section sizes in the ASCII file do not match")

    return text_start, text_words, data


def load_binary(path):
    contents = path.read_bytes()
    if contents[:4] != b"MHC1":
        raise ValueError("Not an MHC-BIN file")

    text_size = int.from_bytes(contents[4:8], "big")
    data_size = int.from_bytes(contents[8:12], "big")

    text = contents[12:12 + text_size]
    data = contents[12 + text_size:]

    if len(text) != text_size or len(data) != data_size:
        raise ValueError("The section sizes in the binary file do not match")
    if text_size % 4 != 0:
        raise ValueError("Text section size is not a multiple of 4")

    words = [
        int.from_bytes(text[i:i + 4], "big")
        for i in range(0, text_size, 4)
    ]

    # The binary header stores section sizes, not starting addresses.
    return TEXT_START, words, list(data)


def signed(value, width):
    if value >= 2 ** (width - 1):
        value -= 2 ** width
    return value


def decode(word, address):
    opcode = (word >> 26) & 0x3F
    rs = (word >> 21) & 0x1F
    rt = (word >> 16) & 0x1F
    rd = (word >> 11) & 0x1F
    immediate = word & 0xFFFF
    funct = word & 0x3F

    if word == 0x0000000C:
        return "syscall", None

    if opcode == 0:
        if funct == 0x21:
            return f"addu {register_names[rd]}, {register_names[rs]}, {register_names[rt]}", None
        if funct == 0x1A:
            return f"div {register_names[rs]}, {register_names[rt]}", None
        if funct == 0x10:
            return f"mfhi {register_names[rd]}", None
        if funct == 0x2A:
            return f"slt {register_names[rd]}, {register_names[rs]}, {register_names[rt]}", None

    if opcode == 8:
        value = signed(immediate, 16)
        return f"addi {register_names[rt]}, {register_names[rs]}, {value}", None
    if opcode == 13:
        return f"ori {register_names[rt]}, {register_names[rs]}, {immediate}", None
    if opcode == 15:
        return f"lui {register_names[rt]}, {immediate}", None

    if opcode in (4, 5):
        offset = signed(immediate, 16)
        target = address + 4 + offset * 4
        name = "beq" if opcode == 4 else "bne"
        text = f"{name} {register_names[rs]}, {register_names[rt]}, TARGET"
        return text, target

    if opcode == 2:
        target = ((address + 4) & 0xF0000000) | ((word & 0x03FFFFFF) << 2)
        return "j TARGET", target

    raise ValueError(f"Unsupported instruction word: {word:032b}")


filename = Path(input("MHC file name: ").strip())

if filename.suffix.lower() == ".mhc-ascii":
    text_start, words, data = load_ascii(filename)
elif filename.suffix.lower() == ".mhc-bin":
    text_start, words, data = load_binary(filename)
else:
    raise ValueError("Choose a .mhc-ascii or .mhc-bin file")

# Find all branch and jump destinations so we can recreate labels.
decoded = []
targets = set()

for i, word in enumerate(words):
    address = text_start + i * 4
    instruction, target = decode(word, address)
    decoded.append((address, instruction, target))
    if target is not None:
        targets.add(target)

label_names = {
    address: ("main" if address == text_start else f"L_{address:08X}")
    for address in targets
}
label_names[text_start] = "main"

assembly = [".data"]
for value in data:
    assembly.append(f".byte {value}")

assembly += ["", ".text", ".globl main"]

for address, instruction, target in decoded:
    if address in label_names:
        assembly.append(label_names[address] + ":")

    if target is not None:
        instruction = instruction.replace("TARGET", label_names[target])

    assembly.append(instruction)

Path("reconstructed.asm").write_text("\n".join(assembly) + "\n")
print("Created reconstructed.asm")