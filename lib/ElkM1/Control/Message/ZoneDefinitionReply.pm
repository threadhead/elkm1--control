package ElkM1::Control::Message::ZoneDefinitionReply;

# MessageType: 'ZD'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

ElkM1::Control::Message::ZoneDefinitionReply;

=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('D6ZD123...00CC');
    my $typeName = $msg->getTypeName(52); 

    if ($typeName eq 'Disabled') { warn 'Zone 52 is disabled'; } 
    
    # -Or-
    
    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $type = $elk->getType(52); 
    print "zone 52 is type $type"

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Zone Definition Reply'  
message from the ElkM1 control. This mesage is used to describe the zone defitions, such as whether or not
a zone is a fire zone, burglar zone, etc.  This would indicate logical states like normal, violated or trouble 
and also physical states like shorted, open, or EOL. The physical to logical mapping would be depending on the 
configured zone type. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

# Type mapping for the value returned into a human readable format. 
my %TYPE = ( '0' => 'Disabled',
			 '1' => 'Burglar Entry/Exit 1',
			 '2' => 'Burglar Entry/Exit 2',
			 '3' => 'Burglar Perimeter Instant',
			 '4' => 'Burglar Interior',
			 '5' => 'Burglar Interior Follower',
			 '6' => 'Burglar Interior Night',
			 '7' => 'Burglar Interior Night Delay',
			 '8' => 'Burglar 24 Hour',
			 '9' => 'Burglar Box Tamper',
			 ':' => 'Fire Alarm',
			 ';' => 'Fire Verified',
			 '<' => 'Fire Supervisory',
			 '=' => 'Aux Alarm 1',
			 '>' => 'Aux Alarm 2',
			 '?' => 'Keyfob',
			 '@' => 'Non Alarm',
			 'A' => 'Carbon Monoxide',
			 'B' => 'Emergency Alarm',
			 'C' => 'Freeze Alarm',
			 'D' => 'Gas Alarm',
			 'E' => 'Heat Alarm',
			 'F' => 'Medical Alarm',
			 'G' => 'Police Alarm',
			 'H' => 'Police No Indication',
			 'I' => 'Water Alarm',
			 'J' => 'Key Momentary Arm / Dis arm',
			 'K' => 'Key Momentary Arm Away',
			 'L' => 'Key Momentary Arm Stay',
			 'M' => 'Key Momentary Disarm',
			 'N' => 'Key On/Off',
			 'O' => 'Mute Audibles',
			 'P' => 'Power Supervisory',
			 'Q' => 'Temperature',
			 'R' => 'Analog Zone',
			 'S' => 'Phone Key',
			 'T' => 'Intercom Key');

=head1 METHODS

=over 4

=cut

=item $msg->getType($zone)

Obtain the numeric value for the type of zone specified by $zone. This is the character representing
the zone in the message and not the zone type as defined in ElkRP. For example, zone type 'T' is 
'Intercom Key' but ElkRP lists it was zone type 36. For the type of zone listed in ElkRP see the
C<$msg-E<gt>getElkRPType> method. 

=cut

sub getType { 
	my $self = shift;
	my $zone = shift;

	return substr($self->command,2 + $zone - 1,1);
}

=item $msg->getElkRPType($zone)

Obtain the zone type number as defined in ElkRP. This would be type 10 for Fire Alarm, type 11 for Fire Verified, etc. 
C<$msg-E<gt>getElkRPType> method. 

=cut

sub getElkRPType { 
    my $self = shift;
    my $zone = shift;

    return ord($self->getType($zone)) - 48;
}

=item $msg->getTypeName($zone)

Obtain the name of the zone type.

=cut

sub getTypeName { 
	my $self = shift;
	my $zone = shift;
	my $val = $self->getTypeValue($zone);

	exists $TYPE{$val} ? $TYPE{$val} : "unknown $val";
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString { 
	my $self = shift;
	my $str = "ZoneDefinitionReply ";
	for (my $i=1;$i<=208;$i++) { 
		$str .= "getType($i)=".$self->getType." (".$self->getTypeValue.")";
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
