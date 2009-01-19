package ElkM1::Control::Message::BypassedZoneStateReply;

# MessageType: 'ZB'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

ElkM1::Control::Message::BypassedZoneStateReply;

=cut

=head1 SYNOPSIS

    my $msg = $elk->readMessage; 

    print $msg->getZone. ' has just been ' $msg->isBypassed ? 'bypassed' : 'unbypassed';
        if (ref($msg) eq 'ElkM1::Control::Message::BypassedZoneStateReply') 

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'BypassedZoneStateReply' 
message from the ElkM1 control. This message is used to describe a zone change even, such as when is zone is opened,
bypassed, etc. It is sent from the ElkM1 when a zone changes status if configured to do so in the global settings. 
This indicates both logical and physical status of the zone. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=head1 METHODS

=over 4

=cut

=item $msg->getZone()

Obtain the zone which has been bypassed. 

=cut

sub getZone { 
	my $self = shift;

	return int(substr($self->command,2,3));
}

=item $msg->isBypassed()

Return true if the zone is bypassed, false if unbypassed. . 

=cut

sub isBypassed {
	my $self = shift;
	
	return int(substr($self->command,5,1));
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString { 
	my $self = shift;
	"BypassedZoneStateReply: ".$self->getZone." is ".($self->isBypassed ? 'bypassed' : 'not bypassed');
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
