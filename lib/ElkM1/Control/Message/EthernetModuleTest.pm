package ElkM1::Control::Message::EthernetModuleTest;

# MessageType: 'XK'

use base ElkM1::Control::Message;
use strict;

=head1 NAME

ElkM1::Control::Message::EthernetModuleTest;

=cut

=head1 SYNOPSIS

    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $msg = $elk->readMessage(); 

# TODO - finish this synopsis.
#
=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents
the 'Ethernet Module Test' message from the ElkM1 control. This message is sent
every 30 seconds to test any M1XEP Ethernet module installed in the system.

This object is usually instantiated via the MessageFactory object when a message
is read. One wouldn't normally instantiate this object directly.

=cut

# Hash to turn a day of week into a name.
my %DAY_OF_WEEK = ( 1 => 'Sunday', 
				2 => 'Monday', 
				3 => 'Tuesday', 
				4 => 'Wednesday', 
				5 => 'Thursday', 
				6 => 'Friday', 
				7 => 'Saturday' );

# Hash to turn a month into a name. 
my %MONTH = ( 1 => 'January', 
			2 => 'February', 
			3 => 'March', 
			4 => 'April', 
			5 => 'May', 
			6 => 'June', 
			7 => 'July', 
			8 => 'August',
			9 => 'September',
			10 => 'October',
			11 => 'November',
			12 => 'December' );

# Hash to turn clock mode into a name.
my %CLOCK_MODE = ( 0 => '24', 
				1 => '12' );

# Hash to turn DST mode into a name.
my %DST_MODE = ( 0 => 'Inactive', 
				1 => 'Active' );

# Hash to turn Date  mode into a name.
my %DATE_MODE = ( 0 => 'MM/DD', 
				1 => 'DD/MM' );

=head1 METHODS

=over 4

=cut

=item $msg->getSeconds

Obtain the seconds value for the test.

=cut

sub getSeconds  { 
	my $self = shift;
	return substr($self->command,2,2);
}

=item $msg->getMinutes

Obtain the minutes value for the test.

=cut

sub getMinutes { 
	my $self = shift;
	return substr($self->command,4,2);
}

=item $msg->getHour

Get the hour of the test.

=cut

sub getHour { 
	my $self = shift;
	return substr($self->command,6,2);	
}

=item $msg->getDayOfWeekValue

Get the test's day of the week.

=cut

sub getDayOfWeekValue { 
	my $self = shift;
	return int(substr($self->command,8,1));
}

=item $msg->getDayOfWeek

Get the name of the day of the week for the test. (ie: Monday, or Friday, etc)

=cut

sub getDayOfWeek { 
	my $self = shift;
	return $DAY_OF_WEEK{$self->getDayOfWeekValue};
}

=item $msg->getDay

Get the day of the month for the test.

=cut

sub getDay { 
	my $self = shift;
	return int(substr($self->command,9,2));
}

=item $msg->getMonthValue

Get the test's value of the month.
01 = Jan, 02 = Feb, etc. 

=cut

sub getMonthValue { 
	my $self = shift;
	return int(substr($self->command,11,2));
}

=item $msg->getMonth

Get the name of the month for the test.

=cut

sub getMonth { 
	my $self = shift;
	return $MONTH{$self->getMonthValue};
}

=item $msg->getYear

Get the year of the test as an integer. (ie. 05 = 2005).
Add this number to 2000 to get the correct year. 

=cut

sub getYear { 
	my $self = shift;
	int(substr($self->command,13,2));
}

=item $msg->getDSTValue

Get the Daylight Saving Time (DST) flag (0=Inactive, 1=Active).

=cut

sub getDSTValue { 
	my $self = shift;
	return substr($self->command,15,1);
}

=item $msg->getDST

Get the Daylight Saving Time (DST) status.

=cut

sub getDST { 
	my $self = shift;
	return $DST_MODE{$self->getDSTValue};
}

=item $msg->getClockModeValue

Get the clock's display mode value (0=24 hour, 1=12 hour).

=cut

sub getClockModeValue { 
	my $self = shift;
	return substr($self->command,16,1);
}

=item $msg->getClockMode

Get the clock's display mode.

=cut

sub getClockMode { 
	my $self = shift;
	return $CLOCK_MODE{$self->getClockModeValue};
}

=item $msg->getDateModeValue

Get the date's display mode value (0=MM/DD, 1=DD/MM).

=cut

sub getDateModeValue { 
	my $self = shift;
	return substr($self->command,17,1);
}

=item $msg->getDateMode

Get the date's display mode.

=cut

sub getDateMode { 
	my $self = shift;
	return $DATE_MODE{$self->getDateModeValue};
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
	my $self = shift;

	"EthernetModuleTest: time=".$self->getHour.':'.$self->getMinutes.':'.$self->getSeconds.
			" dayofweek=".$self->getDayOfWeek.' ('.$self->getDayOfWeekValue.')'.
			" month=".$self->getMonth.
			" day=".$self->getDay.
			" year=".$self->getYear.
			" DST=".$self->getDST.
			" clock_mode=".$self->getClockMode.
			" date_mode=".$self->getDateMode;
}

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

L<ElkM1::Control>, L<ElkM1::Control::Message>, L<ElkM1::Control::MessageFactory>

=cut

=head1 AUTHOR

Taras Dejneka 2007-11-18
based on work by James Russo

=cut

1;
