package ElkM1::Control::Message::OutputChangeUpdate;

#MessageType: 'CC'

use base ElkM1::Control::Message;

use strict;
use warnings;

=head1 NAME

ElkM1::Control::Message::OutputChangeUpdate;

=cut

=head1 SYNOPSIS

$elk = ElkM1::Control::new (host => 192.168.1.115);

$elk->controlOutputOn(output => 1);
my $msg = $elk->readMessage; 

print "output ".$msg->getOutput." has just turned ". ($msg->getState ? 'on' : 'off')
    if (ref($msg) eq 'ElkM1::Control::Message::OutputChangeUpdate');

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Output Change Update' 
message from the ElkM1 control. This mesage is sent in response to an output status being changed. The message
contains the output number and the new state. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=head1 METHODS

=over 4

=cut

=item $msg->getOutput()

Obtain the output number. 

=cut

sub getOutput { 
	my $self = shift;
	return int(substr($self->command,2,3));
}

=item $msg->getState()

The new state of the output. 1=on, 0=off

=cut

sub getState { 
	my $self = shift;
	return int(substr($self->command,5,1));
}

=item $msg->isOn()

return true if the output is on.

=cut

sub isOn { 
	my $self = shift;

	return $self->getState;
}

=item $msg->isOff()

return true if the output is off.

=cut

sub isOff { 
	my $self = shift;

	return !$self->getState;
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString { 
	my $self = shift;
	"OutputChangeUpdate: output=".$self->getOutput.", state=".($self->isOn ? 'on' : 'off');
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

1;
