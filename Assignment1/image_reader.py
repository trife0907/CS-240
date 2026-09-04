# 3. Write a program that reads an image and prints its pixel values.

# First, pip install pillow
from PIL import Image

# Function to give shorthand names for each color of pixel
def convert(pixel):
    if pixel == "(153, 217, 234)": return "B"
    elif pixel == "(255, 174, 201)": return "P"
    else: return pixel

# Open our image and create our output file to write to
image = Image.open("image.png").convert("RGBA")
output_text_file = open("output.txt", "w")

# Iterate through each pixel and write its color value to the file
for y in range(image.height):
    for x in range(image.width):
        r, g, b, _ = image.getpixel((x, y))
        pixel = f"({r}, {g}, {b})"
        pixel = convert(pixel)
        output_text_file.write(pixel)
        output_text_file.write(" ")
    output_text_file.write("\n")

output_text_file.close()