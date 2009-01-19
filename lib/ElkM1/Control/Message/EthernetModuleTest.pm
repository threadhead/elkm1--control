package ElkM1::Control::Message::EthernetModuleTest;

use base ElkM1::Control::Message;
use Carp;
use warnings;
use strict;

# MessageType: 'XK'

=head1 NAME

ElkM1::Control::Message::EthernetModuleTest;

=cut

=head1 SYNOPSIS

    my $msg = $elk->readMessage;

    print "EthernetModuleTest is ".$msg->getString"
        if (ref($msg) eq 'ElkM1::Control::Message::EthernetModuleTest') 

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Ethernet Module Test' message
from the ElkM1 control. This message is sent in response to an ethernet module every 30 seconds. The reply
contains the current date and time of the ElkM1 panel. DO NOT REPLY TO THIS MESSAGE. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=head1 METHODS

=over 4

=cut

=item $msg->getString()

Just get the data portion of the message for display in the toString method.

=cut

sub getString { 
	my $self = shift;
	return substr($self->command,4,18);
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
	my $self = shift;
	return "EthernetModuleTest: string=".$self->getString;
}

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

L<ElkM1::Control>, L<ElkM1::Control::Message>, L<ElkM1::Control::MessageFactory>

=cut

=head1 AUTHOR

Karl Smith

=cut

1;
