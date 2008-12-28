use Test::More tests => 14;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::ThermostatDataReply');
};
my $temperatureReplyObj = ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'ST001135')->message);
is($temperatureReplyObj->getGroup,0,'group 0 (zone probe)');
is($temperatureReplyObj->getGroupName, 'temperature probe','group name is temperature probe');
is($temperatureReplyObj->getDevice,1,'device is 1');
is($temperatureReplyObj->getTemperature,75,'temperature is 75 degrees');

$temperatureReplyObj = ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'ST102105')->message);
is($temperatureReplyObj->getGroup,1,'group 1 (keypad)');
is($temperatureReplyObj->getGroupName, 'keypad','group name is keypad');
is($temperatureReplyObj->getDevice,2,'device is 2');
is($temperatureReplyObj->getTemperature,65,'temperature is 65 degrees');

$temperatureReplyObj = ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'ST201072')->message);
is($temperatureReplyObj->getGroup,2,'group 2 (thermostat)');
is($temperatureReplyObj->getGroupName, 'thermostat','group name is thermostat');
is($temperatureReplyObj->getDevice,1,'device is 1');
is($temperatureReplyObj->getTemperature,72,'temperature is 72 degrees');

