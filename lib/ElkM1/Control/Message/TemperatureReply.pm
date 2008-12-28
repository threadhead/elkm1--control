package ElkM1::Control::Message::TemperatureReply;

use base ElkM1::Control::Message;
use Carp;
use warnings;
use strict;

# MessageType: 'ST'

=head1 NAME

ElkM1::Control::Message::TemperatureReply;

=cut

=head1 SYNOPSIS

    my $msg = $elk->readMessage;

    print "Temperature is ".$msg->getTemperature"
        if (ref($msg) eq 'ElkM1::Control::Message::TemperatureReply') 

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Temperature Reply' message
from the ElkM1 control. This message is sent in response to a temperature request being send. The reply
contains information on the group being request (keypad, temperature sensor, or thermostat), the device
and the actual temperature. This object automatically does the math to return a valid temperature depending
on the group. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=head1 METHODS

=over 4

=cut

# The Temperature groups. 

my %GROUPS = ( 
			'0' => 'temperature probe',
			'1' => 'keypad',
			'2' => 'thermostat'
);

=item $msg->getTemperature()

Obtain the temperature provided in this reply. The format
(C vs. F) of the temperature will depend on the ElkM1 settings. 

=cut

sub getTemperature { 
	my $self = shift;
	my $temp = substr($self->command,5,3);

	if ($self->getGroup == '0') { 
		return int($temp - 60);
	} elsif ($self->getGroup == '1')  {
		return int($temp - 40);
	} elsif ($self->getGroup == '2') { 
		return int($temp);
	} else {
		return "<unknown type ".$self->getGroup.">";
	}
}

=item $msg->getGroup()

Obtain the group for which the temperature is being reported. 
0 is a temperature probe, 1 is a keypad, and 2 is a thermostat.

=cut

sub getGroup { 
	my $self = shift;
	return int(substr($self->command,2,1));
}

=item $msg->getGroupName()

Obtain the name of the group for which the temperature is being reported. 
It will return 'temperature probe', 'keypad', or 'thermostat'.

=cut

sub getGroupName { 
	my $self = shift;
	return exists($GROUPS{$self->getGroup}) ? $GROUPS{$self->getGroup} : '<unknown>';
}

=item $msg->getDevice()

Get the device for which the temperature is being reported. This would
be a keypad for the keypad group, a zone for the temperature probe group, 
and a thermostat for the thermostat group.

=cut

sub getDevice { 
	my $self = shift;
	return int(substr($self->command,3,2));
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
	my $self = shift;
	return "TemperatureReply: group=".$self->getGroup." (".$self->getGroup."), index=".$self->getDevice.", temperature=".$self->getTemperature;
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
