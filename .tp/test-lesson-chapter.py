import shutil
import sys
from subprocess import run

valid_lessons_chapter = {
    1: [2, 3, 4, 6, 7, 8, 12, 13],
    2: [2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13],
    3: [1, 2, 3, 5, 7, 8, 9, 12],
    4: [1, 2, 8, 9, 11],
    5: [4, 8],
}


def run_test(lesson: int, chapter: int) -> int:
    if lesson not in valid_lessons_chapter.keys():
        print(f"Unsupported lesson {lesson}")
        exit(1)

    if chapter not in valid_lessons_chapter[lesson]:
        print(f"Unsupported chapter {chapter} for lesson {lesson}")
        exit(1)

    print(
        f"Copying .tp/test/Lesson{lesson}_Chapter{chapter}.t.sol"
        "=> test/CryptozombiesTest.t.sol"
    )
    shutil.copyfile(
        f".tp/test/Lesson{lesson}_Chapter{chapter}.t.sol",
        "test/CryptozombiesTest.t.sol",
    )

    return run(["forge", "test", "-vvv"]).returncode


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "Usages: "
            "\n\tpython .tp/set-lesson-chapter.py LESSON_NUMBER CHAPTER_NUMBER"
            "\n\tpython .tp/set-lesson-chapter.py --all",
        )
        exit(1)

    lesson = int(sys.argv[1])
    chapter = int(sys.argv[2])

    run_test(lesson, chapter)


if __name__ == "__main__":
    exit(main())
