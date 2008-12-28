use Test::More tests => 42;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::ZonePartitionReply');
};

my $i = 0; 
my @zones;
push (@zones,int(rand(207)+1))
    while ($i++<5);

# Test LogicalStatus

foreach my $zone (@zones) { 
    my $cmd = 'ZP'.(0)x208;
    foreach my $partition (1..8) { 
            substr ($cmd, 2 + $zone - 1,1) = $partition;

            my $messageObj = ElkM1::Control::Message->new(command => $cmd);
            my $zonePartitionReplyObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

            is($zonePartitionReplyObj->getPartition($zone), $partition,"partition for zone $zone is correct");
    }
}
