import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from zipfile import ZIP_DEFLATED, ZipFile


CONFIG = Path(__file__).resolve().parent
ROOT = CONFIG.parents[1]
MEDIA = {".png", ".wav"}


def build(godot: Path, output: Path) -> None:
    manifest = json.loads((ROOT / "manifest.json").read_text(encoding="utf-8"))
    mod_id = f"{manifest['namespace']}-{manifest['name']}"
    prefix = Path("mods-unpacked", mod_id)

    sources = [ROOT / "manifest.json", *ROOT.glob("*.gd")]
    for folder in ("content", "content_data", "extensions", "translations"):
        sources.extend(p for p in (ROOT / folder).rglob("*") if p.is_file() and p.suffix != ".import")

    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=output.parent) as tmp:
        work = Path(tmp)
        project = work / "project"
        project.mkdir()
        for name in ("project.godot", "export_presets.cfg"):
            shutil.copyfile(CONFIG / name, project / name)

        assets = []
        for source in sources:
            if source.suffix.lower() in MEDIA:
                asset = project / prefix / source.relative_to(ROOT)
                asset.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source, asset)
                assets.append(asset)

        subprocess.run(
            [str(godot), "--no-window", "--audio-driver", "Dummy", "--path", str(project),
             "--export-pack", "Assets", str(work / "assets.pck")],
            check=True,
        )

        generated = set((project / ".import").glob("*.md5"))
        for asset in assets:
            sidecar = asset.with_name(asset.name + ".import")
            settings = sidecar.read_text(encoding="utf-8")
            source_uri = "res://" + asset.relative_to(project).as_posix()
            targets = re.findall(r'^path(?:\.[^=]+)?="res://(\.import/[^"/]+)"$', settings, re.MULTILINE)
            if f'source_file="{source_uri}"' not in settings or not targets:
                raise ValueError(f"Invalid import metadata for {source_uri}")
            generated.add(sidecar)
            for target in targets:
                imported = project / target
                if not imported.is_file() or imported.stat().st_size == 0:
                    raise ValueError(f"Missing imported file for {source_uri}: {target}")
                generated.add(imported)

        result = work / "mod.zip"
        with ZipFile(result, "w", compression=ZIP_DEFLATED) as archive:
            for source in sorted(sources):
                archive.write(source, (prefix / source.relative_to(ROOT)).as_posix())
            for source in sorted(generated):
                archive.write(source, source.relative_to(project).as_posix())
        result.replace(output)
    print(f"Built {output.name} with {len(assets)} imported assets.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build the Brotato mod ZIP from its raw assets.")
    parser.add_argument("godot", type=Path, help="path to the Godot 3.6.2 editor")
    parser.add_argument("output", type=Path, help="destination ZIP")
    args = parser.parse_args()
    build(args.godot.resolve(), args.output.resolve())
