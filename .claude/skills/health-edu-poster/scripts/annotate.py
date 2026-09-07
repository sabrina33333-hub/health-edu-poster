#!/usr/bin/env python3
"""在生成图上叠加中文标注（解决生图模型写错复杂中文字的问题）。

用法：
  .venv/bin/python annotate.py --image in.png --output out.png \
      --label "認知:258,445:black" --label "憂鬱:890,445:red" [--size 42]

每个 --label 格式： 文字:x,y:颜色[:角度]
  x,y 是文字中心点；颜色 black/red/orange/blue 或 #hex；角度为逆时针小角度（默认随机 -3~3 度，模拟手写）。
"""
import argparse
import json
import random
import sys

COLORS = {
    "black": (26, 26, 26),
    "red": (200, 30, 30),
    "orange": (230, 120, 20),
    "blue": (40, 90, 200),
}

FONT_CANDIDATES = [
    ("/System/Library/Fonts/Supplemental/HanziPen.ttc", 0),
    ("/System/Library/Fonts/Supplemental/Hannotate.ttc", 0),
    ("/Users/new/Library/Fonts/jf-openhuninn-2.1.ttf", 0),
    ("/System/Library/Fonts/Songti.ttc", 3),  # Songti TC Bold
    ("/System/Library/Fonts/STHeiti Medium.ttc", 0),
]


def load_font(size):
    from PIL import ImageFont
    for path, index in FONT_CANDIDATES:
        try:
            return ImageFont.truetype(path, size, index=index)
        except OSError:
            continue
    print(json.dumps({"success": False, "error": "no CJK font found"}))
    sys.exit(1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", "-i", required=True)
    ap.add_argument("--output", "-o", required=True)
    ap.add_argument("--label", "-l", action="append", required=True,
                    help="文字:x,y:颜色[:角度]")
    ap.add_argument("--size", type=int, default=42)
    a = ap.parse_args()

    from PIL import Image

    img = Image.open(a.image).convert("RGBA")
    font = load_font(a.size)

    for spec in a.label:
        parts = spec.split(":")
        text, xy, color = parts[0], parts[1], parts[2] if len(parts) > 2 else "black"
        angle = float(parts[3]) if len(parts) > 3 else random.uniform(-2.5, 2.5)
        x, y = (int(v) for v in xy.split(","))
        rgb = COLORS.get(color) or tuple(
            int(color.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4))

        # 画在独立透明层，旋转后贴回，制造轻微手写歪斜感
        from PIL import ImageDraw
        pad = a.size
        w = int(font.getlength(text)) + pad * 2
        h = a.size + pad * 2
        layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        ImageDraw.Draw(layer).text((pad, pad), text, font=font, fill=rgb + (255,))
        layer = layer.rotate(angle, expand=True, resample=Image.BICUBIC)
        img.alpha_composite(layer, (x - layer.width // 2, y - layer.height // 2))

    img.convert("RGB").save(a.output)
    print(json.dumps({"success": True, "filePath": a.output}))


main()
