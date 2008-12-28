use Test::More tests => 26;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::ZoneChangeUpdateReport');
};

my $cmd =  'ZC0022';
my $messageObj = ElkM1::Control::Message->new(command => $cmd);
my $zoneChangeUpdateReportObj= ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($zoneChangeUpdateReportObj->getZone, 2, 'zone is 2');
is($zoneChangeUpdateReportObj->getZoneStatus, 2, 'zone status is 0x02');
is($zoneChangeUpdateReportObj->getState, 'normal EOL', 'state is normal EOL');
is($zoneChangeUpdateReportObj->isShort, 0, 'is not shorted.');
is($zoneChangeUpdateReportObj->isEOL, 1, 'is EOL');
is($zoneChangeUpdateReportObj->isOpen, 0, 'is not open');
is($zoneChangeUpdateReportObj->isBypassed, 0, 'is not bypassed');
is($zoneChangeUpdateReportObj->isViolated, 0, 'is not violated');

$cmd =  'ZC208F';
$messageObj = ElkM1::Control::Message->new(command => $cmd);
$zoneChangeUpdateReportObj= ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($zoneChangeUpdateReportObj->getZone, 208, 'zone is 208');
is($zoneChangeUpdateReportObj->getZoneStatus, 0x0F, 'zone status is 0x0F');
is($zoneChangeUpdateReportObj->getState, 'bypassed short', 'state is bypassed short');
is($zoneChangeUpdateReportObj->isShort, 1, 'is shorted.');
is($zoneChangeUpdateReportObj->isEOL, 0, 'is not EOL');
is($zoneChangeUpdateReportObj->isOpen, 0, 'is not open');
is($zoneChangeUpdateReportObj->isBypassed, 1, 'is not bypassed');
is($zoneChangeUpdateReportObj->isViolated, 0, 'is not violated');

$cmd =  'ZC1275';
$messageObj = ElkM1::Control::Message->new(command => $cmd);
$zoneChangeUpdateReportObj= ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($zoneChangeUpdateReportObj->getZone, 127, 'zone is 127');
is($zoneChangeUpdateReportObj->getZoneStatus, 0x05, 'zone status is 0x0F');
is($zoneChangeUpdateReportObj->getState, 'trouble open', 'state is trouble open');
is($zoneChangeUpdateReportObj->isShort, 0, 'is not shorted.');
is($zoneChangeUpdateReportObj->isEOL, 0, 'is not EOL');
is($zoneChangeUpdateReportObj->isOpen, 1, 'is not open');
is($zoneChangeUpdateReportObj->isBypassed, 0, 'is not bypassed');
is($zoneChangeUpdateReportObj->isViolated, 0, 'is not violated');
