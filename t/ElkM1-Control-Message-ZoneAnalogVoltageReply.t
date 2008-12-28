use Test::More tests => 6;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::ZoneAnalogVoltageReply');
};

my $messageObj = ElkM1::Control::Message->new(command => 'ZV015682');
my $analogVoltageObj= ElkM1::Control::MessageFactory->instantiate($messageObj->message);
is($analogVoltageObj->getZone,15,'zone is correct');
is($analogVoltageObj->getVoltage,68.2,'voltage is correct');

$messageObj = ElkM1::Control::Message->new(command => 'ZV208120');
$analogVoltageObj= ElkM1::Control::MessageFactory->instantiate($messageObj->message);
is($analogVoltageObj->getZone,208,'zone is correct');
is($analogVoltageObj->getVoltage,12.0,'voltage is correct');
