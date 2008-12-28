package ElkM1::Control::Message::ArmingStatusReport;

# MessageType: 'AS'

use base ElkM1::Control::Message;
use strict;

our $VERSION = '1.0';

=head1 NAME

    ElkM1::Control::Message::ArmingStatusReport

=cut

=head1 SYNOPSIS

    my $msg = ElkM1::Control:MessageFactory('1EAS100000004000000030000000000E');
    my $armedStatus = $msg->getArmedStatusName; 

    # -Or-
   
    my $elk = ElkM1::Control->new(host => '192.168.1.115');
    my $msg = $elk->requestArmingStatusReport; 
    print "alarm is ".$msg->getArmedStatusName;

=cut

=head1 DESCRIPTION 

    This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Arming Status Report Data' 
    message from the ElkM1 control. This mesage is used to describe the current armed status, armup status and alarm 
    status. This would indicate things like whether or not the alarm is sounding, is ready to arm or is armed. 

    This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
    instantiate this object directly.

=cut

# hash which maps the ARMED_STATUS types to human readable names. 

our %ARMED_STATUS = (
    0 => 'disarmed',
    1 => 'armed away',
    2 => 'armed stay',
    3 => 'armed stay instant',
    4 => 'armed night',
    5 => 'armed night instant',
    6 => 'armed vacation'
);

=item %ARMUP_STATUS

    hash which maps the ARMUP_STATUS types to human readable formats. 

=cut

our %ARMUP_STATUS = (
    0 => 'not ready to arm',
    1 => 'ready to arm',
    2 => 'ready to force arm',
    3 => 'with exit timer',
    4 => 'fully',
    5 => 'forced',
    6 => 'with bypass'
);

=item %ALARM_STATUS

    hash which maps the ARMUP_STATUS types to human readable formats. 

=cut

our %ALARM_STATUS = (
    '0' => 'no alarm active',
    '1' => 'entry delay active',
    '2' => 'alarm abort delay active',
    '3' => 'fire alarm active',
    '4' => 'medical alarm active',
    '5' => 'police alarm active',
    '6' => 'burglar alarm active',
    '7' => 'aux1 alarm active',
    '8' => 'aux2 alarm active',
    '9' => 'aux3 alarm active',
    ':' => 'aux4 alarm active',
    ';' => 'carbon monoxide alarm active',
    '<' => 'emergency alarm active',
    '=' => 'freeze alarm active',
    '>' => 'gas alarm active',
    '?' => 'heat alarm active',
    '@' => 'water alarm active',
    'A' => 'fire supervisory alarm active',
    'B' => 'verify fire alarm active'
);

=head1 Methods

=cut

sub _getArmedArray {
    my $self = shift;
    return substr( $self->command, 2, 8 );
}

sub _getArmUpArray {
    my $self = shift;
    return substr( $self->command, 10, 8 );
}

sub _getAlarmArray {
    my $self = shift;
    return substr( $self->command, 18, 8 );
}

=item getArmedStatusName($area) 

    Obtain the current armed status, such as 'armed away' or 'disarmed' for the specified area. 

=cut

sub getArmedStatusName {
    my $self = shift;
    my $area = shift;

    my $val = $self->getArmedStatus($area);

    return
      exists( $ARMED_STATUS{$val} ) ? ( $ARMED_STATUS{$val} ) : "unknown($val)";
}

=item getArmUpStatusName($area) 

    Obtain the current Arm up status, such as 'ready to arm' or 'not ready to arm'.

=cut

sub getArmUpStatusName {
    my $self = shift;
    my $area = shift;
    my $val  = $self->getArmUpStatus($area);

    return (
        exists( $ARMUP_STATUS{$val} )
        ? ( $ARMUP_STATUS{$val} )
        : "unknown($val)"
    );
}

=item getAlarmStatusName($area) 

    Obtain the current alarm status, such as 'no alarm active' or 'fire alarm'. This 
    can also indicate the state of entry/exit delay. 

=cut

sub getAlarmStatusName {
    my $self = shift;
    my $area = shift;

    my $val = $self->getAlarmStatus($area);

    return (
        exists( $ALARM_STATUS{$val} )
        ? ( $ALARM_STATUS{$val} )
        : "unknown($val)"
    );
}

=item getAlarmStatus($area) 

    Obtain the value of the current alarm status. 
    See the Elk documentation for details. 

=cut

sub getAlarmStatus {
    my $self = shift;
    my $area = shift;

    return substr( $self->_getAlarmArray, $area - 1, 1 );
}

=item getArmedStatus($area) 

    Obtain the value of the current armed status for the specified area. 
    See the Elk documentation for details. 

=cut

sub getArmedStatus {
    my $self = shift;
    my $area = shift;

    return substr( $self->_getArmedArray, $area - 1, 1 );
}

=item getArmUpStatus($area) 

    Obtain the value of the current armUp status for the specified area. 
    See the Elk documentation for valid values. 

=cut

sub getArmUpStatus {
    my $self = shift;
    my $area = shift;

    return substr( $self->_getArmUpArray, $area - 1, 1 );
}

=item getStatus($area)

    Obtain a human readable listing of the all status information
    for the specified area. 

=cut

sub getStatus {
    my $self = shift;
    my $area = shift;
    my $str  =
        $self->getArmedStatusName($area) . ' '
      . $self->getArmUpStatusName($area) . ' '
      . $self->getAlarmStatusName($area);
}

=item toString()

    returns a human readable string containing all information for status of all areas. 

=cut

sub toString {
    my $self = shift;
    my $str  = "ArmingStatusReport:\n";

    for ( my $i = 1 ; $i <= 8 ; $i++ ) {
        $str .= "     Area $i : " . $self->getStatus($i) . "\n";
    }

    return $str;
}

1;

__END__

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

ElkM1::Control, ElkM1::Control::Message, ElkM1::Control::MessageFactory

=cut

=head1 AUTHOR

James Russo <jr@halo3.net>

=cut
