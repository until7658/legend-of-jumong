from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SHEETS = ROOT / "assets" / "portraits" / "dialogue" / "_source_sheets"
KEYED = ROOT / "tmp" / "dialogue_portraits_keyed"

SPECS: dict[str, tuple[int, int, list[str]]] = {
    "jumong": (3, 2, ["neutral", "confident", "irritated", "suspicious", "wounded", "determined"]),
    "yuhwa": (2, 2, ["calm", "concerned", "stern", "sorrow_resolved"]),
    "king_geumwa": (2, 2, ["neutral", "approving", "suspicious", "commanding"]),
    "daeso": (2, 2, ["polite_smile", "mocking", "uneasy", "cold"]),
    "court_official": (3, 1, ["neutral", "concerned", "firm"]),
    "fisherman": (2, 1, ["concerned", "relieved"]),
    "ferry_warden": (2, 1, ["alert", "commanding"]),
    "mugol": (3, 1, ["dry_smile", "concerned", "encouraging"]),
    "aran": (2, 1, ["anxious", "urgent"]),
    "haemyeong": (3, 1, ["disciplined", "cold", "defensive"]),
    "hyeopbo": (2, 1, ["neutral", "quiet_warning"]),
    "oi": (2, 1, ["neutral", "confrontational"]),
    "mari": (2, 1, ["neutral", "focused"]),
}


def magenta_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    rgb = image.convert("RGB")
    pixels = rgb.load()
    xs: list[int] = []
    ys: list[int] = []
    for y in range(rgb.height):
        for x in range(rgb.width):
            red, green, blue = pixels[x, y]
            if red > 180 and green < 100 and blue > 120:
                xs.append(x)
                ys.append(y)
    if not xs:
        return (0, 0, image.width, image.height)
    return (min(xs), min(ys), max(xs) + 1, max(ys) + 1)


def normalize(panel: Image.Image) -> Image.Image:
    panel = panel.crop(magenta_bbox(panel)).convert("RGB")
    panel.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (1024, 1024), (255, 0, 255))
    x = (1024 - panel.width) // 2
    y = 1024 - panel.height
    canvas.paste(panel, (x, y))
    return canvas


def main() -> None:
    KEYED.mkdir(parents=True, exist_ok=True)
    written = 0
    for character_id, (columns, rows, expressions) in SPECS.items():
        sheet = Image.open(SHEETS / f"{character_id}.png").convert("RGB")
        for index, expression_id in enumerate(expressions):
            column = index % columns
            row = index // columns
            left = round(sheet.width * column / columns)
            right = round(sheet.width * (column + 1) / columns)
            top = round(sheet.height * row / rows)
            bottom = round(sheet.height * (row + 1) / rows)
            panel = sheet.crop((left, top, right, bottom))
            out_dir = KEYED / character_id
            out_dir.mkdir(parents=True, exist_ok=True)
            normalize(panel).save(out_dir / f"{expression_id}.png")
            written += 1
    print(f"WROTE_KEYED={written}")


if __name__ == "__main__":
    main()
