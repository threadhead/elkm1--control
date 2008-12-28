use Test::More tests => 33;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::ThermostatDataReply');
};

my $thermostatDataReplyObj = ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR012007268750000')->message);
is($thermostatDataReplyObj->getThermostat,1,'thermostat number is correct');
is($thermostatDataReplyObj->getMode,2,'thermostat mode is correct');
is($thermostatDataReplyObj->getModeName,'cool','thermostat mode is correct');
is($thermostatDataReplyObj->isHoldActive,0,'thermostat hold mode is correct');
is($thermostatDataReplyObj->getFanMode,0,'thermostat fan mode is correct');
is($thermostatDataReplyObj->getFanModeName,'auto','thermostat hold mode is correct');
is($thermostatDataReplyObj->getCurrentTemperature,72,'thermostat temperature is correct');
is($thermostatDataReplyObj->getHeatingSetpoint,68,'thermostat heating setpoint is correct');
is($thermostatDataReplyObj->getCoolingSetpoint,75,'thermostat cooling setpoint is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR992007268750000')->message);
is($thermostatDataReplyObj->getThermostat,99,'two digit thermostat number is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR990007268750000')->message);
is($thermostatDataReplyObj->getMode,0,'thermostat mode is correct');
is($thermostatDataReplyObj->getModeName,'off','thermostat mode is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR991007268750000')->message);
is($thermostatDataReplyObj->getMode,1,'thermostat mode is correct');
is($thermostatDataReplyObj->getModeName,'heat','thermostat mode is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR992007268750000')->message);
is($thermostatDataReplyObj->getMode,2,'thermostat mode is correct ');
is($thermostatDataReplyObj->getModeName,'cool','thermostat mode is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR993007268750000')->message);
is($thermostatDataReplyObj->getMode,3,'thermostat mode is correct');
is($thermostatDataReplyObj->getModeName,'auto','thermostat mode is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR994007268750000')->message);
is($thermostatDataReplyObj->getMode,4,'thermostat mode is correct');
is($thermostatDataReplyObj->getModeName,'emergency heat','thermostat mode is correct');
is($thermostatDataReplyObj->isHoldActive,0,'thermostat hold mode is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR994107268750000')->message);
is($thermostatDataReplyObj->isHoldActive,1,'thermostat hold mode is correct');
is($thermostatDataReplyObj->getFanMode,0,'thermostat fan mode is correct');
is($thermostatDataReplyObj->getFanModeName,'auto','thermostat hold mode is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR994117268750000')->message);
is($thermostatDataReplyObj->isHoldActive,1,'thermostat hold mode is correct');
is($thermostatDataReplyObj->getCurrentTemperature,72,'thermostat temperature is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR994119968750000')->message);
is($thermostatDataReplyObj->getCurrentTemperature,99,'thermostat temperature is correct');
is($thermostatDataReplyObj->getHeatingSetpoint,68,'thermostat heating setpoint is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR994119999750000')->message);
is($thermostatDataReplyObj->getHeatingSetpoint,99,'thermostat heating setpoint is correct');
is($thermostatDataReplyObj->getCoolingSetpoint,75,'thermostat cooling setpoint is correct');

$thermostatDataReplyObj = 
    ElkM1::Control::MessageFactory->instantiate(ElkM1::Control::Message->new(command => 'TR994119999990000')->message);
    is($thermostatDataReplyObj->getCoolingSetpoint,99,'thermostat cooling setpoint is correct');
