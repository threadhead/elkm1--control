use Test::More tests => 530;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::ArmingStatusReport');
};
# Test Armed Status

foreach my $area (1..8) { 
    my $cmd = 'AS00000000000000000000000000';
    foreach my $status (sort keys %ElkM1::Control::Message::ArmingStatusReport::ARMED_STATUS) { 
        my $statusName = $ElkM1::Control::Message::ArmingStatusReport::ARMED_STATUS{$status};
        substr ($cmd, 2 + $area - 1,1) = $status;
        my $messageObj = ElkM1::Control::Message->new(command => $cmd);
        my $armStatusObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);
        is($armStatusObj->getArmedStatus($area),$status,"getArmedStatus for area $area is $status.");
        is($armStatusObj->getArmedStatusName($area),$statusName,
            "getArmedStatusName for area $area is '$statusName'.");
    }
}

foreach my $area (1..8) { 
    my $cmd = 'AS00000000000000000000000000';
    foreach my $status (sort keys %ElkM1::Control::Message::ArmingStatusReport::ARMUP_STATUS) { 
        my $statusName = $ElkM1::Control::Message::ArmingStatusReport::ARMUP_STATUS{$status};
        substr ($cmd, 10 + $area - 1,1) = $status;
        my $messageObj = ElkM1::Control::Message->new(command => $cmd);
        my $armStatusObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);
        is($armStatusObj->getArmUpStatus($area),$status,"getArmUpStatus for area $area is $status.");
        is($armStatusObj->getArmUpStatusName($area),$statusName,
            "getArmUpStatus for area $area is '$statusName'.");
    }
}

foreach my $area (1..8) { 
    my $cmd = 'AS00000000000000000000000000';
    foreach my $status (sort keys %ElkM1::Control::Message::ArmingStatusReport::ALARM_STATUS) { 
        my $statusName = $ElkM1::Control::Message::ArmingStatusReport::ALARM_STATUS{$status};
        substr ($cmd, 18 + $area - 1,1) = $status;
        my $messageObj = ElkM1::Control::Message->new(command => $cmd);
        my $armStatusObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);
        is($armStatusObj->getAlarmStatus($area),$status,"getAlarmState for area $area is $status.");
        is($armStatusObj->getAlarmStatusName($area),$statusName,
            "getAlarmState for area $area is '$statusName'.");
    }
}
