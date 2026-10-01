import os
import runpy

runpy.run_path(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "bn2_styles", "gen_text.py"), run_name="__main__")
