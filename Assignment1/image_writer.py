# 4. Write a program that consumes pixel values and creates an image.

from PIL import Image

# Converts pixel code value back into RGB value
def convert(code):
    if code == "B": return (153, 217, 234)
    elif code == "P": return (255, 174, 201)
    else: return code

# Open our image and create our output file to write to
input_text_file = open("pixelvalues.txt", "r")
lines = input_text_file.readlines()
h, w = len(lines), lines[0].count(" ")
img = Image.new(mode="RGB", size=(h, w), color=(0, 0, 0))

# Iterate through each pixel and write its color value to the file
for y in range(h):
    pixels = lines[y].split()
    for x in range(w):
        pixel = pixels[x]
        img.putpixel((x, y), convert(pixel))

img.save("output.png")