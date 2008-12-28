package ElkM1::Control::Message::KeypadKeyChangeUpdate;

use base ElkM1::Control::Message;
use strict;
use warnings;

# MessageType: 'KC'

=head1 NAME

ElkM1::Control::Message::KeypadKeyChangeUpdate;

=cut

=head1 SYNOPSIS

#TODO 

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Keypad KeyChange Update' 
message from the ElkM1 control. This mesage is sent in response to any keypad button pressed or other keypad
event. 
contains the zone number and the voltage for the requested zone. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=head1 METHODS

=over 4

=cut

my %KEY_MAP = ( '0' => 'No key',
				'11' => '*',
				'12' => '#',
				'13' => 'F1',
				'14' => 'F2',
				'15' => 'F3',
				'16' => 'F4',
				'17' => 'Stay',
				'18' => 'Exit',
				'19' => 'Chime',
				'20' => 'Bypass',
				'21' => 'Elk',
				'22' => 'Down',
				'23' => 'Up',
				'24' => 'Right',
				'25' => 'Left',
				'26' => 'F6',
				'27' => 'F5',
				'28' => '<datakeymode>');


# Method to access the IlluminiationStatus array located 5 in on the command.

sub _getIlluminationStatusArray { 
	my $self = shift;
	return substr($self->command,6,6);
}

# Method to access the beep and chime mode array located 12 in on the command.

sub _getBeepAndChimeModeArray { 
	my $self = shift;
	return substr($self->command,13,8);
}

=item $msg->getKeypadNumber()

Obtain the number of the keypad where the keychange occurred. 

=cut

sub getKeypadNumber { 
	my $self = shift;
	return int(substr($self->command,2,2));
}

=item $msg->getKeyNumber()

Obtain the KeyNumber which was pressed. 

=cut

sub getKeyNumber { 
	my $self = shift;
	return int(substr($self->command,4,2));
}

=item $msg->getKeyName()

Obtain the name of the key which was pressed. 

=cut

sub getKeyName { 
	my $self = shift;
	return $KEY_MAP{$self->getKeyNumber};
}

=item $msg->isCodeRequiredToBypass()

True if a code is required to bypass zones. 

#TODO figure out why this is here. 

=cut

sub isCodeRequiredToBypass { 
	my $self = shift;
	return int(substr($self->command,12,1));
}

=item $msg->getBeepMode()

Obtain the beep/chime mode for the specified area. 

#TODO figure out why this is here. 
#TODO update with information from document. 

=cut
	
sub getBeepMode { 
	my $self = shift;
	my $area = shift || 1;

	return substr($self->_getBeepAndChimeModeArray,$area - 1,1)
}

=item $msg->getIlluminationStatus($functionKey)

/bin/bash: nd: command not found
argument is 1 for F1, 2 for F2, etc. 

=cut

sub getIlluminationStatus { 
	my $self = shift;
    my $key = shift;

    int(substr($self->_getIlluminationStatusArray,$key - 1,1));
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString { 
	my $self = shift;
	'KeypadKeyChangeUpdate: keypad='.$self->getKeypadNumber.', '.
		'key='.$self->getKeyName.' ('.$self->getKeyNumber.'), '.
	    'codeRequiredToBypass='.$self->isCodeRequiredToBypass.', '. 
		'beepMode='.join ',', map { $self->getBeepMode($_) } (1..8);

    #TODO add IlluminctionStatus.
    #TODO add BeepMode
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
