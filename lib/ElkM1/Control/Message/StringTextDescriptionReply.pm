package ElkM1::Control::Message::StringTextDescriptionReply;

# MessageType: 'SD'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

    ElkM1::Control::Message::StringTextDecriptionReply

=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('1EAS100000004000000030000000000E');
    my $armedStatus = $msg->getArmedStatusName; 

    # -Or-
   
    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $msg = $elk->requestArmingStatusReport; 
    print "alarm is ".$msg->getArmedStatusName;

=cut

=head1 DESCRIPTION 

    This is the subclass of the L<ElkM1::Control::Message> object which represents the 'String Text Decription Reply' 
    message from the ElkM1 control. This mesage is sent in response to a request for text decriptions. Text decriptions
    are used to decribe zones, areas, users, keypads, outputs, tasks, telephone numbers, lights and many other items
    in the ElkM1 panel. 

    The way the Elk responds to requests for text messages might be confusing. When you request a specific string you
    will be given that string, or any string after that string whose first character is space or greater. If there is 
    no such string configured (at the index location or later) your reponse will have an index of 0 indicating that
    no strings are available. This is an optimization allowing you to quickly obtain all the relevant strings from the 
    Elk panel without having to obtain all the unconfigured strings. According to the Elk documentation this is for 
    M1 version 2.4.6 or later.

    Certain strings have the highbit of the first character is set to indicate the "show" value. This is automatically
    taken care of for you by the L<getText()> method. However, if you want to obtain the raw text use the L<getRawText()>
    method. Use the L<isShownOnKeyPad()> method to access the value of this high bit. 

    This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
    instantiate this object directly.

=cut

my %TYPES = ( '0' => 'zone',
			'1' => 'area',
			'2' => 'user',
			'3' => 'keypad',
			'4' => 'output',
			'5' => 'task',
			'6' => 'telephone',
			'7' => 'light',
			'8' => 'alarm duration',
			'9' => 'custom settings',
			'10' => 'counter',
			'11' => 'thermostat',
			'12' => 'function key 1',
			'13' => 'function key 2',
			'14' => 'function key 3',
			'15' => 'function key 4',
			'16' => 'function key 5',
			'17' => 'function key 6');

=head1 Methods

=cut

=item getType()

    Obtain the value of the text type. This is a integer which represents the type of text string being
    obtained. This type gives context to the index value. See the Elk documentation for these values.
    See L<getTypeName> for a human readable format of these types. 

=cut

sub getType { 
	my $self = shift;
	return int(substr($self->command,2,2));
}

=item getTypeName()

    Obtain a human readable value for the type of this message. Will return something like 'light' or 'thermostat'.
    See L<getType> for a numeric value for these types.

=cut

sub getTypeName  {
	my $self = shift;
	return exists($TYPES{$self->getTypeValue}) ? $TYPES{$self->getTypeValue} : '<unknown>';
}

=item getIndex()

    Obtain the index for this response. The index may not be the index of the item you requested if that item's first character is a space of less. If
    the requested string starts will a space the next string in numerical order which starts with a space will be obtained. If there are no other strings
    in order, an index of 0 will be returned.

=cut

sub getIndex {
	my $self = shift;
	return int(substr($self->command,4,3));
}

=item getRawText()

    Obtain the text as returned from the ElkM1. No masking is done to remove the possible highbit in the first
    character which indicates the 'Show On Keypad' setting.

=cut

sub getRawText { 
    my $self = shift;

    return substr($self->command,7,16);
}

=item getText()

    Obtain the text as returned from the ElkM1. The high bit of the first character is masked out to 
    show just the normal characters. See L<getRawText()> to access all the information. 

=cut

sub getText { 
	my $self = shift;
	my $text = $self->getRawText;

    substr($text,0,1) = chr(ord(substr($text,0,1)) & 0x7F);
}

=item isShownOnKeypad()

    Return true if the string is shown on the keypad. This only makes sense for things which are available
    to be shown on the keypad such as tasks, etc. 

=cut

sub isShownOnKeypad { 
    my $self = shift;
    my $text = $self->getRawText;

    return int((ord(substr($text,0,1)) & 0x80) == 0x80);
}

=item toString()

    returns a human readable string containing all information for status of all areas. 

=cut

sub toString {
	my $self = shift;
	"StringTextDescriptionReply: type=".$self->getType." (".$self->getTypeValue."), index=".$self->getIndex.", text='".$self->getText.'\'';
}

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

ElkM1::Control, ElkM1::Control::Message, ElkM1::Control::MessageFactory

=cut

=head1 AUTHOR

James Russo <jr@halo3.net>

=cut

1;
