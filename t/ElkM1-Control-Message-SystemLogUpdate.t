use Test::More tests => 11;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::SystemLogUpdate');
};

my $cmd =  'LD1193102119450607001505';
my $messageObj = ElkM1::Control::Message->new(command => $cmd);
my $logDataObj= ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($logDataObj->getEvent, 1193, "event is 1193");
is($logDataObj->getEventNumberData, 102, "eventnumberdata is 1193");
is($logDataObj->getArea, 1, "area is 1");
is($logDataObj->getMonth, 'June', "month is 'June'");
is($logDataObj->getMonthValue, 6, "month value is 6");
is($logDataObj->getDay, 7, "day is 7");
is($logDataObj->getDayOfWeek, 'Thursday', "dayofweek is thursday");
is($logDataObj->getDayOfWeekValue, 5, "dayofweek is thursday");
is($logDataObj->getYear, 5, "year is 5");
