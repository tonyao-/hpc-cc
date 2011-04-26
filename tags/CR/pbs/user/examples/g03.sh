#!/bin/sh
cd g03
~/submit-tp -q short -n 2 -f ~/submit-g03.sh -j g03_test164-n2-l -i ~/examples/g03/test164.com -o ~/examples/g03/test164-n2-l.log
~/submit-tp -q short -n 4 -f ~/submit-g03.sh -j g03_test164-n4-l -i ~/examples/g03/test164.com -o ~/examples/g03/test164-n4-l.log
~/submit-tp -q short -n 2 -f ~/submit-g03.sh -j g03_test164-n2 -i /usr/local/g03/tests/com/test164.com -o ~/examples/g03/test164-n2.log
~/submit-tp -q short -n 4 -f ~/submit-g03.sh -j g03_test164-n4 -i /usr/local/g03/tests/com/test164.com -o ~/examples/g03/test164-n4.log
~/submit-tp -q short -n 2 -f ~/submit-g03.sh -j g03_test691-n2 -i /usr/local/g03/tests/com/test691.com -o ~/examples/g03/test691-n2.log
~/submit-tp -q short -n 4 -f ~/submit-g03.sh -j g03_test691-n4 -i /usr/local/g03/tests/com/test691.com -o ~/examples/g03/test691-n4.log
~/submit-tp -q short -n 2 -f ~/submit-g03.sh -j g03_test695-n2 -i /usr/local/g03/tests/com/test695.com -o ~/examples/g03/test695-n2.log
~/submit-tp -q short -n 4 -f ~/submit-g03.sh -j g03_test695-n4 -i /usr/local/g03/tests/com/test695.com -o ~/examples/g03/test695-n4.log
cd -
