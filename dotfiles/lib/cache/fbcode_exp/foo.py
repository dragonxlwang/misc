from bar import foobar
import sys

if __name__ == "__main__":
    print("===")
    print(__package__)
    print(__name__)
    print("===")
    print(sys.path)
    print("===")
