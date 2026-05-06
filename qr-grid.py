import sys
from PIL import Image, ImageDraw, ImageFont

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <input.png> <output.png>")
    sys.exit(1)

img = Image.open(sys.argv[1]).convert('L')
pixels = list(img.getdata())
w = 290
module_size = 10
quiet_zone = 40
num_modules = 21

def px(x, y):
    return pixels[y * w + x]

modules = []
for row in range(num_modules):
    for col in range(num_modules):
        cx = quiet_zone + col * module_size + module_size // 2
        cy = quiet_zone + row * module_size + module_size // 2
        modules.append((row, col, px(cx, cy) < 128))

cell = 20
label_margin = 25
offset_x = label_margin
offset_y = 5
img_w = label_margin + num_modules * cell + 10
img_h = num_modules * cell + label_margin + 10

out = Image.new('RGB', (img_w, img_h), 'white')
draw = ImageDraw.Draw(out)

try:
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 11)
except:
    try:
        font = ImageFont.truetype('/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf', 11)
    except:
        font = ImageFont.load_default()

# Draw grid
grid_color = (200, 200, 200)
for i in range(num_modules + 1):
    x = offset_x + i * cell
    draw.line([(x, offset_y), (x, offset_y + num_modules * cell)], fill=grid_color, width=1)
    y = offset_y + i * cell
    draw.line([(offset_x, y), (offset_x + num_modules * cell, y)], fill=grid_color, width=1)

# Finder pattern regions (7x7 squares in three corners)
finder_cells = set()
for r in range(7):
    for c in range(7):
        finder_cells.add((r, c))                                    # top-left
        finder_cells.add((r, num_modules - 7 + c))                 # top-right
        finder_cells.add((num_modules - 7 + r, c))                 # bottom-left

# Draw squares: no padding for finder patterns, padded for data
pad = 3
for row, col, is_black in modules:
    if is_black:
        p = 0 if (row, col) in finder_cells else pad
        x0 = offset_x + col * cell + p
        y0 = offset_y + row * cell + p
        x1 = offset_x + (col + 1) * cell - p
        y1 = offset_y + (row + 1) * cell - p
        draw.rectangle([x0, y0, x1, y1], fill='black')

# Column labels
labels_col = 'abcdefghijklmnopqrstu'
for col in range(num_modules):
    cx = offset_x + col * cell + cell // 2
    draw.text((cx, offset_y + num_modules * cell + 3), labels_col[col], fill='black', font=font, anchor='mt')

# Row labels: 1 at bottom
for row in range(num_modules):
    cy = offset_y + row * cell + cell // 2
    draw.text((offset_x - 3, cy), str(num_modules - row), fill='black', font=font, anchor='rm')

out.save(sys.argv[2])
