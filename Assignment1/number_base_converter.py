# 2. Build a number-base converter supporting binary, decimal, octal, and hexadecimal.

# Define bases allowed for conversion
bases = ["binary", "decimal", "octal", "hex"]

# Ask for starting base
start_base = input(f"Convert from? {bases}: ")

# Ask for ending base
if start_base == "binary":
    bases.remove("binary")
    end_base = input(f"Convert to? {bases}: ")

elif start_base == "decimal":
    bases.remove("decimal")
    end_base = input(f"Convert to? {bases}: ")

elif start_base == "octal":
    bases.remove("octal")
    end_base = input(f"Convert to? {bases}: ")

else:
    bases.remove("hex")
    end_base = input(f"Convert to? {bases}: ")

# Apply conversion based on starting/ending base

# Binary -> ___
if start_base == "binary":

    binary_input = input("Enter binary: ")

    if end_base == "decimal":
        print(f"Decimal: {int(binary_input, 2)}")

    elif end_base == "octal":
        print(f"Octal: {oct(int(binary_input, 2))}")

    else:
        print(f"Hexadecimal: {hex(int(binary_input, 2))}")


# Decimal -> ___
elif start_base == "decimal":

    decimal_input = int(input("Enter decimal: "))

    if end_base == "binary":
        print(f"Binary: {bin(decimal_input)}")

    elif end_base == "octal":
        print(f"Octal: {oct(decimal_input)}")

    else:
        print(f"Hexadecimal: {hex(decimal_input)}")

# Octal -> ___
elif start_base == "octal":

    octal_input = input("Enter octal: ")

    if end_base == "binary":
        print(f"Binary: {bin(int(octal_input, 8))}")

    elif end_base == "decimal":
        print(f"Decimal: {int(octal_input, 8)}")

    else:
        print(f"Hexadecimal: {hex(int(octal_input, 8))}")

# Hexadecimal -> ___
else:
    
    hex_input = input("Enter hexadecimal: ")

    if end_base == "binary":
        print(f"Binary: {bin(int(hex_input, 16))}")

    elif end_base == "decimal":
        print(f"Decimal: {int(hex_input, 16)}")

    else:
        print(f"Octal: {oct(int(hex_input, 16))}")