use Test::More tests => 322;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::ZoneStatusReply');
};

my $i = 0; 
my @zones;
push (@zones,int(rand(207)+1))
    while ($i++<5);

# Test LogicalStatus

foreach my $zone (@zones) { 
    my $cmd = 'ZS'.(0)x208;
    foreach my $logicalStatus (sort keys %ElkM1::Control::Message::ZoneStatusReply::LOGICAL_STATUS) { 
        foreach my $physicalStatus (sort keys %ElkM1::Control::Message::ZoneStatusReply::PHYSICAL_STATUS) { 
            my $logicalStatusName = $ElkM1::Control::Message::ZoneStatusReply::LOGICAL_STATUS{$logicalStatus};
            my $physicalStatusName = $ElkM1::Control::Message::ZoneStatusReply::PHYSICAL_STATUS{$physicalStatus};

            substr ($cmd, 2 + $zone - 1,1) = sprintf("%X",($logicalStatus | $physicalStatus << 2));

            my $messageObj = ElkM1::Control::Message->new(command => $cmd);
            my $zoneStatusObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

            is($zoneStatusObj->getLogicalStatus($zone) & 0x03,$logicalStatus,"getLogicalStatus for zone $zone is $logicalStatus.");
            is($zoneStatusObj->getLogicalStatusName($zone),$logicalStatusName,
                "getLogicalStatusName for zone $zone is '$logicalStatusName'.");

            is($zoneStatusObj->getPhysicalStatus($zone),$physicalStatus,"getPhysicalStatus for zone $zone is $physicalStatus.");
            is($zoneStatusObj->getPhysicalStatusName($zone),$physicalStatusName, "getPhysicalStatusName for zone $zone is '$physicalStatusName'.");
        }
    }
}
