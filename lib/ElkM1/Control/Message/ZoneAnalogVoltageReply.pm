package ElkM1::Control::Message::ZoneAnalogVoltageReply;

# MessageType: 'ZV'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

ElkM1::Control::Message::ZoneAnalogVoltageReply;

=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('0cZV123072004E');
    # would return 7.2
    my $voltage = $msg->getVoltage(); 
    
    # -Or-
    
    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $msg = $elk->requestZoneVoltage(52); 
    print "zone 52 has a voltage of ".$msg->getVoltage;

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Zone Analog Voltage Data Reply' 
message from the ElkM1 control. This mesage is sent in response to a request zone voltage message. This message
contains the zone number and the voltage for the requested zone. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=head1 METHODS

=over 4

=cut

=item $msg->getVoltage

Obtain the zone voltage for the specified zone in decimal format.

=cut

sub getVoltage { 
	my $self = shift;
	int(substr($self->command,5,3))/10.0;
}

=item $msg->getZone

Obtain the numeric value for the zone for which voltage was requested. 

=cut

sub getZone { 
	my $self = shift;
	int(substr($self->command,2,3));
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
	my $self = shift;
	return "ZoneAnalogVoltageReply: zone=".$self->getZone.", voltage=".$self->getVoltage."V";
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
