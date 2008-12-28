package ElkM1::Control::Message::ZoneStatusReply;

# MessageType: 'ZS'

use base ElkM1::Control::Message;
use strict;
use warnings;

our $VERSION = '1.0';

=head1 NAME

ElkM1::Control::Message::ZoneStatusReply;

=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('D6ZSD...000CC');
    my $status = $msg->getLogicalStatusName(52); 
    
    # -Or-
    
    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $msg = $elk->requestZoneStatus; 
    print "zone 1 is physically ".$msg->getPhysicalStatusName(1);

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Zone Status Report Data' 
message from the ElkM1 control. This mesage is used to describe the current physical and logical zone status.
This would indicate logical states like normal, violated or trouble and also physical states like shorted, 
open, or EOL. The physical to logical mapping would be depending on the configured zone type. 

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

# hash providing physical status values to human readable names. Use by getPhysicalStatusName

our %PHYSICAL_STATUS =
  ( 0 => 'normal', 1 => 'trouble', 2 => 'violated', 3 => 'bypassed' );

# hash providing logical status values to human readable names. Use by getPhysicalStatusName

our %LOGICAL_STATUS =
  ( 0 => 'unconfigured', 1 => 'open', 2 => 'EOL', 3 => 'short' );

=head1 METHODS

=over 4

=cut

# _getZone
#
# Obtain the character for the specified zone.

sub _getZone {
    my $self = shift;
    my $zone = shift;

    return substr( $self->command, $zone + 2 - 1, 1 );
}

=item $msg->getPhysicalStatus($zone)

Obtain the physical status for the specific zone (ie. normal, trouble, violated).
This returns the numeric value see L<getPhysicalStatusName()> for a human readable
name.

=cut

sub getPhysicalStatus {
    my $self      = shift;
    my $zone      = shift;
    my $zoneValue = hex( $self->_getZone($zone) );

    $zoneValue >> 2;
}

=item getLogicalStatus($zone)

Obtain the logical status for the specified zone (ie. unconfigured, Open, EOL).
This returns the numeric value. see L<getLogicalStatusName> for a human readable
name. 

=cut

sub getLogicalStatus {
    my $self      = shift;
    my $zone      = shift;
    my $zoneValue = hex( $self->_getZone($zone) );

    ($zoneValue & 0x03);
}

=item getPhysicalStatusName($zone)

Obtain the physical status name for the specified zone. Returns one of the following 
strings.  'unconfigured', 'open', 'EOL', 'short'. To get a numeric value for these 
see L<getLocalStatus>

=cut

sub getPhysicalStatusName {
    my $self   = shift;
    my $zone   = shift;
    my $status = $self->getPhysicalStatus($zone);

    exists $PHYSICAL_STATUS{$status}
      ? $PHYSICAL_STATUS{$status}
      : "unknown ($status)";
}

=item getLogicalStatusName($zone)

Obtain the logical status name for the specified zone.  Returns one of the following: 
'normal', 'trouble', 'violated', 'bypassed'.  To get a numeric value for these see 
L<getLocalStatus>

=cut

sub getLogicalStatusName {
    my $self   = shift;
    my $zone   = shift;
    my $status = $self->getLogicalStatus($zone);

    exists $LOGICAL_STATUS{$status}
      ? $LOGICAL_STATUS{$status}
      : "unknown ($status)";
}

=item toString

Return a string which represents the status of this message in a human readable format.

=cut

sub toString {
    my $self = shift;
    my $str;

    for ( my $i = 1 ; $i <= 208 ; $i++ ) {
        my $physicalStatusName = $self->getPhysicalStatusName($i);
        my $logicalStatusName  = $self->getPhysicalStatusName($i);
        $str .= "ZoneStatusReply: zone=$i, physical=$physicalStatusName, logical=$logicalStatusName\n";
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
