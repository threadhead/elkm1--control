package ElkM1::Control::Message::CustomValueReply;

#MessageType: 'CR'

use base ElkM1::Control::Message;
use strict;
use warnings;
use Switch;
use Carp;

=head1 NAME

    ElkM1::Control::Message::CustomValueReply

=cut

=head1 SYNOPSIS

    my $msg = $elk->readCustomValue(index => 1);
    if (ref($msg) eq 'ElkM1::Control::Message::CustomValueReply') {
        print "Custom Setting 1 value is: " . $msg->getCustomValue(1) . "\n";
        print "Custom Setting 1 format is: " . $msg->getCustomValueFormat(1) . "\n";
        print "Custom Setting 1 : ". $msg->getCustomValueFormated(1) . "\n";
    }

=cut

=head1 DESCRIPTION 

    This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Custom Value Reply' message 
    from the ElkM1 control. This message is used to describe the custom settings value. 

    This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
    instantiate this object directly.

=cut

=head1 Methods

=cut

# Custom Value Formats
my %FORMAT = ( '0' => 'Number', '1' => 'Timer', '2' => 'Time of day');

=item getCustomValue($index) 

    Return the current value of the specified custom value (Custom Setting).

=cut

sub getCustomValue { 
    my $self = shift;
    my $index = shift;

    my $messageIndex = int(substr($self->message,4 , 2));
    my $messageSize = hex(substr($self->message,0 , 2));

    croak "message does not contain the custom value index requested"
      if ($messageIndex and $messageIndex != $index );

    my $i;
    if ($messageSize == 0x0E) { $i = 1;} # single entry message
    elsif ($messageSize == 0x80) { $i = $index;} # entire list
    else { croak "message size doea not match CR messages";}

    return int(substr($self->message,$i * 6, 5));
}

=item getCustomValueFormat($index) 

    Return the current value format of the specified custom value (Custom Setting).

=cut

sub getCustomValueFormat { 
    my $self = shift;
    my $index = shift;
    my $messageIndex = int(substr($self->message,4 , 2));
    my $messageSize = hex(substr($self->message,0 , 2));

    croak "message does not contain custom value index requested"
      if ($messageIndex and $messageIndex != $index );

    my $i;
    if ($messageSize == 0x0E) { $i = 1;} # single entry message
    elsif ($messageSize == 0x80) { $i = $index;} # entire list
    else { croak "message size does not match CR messages";}

    return int(substr($self->message,($i * 6) + 5, 1));
}

=item getCustomValueFormatName($index) 

    Return the current value format of the specified custom value (Custom Setting).

=cut

sub getCustomValueFormatName { 
    my $self = shift;
    my $index = shift;

    return exists($FORMAT{$self->getCustomValueFormat}) ? $FORMAT{$self->getCustomValueFormat} : '<unknown>';
}


=item getCustomValueFormated($index) 

    Return the current value of the specified custom value (Custom Setting) as a formatted string.

=cut

sub getCustomValueFormated { 
    my $self = shift;
    my $index = shift;

    switch ($self->getCustomValueFormat($index)) {
        case 0 { return ( "$FORMAT{0}-" . $self->getCustomValue($index)) } 
        case 1 { return ( "$FORMAT{1}-" . (sprintf "%02d:%02d:%02d", 
                                             (gmtime($self->getCustomValue($index)))[2,1,0])) }   
        case 2 { return ( "$FORMAT{2}-" . (sprintf ("%02d:%02d\n", 
                          map { hex($_) } ((sprintf("%x", $self->getCustomValue($index) )) =~ /(..)/g))));}
        else   { croak "custom value format not valid" }
    }

}

=item toString()

    returns a human readable string containing all information for custom value(s) returned. 

=cut

sub toString {
    my $self = shift;
    my $str = "CustomValueReply: ";
    my $index = 1;
    my $maxIndex = 0;

    switch ( hex (substr($self->message,0 , 2)) ) {
        case 0x0E { $index = int(substr($self->message,4 , 2));
                    $maxIndex = $index; }
        case 0x80 { $index = 1;
                    $maxIndex = 20; }
        else {croak "message size does not match CR messages"}
    }

    for (my $i=$index; $i<=$maxIndex; $i++) { 
        $str .= "$i=".($self->getCustomValueFormated($i)).", ";
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

eagle360 

=cut

