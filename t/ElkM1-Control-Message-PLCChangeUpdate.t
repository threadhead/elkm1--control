use Test::More tests => 8;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::PLCChangeUpdate');
};

my $messageObj = ElkM1::Control::Message->new(command => 'PCA0100');
my $PLCChangeUpdate= ElkM1::Control::MessageFactory->instantiate($messageObj->message);
is($PLCChangeUpdate->getHouseCode,'A','house code is A');
is($PLCChangeUpdate->getUnitCode,1,'unit code is 1');
is($PLCChangeUpdate->getStatus,0,'status is 0 (OFF)');

$messageObj = ElkM1::Control::Message->new(command => 'PCP1699');
$PLCChangeUpdate= ElkM1::Control::MessageFactory->instantiate($messageObj->message);
is($PLCChangeUpdate->getHouseCode,'P','house code is A');
is($PLCChangeUpdate->getUnitCode,16,'unit code is 1');
is($PLCChangeUpdate->getStatus,99,'status is 99 (near full brightness)');
