from jetter.build import do_build
from jetter.thrift.types import MultiBuildResult


def main():
    print(">>>>>>>>>>>")
    do_build(targets=["//deep_retrieval:penv"], fbpkg_name="torchrec.deep_retrieval")


if __name__ == "__main__":
    main()
