package ElkM1::Control::Message::ZonePartitionReply; 

# MessageType: 'ZP'

use base ElkM1::Control::Message;
use strict;
use warnings;

=head1 NAME

ElkM1::Control::Message::ZonePartitionReply;

=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('D6ZPD..00CC');
    # look at the partition (area) for zone 53.
    my $area = $msg->getPartition(53); 
    
    # -or-
    
    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $msg = $elk->requestZoneStatus; 
    print "area for zone 1 is".$msg->getPartition(1);

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Zone Partition Report Data' 
message from the ElkM1 control. This mesage is used to describe the which zones belong to which parition (area).

This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
instantiate this object directly.

=cut

=item $msg->getPartition($zone)

Obtain the partition (area) which the specifed zone belongs to. This returns a
value from 1..8. 

=cut

sub getPartition { 
	my $self = shift;
	my $zone = shift;

	return substr($self->command,$zone + 2 - 1, 1);
}

=item $msg->toString()

Return a string which represents the status of this message in a human readable format.

=cut

sub toString { 
	my $self = shift;
	my $str = "ZonePartitionReply:"; 

	for (my $i=1;$i<=208;$i++) { 
		my $partition = $self->getPartition($i);
		$str .= "zone=$i, partition=$partition\n";
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
