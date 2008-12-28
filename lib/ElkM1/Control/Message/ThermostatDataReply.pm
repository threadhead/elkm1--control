package ElkM1::Control::Message::ThermostatDataReply;

use base ElkM1::Control::Message;
use Carp;
use warnings;
use strict;

# MessageType: 'ST'

=head1 NAME

ElkM1::Control::Message::ThermostatDataReply

=cut

=head1 SYNOPSIS

    my $msg = $elk->requestThermostatData(thermostat => 1);

    print "Thermostat: ".$msg->getThermostat";
    print "   mode: ".$msg->getModeName;
    print "   hold: ".$msg->isHoldActive;
    print "   fan mode: ".$msg->getFanModeName;
    print "   current temperature: ".$msg->getCurrentTemperautre;
    print "   heating set point: ".$msg->getHeatingSetpoint;
    print "   cooling set point: ".$msg->getCoolingSetpoint;
    print "   current humidity: ".$msg->getHumidity;

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Thermostat Reply Data' message
from the ElkM1 control. This message is sent in response to a thermostat data request being sent. The reply contains
information on the specific thermostat. This object automatically does the math to return a valid temperature depending
on the group. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=head1 METHODS

=over 4

=cut

# Thermostat modes

my %MODE = ( '0' => 'off', '1' => 'heat', '2' => 'cool', '3' => 'auto', '4' => 'emergency heat' );

# Fan modes
my %FAN_MODE = ( '0' => 'auto', '1' => 1 ); 

=item $msg->getThermostat

Obtain the thermostat number this message contains information on.

=cut

sub getThermostat { 
	my $self = shift;
	int(substr($self->command,2,2));
}

=item $msg->getModeName()

Obtain the mode the thermostat is current in as a string. The string
can be one of the following 'off', 'heat', 'cool', 'auto', 'emergency heat'
or '<unknown>' if some unknown value is returned. 

=cut

sub getModeName { 
	my $self = shift;
    my $mode = $self->getMode;
	return exists $MODE{$mode} ? $MODE{$mode} : "<unknown>";
}

=item $msg->getMode()

Obtain the mode the thermostat is current in as an integer. The
valid values are 0 for off, 1 for heat, 2 for cool, 3 for auto
and 4 for emergency heat. 

=cut

sub getMode {
	my $self = shift;
    substr($self->command,4,1);
}

=item $msg->isHoldActive()

Return true if the thermostat is currently in 'hold' mode. 

=cut

sub isHoldActive {
	my $self = shift;
    substr($self->command,5,1);
}

=item $msg->getFanModeName()

Obtain the fan mode for the thermstat as a string. The valid
values are 'auto', and 'on' or '<unknown>' if an unknown
value is found. 

=cut

sub getFanModeName {
	my $self = shift;
    exists $FAN_MODE{$self->getFanMode} ? $FAN_MODE{$self->getFanMode} : '<unknown>';
}

=item $msg->getFanMode()

Obtain the fan mode for the thermstat as a integer. The valid
values are 0 for auto, and 1 for on. 

=cut

sub getFanMode {
	my $self = shift;
    int(substr($self->command,6,1));
}

=item $msg->getCurrentTemperature()

Obtain the current temperature from the thermostat in Farenheight as an integer.

=cut

sub getCurrentTemperature {
	my $self = shift;
    int(substr($self->command,7,2));
}

=item $msg->getHeatingSetpoint()

Obtain the heating setpoint for the thermostat. 

=cut

sub getHeatingSetpoint { 
	my $self = shift;
    int(substr($self->command,9,2));
}

=item $msg->getCoolingSetpoint()

Obtain the cool setpoint for the thermostat. 

=cut

sub getCoolingSetpoint { 
	my $self = shift;
    int(substr($self->command,11,2));
}

=item $msg->getHumidity()

Obtain the humidity from the thermostat

=cut

sub getHumidity { 
	my $self = shift;
    int(substr($self->command,13,2));
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
	my $self = shift;
	return "ThermostatDataReply: thermostat=".$self->getThermostat.", ".
    "mode=".$self->getModeName." (".$self->getMode."), ".
    "fanmode=".$self->getFanModeName." (".$self->getFanMode."), ".
    "hold=".($self->isHoldActive ? 'on' : 'off').", ".
    "currentTemperature=".$self->getCurrentTemperature.", ".
    "coolingSetPoint=".$self->getCoolingSetpoint.", ".
    "heatingSetPoint=".$self->getHeatingSetpoint;
}

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

L<ElkM1::Control>, L<ElkM1::Control::Message>, L<ElkM1::Control::MessageFactory>

=cut

=head1 AUTHOR

James Russo <jr@halo3.net>

=cut

1;
