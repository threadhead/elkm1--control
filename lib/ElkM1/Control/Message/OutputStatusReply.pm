package ElkM1::Control::Message::OutputStatusReply;

#MessageType: 'CS'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

    ElkM1::Control::Message::OutputStatusReply

=cut

=head1 SYNOPSIS

    my $msg = $elk->requestOutputStatus;
    print 'output 25 is on? '.$msg->isOn(25) ? 'yes' : 'no';

    print 'siren is likely sounding'
        if ($msg->isOn(2));

=cut

=head1 DESCRIPTION 

    This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Output Status Reply' message 
    from the ElkM1 control. This mesage is used to describe the current status of all outputs. 

    This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
    instantiate this object directly.

=cut

=head1 Methods

=cut

=item isOn($output) 

    Return true if the specified output is on, false otherwise. 

=cut

sub isOn { 
	my $self = shift;
    my $output = shift;

    return int($self->getOutput($output));
}

=item isOff($output) 

    Return true if the specified output is off, false otherwise. 

=cut

sub isOff { 
    my $self = shift;
    my $output = shift;

    return !$self->isOn($output);
}

=item getOutput($output) 

    Return the current state of the specified output.

=cut

sub getOutput { 
    my $self = shift;
    my $output = shift;

    return int(substr($self->command,2 + $output - 1, 1));
}

=item toString()

    returns a human readable string containing all information for status of all areas. 

=cut

sub toString {
	my $self = shift;
    my $str = "OutputStatusReply: ";
    for (my $i=1;$i<=208; $i++) { 
        $str .= "$i=".($self->isOn($i) ? 'on' : 'off').", ";
    }
    return $str;
}
1;
__END__

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

ElkM1::Control, ElkM1::Control::Message, ElkM1::Control::MessageFactory

=cut

=head1 AUTHOR

James Russo <jr@halo3.net>

=cut

