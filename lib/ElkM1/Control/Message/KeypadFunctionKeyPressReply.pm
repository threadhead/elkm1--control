package ElkM1::Control::Message::KeypadFunctionKeypressReply;
use strict;
use base qw(ElkM1::Control::Message);

=head1 NAME

ElkM1::Control::Message::KeypadFunctionKeypres;

=cut

=head1 SYNOPSIS

#TODO

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Keypad Function Keypress Reply' 
message from the ElkM1 control. This message is sent in response to a keypad function key press message. 

#TODO figure out when this message is sent. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

# The chime mode mappings. 

my %CHIME_MODE = ('0' => 'Off',
				  '1' => 'Chime Only',
				  '2' => 'Voice Only',
				  '3' => 'Chime/Voice');

# The key mappings. 

my %KEY_MAP = ( '1' => 'F1',
				'2' => 'F2',
				'3' => 'F3',
				'4' => 'F4',
				'5' => 'F5',
				'6' => 'F6',
				'*' => '*',
				'C' => 'chime');

=head1 METHODS

=over 4

=cut

# Method to obtain the chime array from the command. 

sub _getChimeArray { 
	my $self = shift;
	substr($self->command,5,8);
}

=item $msg->getKeypadNumber()

Obtain the keypad number where this even occurred. 

=cut

sub getKeypadNumber {
	my $self = shift;
	return substr($self->command,2,2);
}

=item $msg->getFunctionKey() 

Return the number of the function key which was pressed. Returns
1..6 for F1..F6 or * for '*' and 'C' for chime.

=cut

sub getFunctionKey { 
	my $self = shift;
	return int(substr($self->command,4,1));
}

=item $msg->getFunctionKeyName() 

Return the name of the function key which was pressed. Can return
'F1' .. 'F6', '*' or 'chime'. 

=cut

sub getFunctionKeyName { 
	my $self = shift;
	exists $KEY_MAP{$self->getKeyValue} ? $KEY_MAP{$self->getKeyValue} : '<unknown>';
}

=item $msg->getChimeModeName()

Return the chime mode. One of the following: 'Off', 'Chime Only', 'Voice Only', 'Chime/Voice'.

=cut

sub getChimeMode { 
	my $self = shift;
	my $area = shift;
	my $val = substr($self->_getChimeArray,$area - 1, 1);
	exists $CHIME_MODE{$val} ? $CHIME_MODE{$val} : "unknown $val";
}

=item $msg->toString

return a human readable value for this message.

=cut

sub toString { 
	my $self = shift;
	my $str = 'KeypadFunctionKeypressReply: keypad='.$self->getKeypadNumber.', '.
		'FunctionKey='.$self->getFunctionKey.' ('.$self->getFunctionKeyValue.'), ';

	for (my $i=1;$i<=8;$i++) {
		$str .= " ChimeMode($i) = ".$self->GetChimeMode($i);
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
