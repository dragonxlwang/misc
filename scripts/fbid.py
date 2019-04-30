import libfb.py.employee
import getpass
import sys

if __name__ == '__main__':
    usr = sys.argv[1] if len(sys.argv) > 2 else getpass.getuser()
    print(libfb.py.employee.unixname_to_uid(usr))


