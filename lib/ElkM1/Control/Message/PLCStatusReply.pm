package ElkM1::Control::Message::PLCStatusReply;

use base ElkM1::Control::Message;
use strict;

# MessageType: 'PS'

=head1 NAME

ElkM1::Control::Message::PLCStatusReply;

=cut

=head1 SYNOPSIS

#TODO 

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'PLC Status Reply' message from 
the ElkM1 control. This message is used to indicate the status of a set of PLC devices. Banks are used to provide
access to all the 256 available powerline control devices. Bank 0 is devices A1-D16, Bank 1 is E1 to H16, Bank 2 
is I1 to L16 and Bank 3 is M1 to P16. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=head1 METHODS

=cut

=item $msg->getBank

Obtain the bank this reply contains information on.

=cut

sub getBank { 
	my $self = shift;
	return int(substr($self->command,2,1));
}

=item $msg->getStatus($device)

Obtain the status for the specified device. 

=cut

sub getStatus { 
	my $self = shift;
    my $index = shift; 

	return int(substr($self->command,3 + $index,1));
}

=item $msg->toString

return a human readable value for this message.

=cut

sub toString { 
	my $self = shift;
	'PLCStatusReply: bank='.$self->getBank.', status='.join ',', map { $self->getStatus($_)} (0..63);
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
