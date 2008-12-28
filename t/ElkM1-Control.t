# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl ElkM1-Control.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More no_plan;
BEGIN { use_ok('ElkM1::Control') };

#########################

eval { ElkM1::Control->new(host => 'somehost', wank => 1); };
like($@,qr/wank/,"extra argument to new");
eval { ElkM1::Control->new(host => 'somehost', port => 'someport'); };
like($@,qr/port/,"invalid port specified");
eval { ElkM1::Control->new(host => 'somehost', debug => 'yes'); };
like($@,qr/'debug' \(yes\) is invalid/,"invalid debug specified");
eval { ElkM1::Control->new(); };
like($@,qr/required argument 'host'/,"missing host");
