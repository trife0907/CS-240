# Build an ASCII-to-decimal converter

# Prompt user for input
ascii = input("Enter ASCII: ")

# Convert input to decimal
decimal = " ".join(str(ord(c)) for c in ascii)
print(f"Decimal: {decimal}")