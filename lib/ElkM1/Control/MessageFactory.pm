package ElkM1::Control::MessageFactory;

=head1 NAME
    ElkM1::Control::MessageFactory - Factory used to create message objects.
=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('1EAS100000004000000030000000000E');
    print ref($msg); # Will be ElkM1::Control::Message::ArmingStatusReport.

=cut

use strict;
use warnings;

# Our listing of message types to objects. 

our %DISPATCH_MAP = (
		'AS' => 'ElkM1::Control::Message::ArmingStatusReport',
		'CS' => 'ElkM1::Control::Message::OutputStatusReply',
		'ZS' => 'ElkM1::Control::Message::ZoneStatusReply',
		'ZP' => 'ElkM1::Control::Message::ZonePartitionReply',
		'ZB' => 'ElkM1::Control::Message::BypassedZoneStateReply',
		'ZC' => 'ElkM1::Control::Message::ZoneChangeUpdateReport',
		'LD' => 'ElkM1::Control::Message::SystemLogUpdate',
		'CC' => 'ElkM1::Control::Message::OutputChangeUpdate',
		'TC' => 'ElkM1::Control::Message::TaskChangeUpdate',
		'SD' => 'ElkM1::Control::Message::StringTextDescriptionReply',
		'ST' => 'ElkM1::Control::Message::TemperatureReply',
	#	'CR' => 'ElkM1::Control::Message::CustomValueReply',
		'KC' => 'ElkM1::Control::Message::KeypadKeyChangeUpdate',
		'TR' => 'ElkM1::Control::Message::ThermostatDataReply',
		'PC' => 'ElkM1::Control::Message::PLCChangeUpdate',
		'ZV' => 'ElkM1::Control::Message::ZoneAnalogVoltageReply',
		'XK' => 'ElkM1::Control::Message::EthernetModuleTest',
		'PS' => 'ElkM1::Control::Message::PLCStatusReply',
		'UA' => 'ElkM1::Control::Message::ValidUserCodeAreasReply'
);

=head1 METHODS

=cut


=item ElkM1::Control::MessageFactory->instantiate($message)

    This will take the message provided and attempt to return
    a subclass from L<ElkM1::Control::Message> for the specific
    type of message. If a message type is not known, a 
    L<ElkM1::Control::Message> object is returned. 

=cut

sub instantiate { 
	my $class = shift;
	my $message = shift;

	my $type = substr($message,2,2);
	my $module = $DISPATCH_MAP{$type} || 'ElkM1::Control::Message';
	my $module_file = $module;
	$module_file =~ (s/::/\//g);	
	$module_file .= '.pm'; 

	require $module_file
		unless $INC{$module_file};

	return $module->new(message => $message);
}

1;

__END__

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

ElkM1::Control, ElkM1::Control::Message

=cut

=head1 AUTHOR

James Russo <jr@halo3.net>

=cut
