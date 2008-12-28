package ElkM1::Control::Message::PLCChangeUpdate;

use base ElkM1::Control::Message;
use strict;

# MessageType: 'PC'

=head1 NAME

ElkM1::Control::Message::PLCChangeUpdate;

=cut

=head1 SYNOPSIS

#TODO 

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'PLC Change Update' message from 
the ElkM1 control. This message is used to indicate that certain PLC (power line control) events have occurred. Such
as a light being turned on, etc. This reports in X10 type codes, but these are mapped to UPB and other technologies
according to the documentation. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=head1 METHODS

=cut

=item $msg->getHouseCode

Obtain the house code 'A'..'P' for this PLC event.

=cut

sub getHouseCode { 
	my $self = shift;
	return substr($self->command,2,1);
}

=item $msg->getUnitCode

Obtain a unit code for this event 1..16

=cut

sub getUnitCode { 
	my $self = shift;
	return int(substr($self->command,3,2));
}

=item $msg->getStatus

Obtain the new status of the device. Could be 0 for off, 1 for on 2-99 for a light
level percentage. 

=cut

sub getStatus { 
	my $self = shift;
	return int(substr($self->command,5,2));
}

=item $msg->toString

return a human readable value for this message.

=cut

sub toString { 
	my $self = shift;
	'PLCChangeUpdate: house='.$self->getHouseCode.', unit='.$self->getUnitCode.', status='.$self->getStatus;
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
