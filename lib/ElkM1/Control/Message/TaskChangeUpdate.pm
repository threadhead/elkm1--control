package ElkM1::Control::Message::TaskChangeUpdate;

# MessageType: 'TC'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

ElkM1::Control::Message::TaskChangeUpdate;

=cut

=head1 SYNOPSIS

    my $msg = $elk->readMessage;

    print "Task ".$msg->getTask." has just fired."
        if (ref($msg) eq 'ElkM1::Control::Message::TaskChangeUpdate') 

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Task Change Update' message
from the ElkM1 control. This mesage is sent in response to a task being activated. This activation could occur
via the keypad or via one of the rules. The message contains the task number which has activated. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=head1 METHODS

=over 4

=cut

=head1 METHODS

=over 4

=cut

=item $msg->getTask() 

Obtain the task number which has been activated.

=cut

sub getTask { 
	my $self = shift;
	return int(substr($self->command,2,3));
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString { 
	my $self = shift;
	"TaskChangeUpdate: task=".$self->getTask;
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
