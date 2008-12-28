package ElkM1::Control::Message::SystemLogUpdate;

# MessageType: 'LD'

use base ElkM1::Control::Message;
use strict;

=head1 NAME

ElkM1::Control::Message::SystemLogUpdate;

=cut

=head1 SYNOPSIS

    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $msg = $elk->readMessage(); 

# TODO - finish this synopsis.
#
=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'System Log Update' message 
from the ElkM1 control. This mesage is sent in response to a request zone voltage message. This message contains
a log entry from the Elk panel. This event will be generated as events are logged on the panel or in response
to a 'Request System Log Data' message.

The information in this object includes the date/time of the event, the event area, and the 4 digit event number. 

#TODO figure out the values for event.

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

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

=head1 METHODS

=over 4

=cut

=item $msg->getEvent

Obtain the event value for this log entry. The event 
object is a 4 digit number which represents the type
of event.

=cut

sub getEvent  { 
	my $self = shift;

	return substr($self->command,2,4);
}

=item $msg->getEventNumberData

This is an argument to the Event. This could be used to represent a zone number, user number, etc. 
The defition of this field depends on the Event value. 

=cut

sub getEventNumberData { 
	my $self = shift;
	return substr($self->command,6,3);
}

=item $msg->getArea

This is the area in which the event occurred. 

=cut

sub getArea { 
	my $self = shift;
	return substr($self->command,9,1);
}

=item $msg->getHour

Get the hour of the event.

=cut

sub getHour { 
	my $self = shift;
	return substr($self->command,10,2);	
}

=item $msg->getMinute

Get the minute of the event.

=cut

sub getMinute { 
	my $self = shift;
	return substr($self->command,12,2);	
}

=item $msg->getMonthValue

Get the value of the month from the event.
01 = Jan, 02 = Feb, etc. 

=cut

sub getMonthValue { 
	my $self = shift;
	return int(substr($self->command,14,2));
}

=item $msg->getMonth

Get the name of the month from the event.
of the event.

=cut

sub getMonth { 
	my $self = shift;
	return $MONTH{$self->getMonthValue};
}

=item $msg->getDay

Get the day of the month for the event.

=cut

sub getDay { 
	my $self = shift;
	return int(substr($self->command,16,2));
}

=item $msg->getIndex

Get the index for this event. All entries
have a unique index number frmo 1 to 511.

=cut

sub getIndex { 
	my $self = shift;
	return substr($self->command,18,3);
}

=item $msg->getDayOfWeekValue

Get the value for the day of the week for the event. 1 = Sunday, 2 = Monday, etc. 

=cut

sub getDayOfWeekValue {
	my $self = shift;
	substr($self->command,21,1);
}

=item $msg->getDayOfWeek

Get the name of the day of the week for the event. (ie: Monday, or Friday, etc)

=cut

sub getDayOfWeek { 
	my $self = shift;
	return $DAY_OF_WEEK{$self->getDayOfWeekValue};
}

=item $msg->getYear

Get the year of the event as an integer. (ie. 5 = 2005).
Add this number to 2000 to get the correct year. 

=cut

sub getYear { 
	my $self = shift;
	int(substr($self->command,22,2));
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
	my $self = shift;

	"SystemLogUpdate: event=".$self->getEvent.
			" data=".$self->getEventNumberData.
			" area=".$self->getArea.
			" time=".$self->getHour.':'.$self->getMinute.
			" dayofweek=".$self->getDayOfWeek.' ('.$self->getDayOfWeekValue.')'.
			" month=".$self->getMonth.
			" day=".$self->getDay.
			" year=".$self->getYear;
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
