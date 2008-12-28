use Test::More tests => 5;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::TaskChangeUpdate');

};


my $cmd =  'TC0010';
my $messageObj = ElkM1::Control::Message->new(command => $cmd);
my $taskChangeUpdateObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($taskChangeUpdateObj->getTask, 1, "task is 1");

$cmd =  'TC2080';
$messageObj = ElkM1::Control::Message->new(command => $cmd);
$taskChangeUpdateObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($taskChangeUpdateObj->getTask, 208, "task is 208");

$cmd =  'TC1270';
$messageObj = ElkM1::Control::Message->new(command => $cmd);
$taskChangeUpdateObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($taskChangeUpdateObj->getTask, 127, "task is 127");
