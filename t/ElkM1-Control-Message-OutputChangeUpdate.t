use Test::More tests => 10;
use strict;

BEGIN { 
    use_ok('ElkM1::Control::MessageFactory');
    use_ok('ElkM1::Control::Message::OutputChangeUpdate');
};


my $cmd =  'CC0031';
my $messageObj = ElkM1::Control::Message->new(command => $cmd);
my $outputChangeUpdateObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($outputChangeUpdateObj->getOutput, 3, "output is 3");
is($outputChangeUpdateObj->getState, 1, "output is on");

$cmd =  'CC0030';
$messageObj = ElkM1::Control::Message->new(command => $cmd);
$outputChangeUpdateObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($outputChangeUpdateObj->getOutput, 3, "output is 3");
is($outputChangeUpdateObj->getState, 0, "output is off");


$cmd =  'CC2081';
$messageObj = ElkM1::Control::Message->new(command => $cmd);
$outputChangeUpdateObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($outputChangeUpdateObj->getOutput, 208, "output is 208");
is($outputChangeUpdateObj->getState, 1, "output is on");

$cmd =  'CC2080';
$messageObj = ElkM1::Control::Message->new(command => $cmd);
$outputChangeUpdateObj = ElkM1::Control::MessageFactory->instantiate($messageObj->message);

is($outputChangeUpdateObj->getOutput, 208, "output is 208");
is($outputChangeUpdateObj->getState, 0, "output is off");
