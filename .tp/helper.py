import shutil
import sys
from pathlib import Path
from subprocess import run

if len(sys.argv) != 3:
    print(
        "Usage: python .tp/set-lesson-chapter.py LESSON_NUMBER CHAPTER_NUMBER",
    )
    exit(1)

lesson = sys.argv[1]
chapter = sys.argv[2]

if (
    run(
        [
            "forge",
            "test",
            "--match-path",
            "test/CryptozombiesTest.t.sol",
        ]
    ).returncode
    != 0
):
    print("Error: Test failed")
    exit(1)

if Path(f".tp/test/Lesson{lesson}_Chapter{chapter}.t.sol").exists():
    print("Error: File exists")
    exit(1)

shutil.copyfile(
    "./test/CryptozombiesTest.t.sol",
    f".tp/test/Lesson{lesson}_Chapter{chapter}.t.sol",
)
run(["git", "add", ".tp", "test"])
run(["git", "commit", "-m", f"Test: Lesson {lesson} Chapter {chapter}"])

run(["git", "add", "src"])
run(["git", "commit", "-m", f"Correction: Lesson {lesson} Chapter {chapter}"])
