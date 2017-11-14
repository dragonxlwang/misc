################################################################################
####        Remove following before landing                                 ####
####        Below adds the functionality to select the test functions       ####
####        and support of pdb                                              ####
################################################################################

tests = ['***']   # replace with test functions
test_class = ***  # replace with test class
for attr in dir(test_class):
    if attr.startswith('test_') and attr not in tests:
        delattr(test_class, attr)
    elif attr in tests:
        test_func = getattr(test_class, attr)
        delattr(test_class, attr)

        def test(self):
            import sys
            sys.stdout = file('/dev/stdout', 'w')
            try:
                test_func(self)
            except:
                import pdb
                import traceback
                import sys
                import signal

                def signal_handler(signum, frame):
                    print("Exiting from pdb session")
                    sys.exit(signum)

                type, value, tb = sys.exc_info()
                traceback.print_exc()
                signal.signal(signal.SIGINT, signal_handler)
                pdb.post_mortem()

        setattr(test_class, attr, test)
