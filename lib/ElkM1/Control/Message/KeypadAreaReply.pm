package ElkM1::Control::Message::KeypadAreaReply;

# Messagetype: 'KA'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

ElkM1::Control::Message::KeypadAreaReply;

=cut

=head1 SYNOPSIS

#TODO

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Keypad Area Reply'  message
from the ElkM1 control. This mesage is sent in response to a request keypad area assignments request. This
message contains information on which keyapds belong to which area. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=head1 METHODS

=over 4

=cut

=item $msg->getArea($keypad) 

Return the area to which this specified keypad belongs. 

=cut

sub getArea {
    my $self = shift;
    my $keypad = shift;

    substr($self->command,2 + $keypad - 1, 1);
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
    my $self = shift;
    my $str = "KeypadAreaReply:";
    for (my $i=1;$i<=16;$i++) {
        $str .= "keypad $i area=".$self->getArea($i);
    }

    return $str;
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
