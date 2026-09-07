#!/usr/bin/env python3
"""用 Hugging Face 免费公开 Space（Z-Image-Turbo）生成配图，免 API key。

用法：
  .venv/bin/python generate.py --prompt "..." --output ./01-topic.png
输出 JSON：{"success": true, "filePath": "..."} 或 {"success": false, "error": "..."}
"""
import argparse
import json
import shutil
import sys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", "-p", required=True, help="完整生图提示词")
    ap.add_argument("--output", "-o", required=True, help="输出图片路径")
    ap.add_argument("--resolution", "-r", default="1280x720 ( 16:9 )",
                    help="必须是 Space 下拉选单里的字面值，默认 16:9")
    ap.add_argument("--seed", type=int, default=None, help="不给则随机")
    ap.add_argument("--steps", type=int, default=8)
    ap.add_argument("--space", default="Tongyi-MAI/Z-Image-Turbo")
    a = ap.parse_args()

    try:
        import os

        from gradio_client import Client

        # 有 HF_TOKEN 時用登入額度（ZeroGPU 匿名額度極少且全 Space 共用）
        client = Client(a.space, verbose=False,
                        token=os.environ.get("HF_TOKEN") or None)
        result = client.predict(
            prompt=a.prompt,
            resolution=a.resolution,
            seed=a.seed if a.seed is not None else 42,
            steps=a.steps,
            shift=3.0,
            random_seed=a.seed is None,
            gallery_images=[],
            api_name="/generate",
        )
        item = result[0][0]
        path = item["image"] if isinstance(item, dict) else item
        if isinstance(path, dict):
            path = path.get("path") or path.get("url")
        shutil.copy(path, a.output)
        print(json.dumps({"success": True, "filePath": a.output}))
    except Exception as e:
        print(json.dumps(
            {"success": False, "error": f"{type(e).__name__}: {e}"},
            ensure_ascii=False))
        sys.exit(1)


main()
