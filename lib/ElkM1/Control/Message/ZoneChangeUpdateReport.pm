package ElkM1::Control::Message::ZoneChangeUpdateReport;
use base ElkM1::Control::Message;
use strict;

# MessageType: 'ZC'

=head1 NAME

ElkM1::Control::Message::ZoneChangeUpdateReport;

=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('D6ZSD...000CC');
    my $violated = $msg->isViolated(); 

    if ($msg->isOpen) { warn $msg->getZone.' is open'; }

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Zone Change Update Report Data' 
message from the ElkM1 control. This message is used to describe a zone change even, such as when is zone is opened,
bypassed, etc. It is sent from the ElkM1 when a zone changes status if configured to do so in the global settings. 
This indicates both logical and physical status of the zone. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=item $msg->getZone

obtain the numeric value of the zone which has changed. 

=cut

sub getZone { 
	my $self = shift;

	return int(substr($self->command,2,3));
}

=item $msg->getZoneStatus

obtain the numeric value of the current zone status. This values here 
are described in the Elk documentation.

=cut

sub getZoneStatus { 
	my $self = shift;
	return hex(substr($self->command,5,1));
}

=item $msg->isNormal

return true if the zone is normal

=cut

sub isNormal {
	my $self = shift;
	return (($self->getZoneStatus >> 2) == 0x00) ? 1 : 0;
}

=item $msg->isTrouble

return true if the zone is in trouble condition

=cut

sub isTrouble {
	my $self = shift;
	return (($self->getZoneStatus >> 2) == 0x01) ? 1 : 0;
}

=item $msg->isViolated

return true if the zone is currently violated.

=cut

sub isViolated { 
	my $self = shift;
	return (($self->getZoneStatus >> 2) == 0x02) ? 1 : 0;
}

=item $msg->isBypassed

return true if the zone is currently bypassed.

=cut

sub isBypassed {
	my $self = shift;
	return (($self->getZoneStatus >> 2) == 0x03) ? 1 : 0;
}

=item $msg->isUnconfigured

return true if the zone is currently unconfigured.

=cut

sub isUnconfigured { 
	my $self = shift;
	return (($self->getZoneStatus & 0x03) == 0x00) ? 1 : 0;
}

=item $msg->isOpen

return true if the zone is currently physically open (not shorted).

=cut

sub isOpen {
	my $self = shift;
	return (($self->getZoneStatus & 0x03) == 0x01) ? 1 : 0;
}

=item $msg->isEOL

return true if the zone is currently physically EOL (seeing EOL resistor).

=cut

sub isEOL {
	my $self = shift;
	return (($self->getZoneStatus & 0x03) == 0x02) ? 1 : 0;
}

=item $msg->isShort

return true if the zone is currently shorted 

=cut

sub isShort { 
	my $self = shift;
	return (($self->getZoneStatus & 0x03) == 0x03) ? 1 : 0;
}

=item $msg->getState

return the human readable state for the zone. This will return a string
like 'normal EOL' or 'bypassed short'.

=cut

sub getState { 
	my $self = shift;
	my $str;

	$str .= 'normal '
		if ($self->isNormal);

	$str .= 'trouble '
		if ($self->isTrouble);
	
	$str .= 'violated '
		if ($self->isViolated);
	
	$str .= 'bypassed '
		if ($self->isBypassed);

	$str .= 'unconfigured'
		if ($self->isUnconfigured);

	$str .= 'open'
		if ($self->isOpen);

	$str .= 'EOL'
		if ($self->isEOL);

	$str .= 'short'
		if ($self->isShort);

	return $str; 
}

=item $msg->toString

return a human readable value for this message.

=cut

sub toString { 
	my $self = shift;
	"ZoneChangeUpdateReport: ".$self->getZone." is ".$self->getState;
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
