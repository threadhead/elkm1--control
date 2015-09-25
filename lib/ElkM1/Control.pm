package ElkM1::Control;

use 5.008006;
use strict;
use warnings;
use Carp;
use IO::Socket::INET;
use IO::Socket::SSL;
use Data::Dumper;
use ElkM1::Control::Message;
use ElkM1::Control::MessageFactory;
use POSIX qw(ceil floor);

=head1 NAME

ElkM1::Control - Package providing API interface to the Elk Products M1 Cross Platform Control Alarm/Home Automation system.

=cut

=head1 SYNOPSIS

    use ElkM1::Control;

    my $elk = ElkM1::Control->new('host' => '192.168.1.115', 'port' => 2101, use_ssl => 0
                                  username => 'user', password => 'password');

    # Main loop, read any message. 
    while (1) {  
        while (my $msg = $elk->readMessage) {
            if (ref($msg) eq 'ElkM1::Control::ZoneChangeUpdate') { 
                print "zone " . $msg->getZone . " is now " . $msg->getState . "\n";
                
                # If zone 1 is violated, activate task 1
                # and do something else. 
                if ($msg->getZone == 1 and $msg->isViolated) { 
                    $elk->activateTask(task => 1);
                    # ... something else ...  
                }
            } else { 
                print $msg->toString . "\n";
            }
        }
    }

=cut

=head1 DESCRIPTION 
    
ElkM1::Control is a set of modules which provide an API for communication and control with the 
ElkM1 security and home automation system. This package contains no user-runnable code, but rather
is an API with which you can build applications that can communicate with the Elk. With this package
you can command the panel to do anything you could do at the keypad. You can also recieve messages 
when certain events occur on the panel such as a zone being violated, a task activating, etc. 

This package requires the use of the Elk ethernet module and can communication on either the secure
port or the insecure port. 

The core module is L<ElkM1::Control>. This module contains methods to interact with the ElkM1. Some
methods return a subclass of L<ElkM1::Message> and others do not. The methods which don't return a
message typically cause the Elk to send out a message due to the change. An example of this is the
PLC commands which don't return anything but the Elk will fire a L<PLCChangeUpdate> message when
any PLC device changes state. 

Typically a module which ends in Reply will be in response to a request. A message which can be
sent by the ElkM1 without a request typically end in Update or Report. However, this is not always 
the case. 

You would normally have a core loop reading messages from the Elk, and then firing other commands when
needed. The reading of responses to requests is intelligent enough to leave unexpected messages in queue 
for the main loop to recieve. This means you won't loose messages when you request information.

The design of the system uses individual classes to represent messages from the Elk. This allows easy
for ease-of-use by providing methods to obtain all the fields from the messages. These subclasses
are created with the L<ElkM1::Control::MessageFactory> class. 

=cut

my $AREA_PARAM = {
    allow => sub { ( $_[0] <= 8 and $_[0] >= 1 ) },
    default     => 1,
    description => 'an area 1..8'
};
my $CODE_PARAM = {
    allow       => qr/^(\d{4}|\d{6})$/,
    description => 'a user 4 or 6 digit user code'
};
my $ZONE_PARAM = {
    allow => sub { ( $_[0] <= 208 and $_[0] >= 1 ) },
    required    => 1,
    description => 'an zone 1..208'
};
my $KEYPAD_PARAM = {
    allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
    description => 'an keypad from 1..16'
};
my $OUTPUT_PARAM = {
    allow => sub { ( $_[0] >= 1 and $_[0] <= 208 ) },
    description => 'an output from 1..208'
};
my $TIMEOUT_PARAM =
  { allow => sub { ( $_[0] >= 0 and $_[0] <= 65535 ) }, default => 0 };
my $HOUSE_PARAM = {
    allow => sub { ( ord( $_[0] ) >= 65 and ord( $_[0] ) <= 77 ) },
    description => 'an valid house code A..P'
};
my $UNIT_PARAM = {
    allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
    description => 'an unit code from 1..16'
};

our $VERSION = '0.1.1';

=head1 METHODS

=over 4

=cut

sub _checkParam {
    my $self = shift;
    my $spec = shift;
    my $args = shift;
    my $sub  = ( caller(1) )[3];

    # Check for any missing required parameters.
    foreach my $argName ( keys %{$spec} ) {
        my $specDetails =
          exists $spec->{$argName}->{rules}
          ? $spec->{$argName}->{rules}
          : $spec->{$argName};

        # Check for required arguments.
        croak "$sub - required argument '$argName' not found."
          if ( $specDetails->{required} and !exists( $args->{$argName} ) );

        # Setup defaults.
        $args->{$argName} = $specDetails->{default}
          if ( exists $specDetails->{default}
            and !exists( $args->{$argName} ) );

        next unless exists $args->{$argName};

        # Check validity
        croak "$sub: argument '$argName' ($$args{$argName}) is invalid."
          . "$$specDetails{description}"
          if ( ref( $specDetails->{allow} ) eq 'CODE'
            and !$specDetails->{allow}->( $args->{$argName} ) )
          or ( ref( $specDetails->{allow} ) eq 'Regexp'
            and $args->{$argName} !~ $specDetails->{allow} );

        ${ $spec->{$argName}->{var} } = $args->{$argName}
          if ( $spec->{$argName}->{var} );
    }

    # Check all parameters for extras and invalid ones.
    foreach my $argName ( keys %{$args} ) {
        my $specDetails = $spec->{$argName};
        croak "$sub: argument '$argName' not allowed here."
          unless $specDetails;
    }

    return $args;
}

=item $elk->new( host => 'host', port => port, use_ssl => 1, username => 'username', password => 'password' , debug => 0)

Construct a ElkM1::Control object with the given parameters. This method
accepts the following paramters. host, the host to which to connect to.
This can be either a hostname or ip address. The port to connect to and
if not specified will be either 2101 or 2601 depending on the use_ssl flag. 
The use_ssl flag determines whether or not to connect using SSL. Use
this if you connect to the secure port.  Username and Password if enabled in XEP
The debug flag indicates whether all messages will be printed to stdout. 

returns a blessed reference on success, croaks on failure.

=cut

sub new {
    my $class = shift;
    my %args  = @_;

    my $obj = $class->_checkParam(
        {
            host => {
                required    => 1,
                description => 'must be a hostname or IP address'
            },
            port => {
                allow       => qr/^\d+$/,
                description => 'port to connect to'
            },
            use_ssl => {
                allow       => qr/^(1|0)/,
                default     => 0,
                description => 'must be 1 or 0'
            },
            username => {
                default     => '',
                description => 'username if enabled in XEP'
            },
            password => {
                default     => '',
                description => 'password if enabled in XEP'
            },
            debug => {
                allow       => qr/^(\d)$/,
                default     => 0,
                description => 'must be a 0 or 9'
            }
        },
        \%args
    );

    $obj->{port} = ( $obj->{use_ssl} ? 2601 : 2101 )
      unless ( exists $obj->{port} );

    $obj->{_queue} = [];

    my $self = bless $obj, $class;

    $self->connect;

    return $self;
}

=item $elk->connect()

Establish a connection to the panel. This is done automatically
upon instantation of the object. You would typically call this
method if you called the C<$elk->disconnect> method previously.

returns 1 on success, croaks on failure. 

=cut

sub connect {
    my $self = shift;
    my $sock;

    if ( $self->{use_ssl} ) {
        warn "creating SSL socket to $$self{host}:$$self{port}"
          if ( $self->{debug} );
        $sock = new IO::Socket::SSL(
            PeerAddr => $self->{host},
            PeerPort => $self->{port},
            Proto    => 'tcp',
            SSL_version => 'SSLv3'
        );
    }
    else {
        $sock = new IO::Socket::INET(
            PeerAddr => $self->{host},
            PeerPort => $self->{port},
            Proto    => 'tcp'
        );

    }

    croak "unable to connect $!"
      unless ( defined $sock );

    $self->{_socket} = $sock;

    if ( $self->{use_ssl} and $self->{username} ) {
        my $msg; 

        # give XEP time to initiate authentication - if not our readLine will timeout with nothing
        sleep (2) ; 
          
        croak "No response from XEP waiting for: 'lf'"
          unless ( $self->_readLine =~ /\n/);
 
        # send username before prompt because readLine is waiting for lf and XEP is prompting for Username
        print $sock "$self->{username}\r\n";

        croak "No response from XEP waiting for: Username:"
          unless ( $self->_readLine =~ /Username:/);

        # send password before prompt because readLine is waiting for lf and XEP is prompting for Password
        print $sock "$self->{password}\r\n";

        croak "No response from XEP waiting for: Password:"
          unless ( $self->_readLine =~ /Password:/);

        croak "Authentication failed"
          unless ( $self->_readLine =~ /Elk-M1XEP: Login successful./);
        # XEP responds with "*read:errno=0" if authentication fails
        
    } #end if Authentication 

    return 1;
}

=item $elk->disconnect()

Disconnect from the panel. 

=cut

sub disconnect {
    my $self = shift;

    return unless defined( $self->{sock} );

    $self->{_socket}->shutdown(2);
    $self->{_socket}->close;
    undef $self->{_socket};
}

=item $elk->disarm( code => 1234 [, area => 1] )

Request that the alarm be disarmed. Takes a hash
with a code element and optionally a area argument.
The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub disarm {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a0' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armAway( code => 1234 [, area => 1] )

Request that the alarm be armed to the away mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armAway {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a1' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armStay( code => 1234 [, area => 1] )

Request that the alarm be armed to the stay mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armStay {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a2' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armStayInstant( code => 1234 [, area => 1] )

Request that the alarm be armed to the stay instant mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armStayInstant {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a3' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armNight( code => 1234 [, area => 1] )

Request that the alarm be armed to the stay instant mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armNight {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a4' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armNightInstant( code => 1234 [, area => 1] )

Request that the alarm be armed to the night instant mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armNightInstant {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a5' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armVacation( code => 1234 [, area => 1] )

Request that the alarm be armed to the vacation mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armVacation {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a6' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armStepNextAwayMode( code => 1234 [, area => 1] )

Request that the alarm step to the next away mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armStepNextAwayMode {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a7' . $area . sprintf( '%06d', $code ) );
}

=item $elk->armStepNextStayMode( code => 1234 [, area => 1] )

Request that the alarm step to the next stay mode. 
Takes a hash with a code element and optionally a 
area argument.  The area defaults to 1 if not provided. 

#TODO Figure out return types. 

=cut

sub armStepNextStayMode {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( 'a8' . $area . sprintf( '%06d', $code ) );
}

=item $elk->requestArmingStatus()

Request the arming status. Will return a 
L<ElkM1::Control::Message::ArmingStatusReport> object with 
arming status for the panel or undef on error.

=cut

sub requestArmingStatus {
    my $self = shift;

    $self->sendCommand('as');
    return $self->readMessage('AS');
}

=item $elk->requestZoneStatus()

Request zone status. Will return a 
L<ElkM1::Control::Message::ZoneStatusReply> object with 
information on all zones.

=cut

sub requestZoneStatus {
    my $self = shift;

    $self->sendCommand('zs');
    return $self->readMessage('ZS');
}

=item $elk->requestZonePartitions()

Request zone partition. Will return a 
L<ElkM1::Control::Message::ZonePartitionReply> object with 
information on which zones belong to which partitions (areas).

=cut

sub requestZonePartitions {
    my $self = shift;

    $self->sendCommand('zp');
    return $self->readMessage('ZP');
}

=item $elk->requestBypassZone( zone => 1, code => 1234 )

Request that the specified zone be bypassed by using the
provided code. If the zone is already bypassed, it will 
be unbypassed. Takes a hash with a zone element and a code 
element. A C<ElkM1::Control::Message::BypassedZoneReport> 
object will be returned.

=cut

sub requestBypassZone {
    my $self = shift;
    my %args = @_;
    my $zone;
    my $code;

    $self->_checkParam(
        {
            zone => { rules => $ZONE_PARAM, var => \$zone },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'zb%03d0%06d', $zone, $code ) );
    return $self->readMessage('ZB');
}

=item $elk->requestBypassAllViolated( area => 1, code => 1234 )

Request that all violated zones in the specified area be bypassed
using the provided code.  Takes a hash with a zone element and a code 
element. Nothing is returned but multiple 
C<ElkM1::Control::Message::BypassedZoneReport> objects may be returned
if zones were bypassed as a result of this command.

#TODO confirm that this is how it works with the multiple ZB commands
#TODO on success maybe we should just return an array?

=cut

sub requestBypassAllViolated {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'zb999%d%06d', $area, $code ) );
}

=item $elk->requestUnbypassAll( area => 1, code => 1234 )

Request that all violated zones in the specified area be unbypassed
using the provided code.  Takes a hash with a zone element and a code 
element. Nothing is returned but multiple 
C<ElkM1::Control::Message::BypassedZoneReport> objects may be returned
if zones were unbypassed as a result of this command.

#TODO confirm that this is how it works with the multiple ZB commands
#TODO on success maybe we should just return an array?

=cut

sub requestUnbypassAll {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam(
        {
            area => { rules => $AREA_PARAM, var => \$area },
            code => { rules => $CODE_PARAM, var => \$code },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'zb000%d%06d', $area, $code ) );
    return $self->readMessage('ZB');
}

=item $elk->speakWord( word => 'alarm')

Request that the ElkM1 speak the word provided. The word can be 
any of the supported words in the ElkM1 vocabulary or a number
from the ElkM1 documentation. Some words are actually phrases
and if thats the case the spaces are replaced with underscore _
to make them into one word. See C<ElkM1::Control::Words> for
the table used to lookup the values. 

=cut

sub speakWord {
    my $self = shift;
    my %args = @_;

    my $word = lc( $args{word} );

    $word = $ElkM1::Control::Words::ELK_M1_WORDS{$word}
      if ( exists $ElkM1::Control::Words::ELK_M1_WORDS{$word} );

    warn "unknown word value: $word"
      if ( $word < 1 or $word > 473 );

    $self->sendCommand( 'sw' . sprintf( "%03d", $word ) );
}

=item $elk->speakPhase( phrase => 0)

Request that the ElkM1 speak a phrase. The value for
the phrase comes from the ElkM1 documentation. There are 319
available phrases. 

=cut

sub speakPhrase {
    my $self = shift;
    my %args = @_;
    my $phrase;

    $self->_checkParam(
        {
            phrase => {
                allow => sub { ( $_[0] <= 319 and $_[0] >= 0 ) },
                var         => \$phrase,
                description => 'a word from 1..473'
            },
        },
        \%args
    );

    $self->sendCommand( 'sp' . sprintf( "%03d", $phrase ) );
}

=item $elk->controlOutputOn( output => 1, timeout => 10)

Turns on the specified output on for the time specified
in timeout. The output argument is required. The timeout
argument is optional and defaults to 0 which indicates
that the output should stay on until turned off manually.
Returns nothing, but will generate an OutputChangeUpdate
message when the output changes. 

=cut

sub controlOutputOn {
    my $self = shift;
    my %args = @_;

    my $output;
    my $timeout;

    $self->_checkParam(
        {
            output  => { rules => $OUTPUT_PARAM,  var => \$output },
            timeout => { rules => $TIMEOUT_PARAM, var => \$timeout }
        },
        \%args
    );

    $self->sendCommand( sprintf( "cn%03d%05d", $output, $timeout ) );
}

=item $elk->controlOutputOff( output => 1 )

Turns off the specified output. The output
argument is required. Returns nothing, but 
will generate an OutputChangeUpdate message 
when the output changes. 

=cut

sub controlOutputOff {
    my $self = shift;
    my %args = @_;
    my $output;

    $self->_checkParam(
        { output => { rules => $OUTPUT_PARAM, var => \$output }, }, \%args );

    $self->sendCommand( sprintf( "cf%03d", $output ) );
}

=item $elk->controlOutputToggle( output => 1 )

Toggles the specified output. The output argument
is required. Returns nothing, but will generate an 
OutputChangeUpdate message when the output changes. 

=cut

sub controlOutputToggle {
    my $self = shift;
    my %args = @_;
    my $output;

    $self->_checkParam(
        { output => { rules => $OUTPUT_PARAM, var => \$output }, }, \%args );

    $self->sendCommand( sprintf( "ct%03d", $output ) );
}

=item $elk->requestControlOutputStatus()

Request status of outputs. Will return a 
L<ElkM1::Control::Message::ControlOutputStatusReply> 
message containing the status of all outputs. 

=cut

sub requestControlOutputStatus {
    my $self = shift;

    $self->sendCommand('cs');
    return $self->readMessage('CS');
}

=item $elk->activateTask( task => 4 )

Activate the specified task. The task argument
is the task number is required. Returns nothing
but will generate a 
L<ElkM1::Control::Message::TaskChangeUpdate>
message.

=cut

sub activateTask {
    my $self = shift;
    my %args = @_;
    my $task;

    $self->_checkParam(
        {
            task => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 32 ) },
                var         => \$task,
                description => 'an task from 1..208'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( "tn%03d", $task ) );
}

=item $elk->requestSystemLogData( index => 212 ); 

Request that the log entry specified by index. This
is a way to download the event log from the ElkM1. 
Returns a L<ElkM1::Control::Message::SystemLogUpdate>
message on success, undef on failure. 

=cut

sub requestSystemLogData {
    my $self = shift;
    my %args = @_;
    my $index;

    $self->_checkParam(
        {
            'index' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 511 ) },
                var         => \$index,
                description => 'an log index from 1..511'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'ld%03d', $index ) );
    return $self->readMessage('LD');
}

=item $elk->requestKeypadFunctionKeyIlluminationStatus( keypad => 2 );

Request the FunctionKeyIlluminationStatus for the specified keypad. 
Takes a hash with one named argument, keypad. This method will
return a L<ElkM1::Control::Message::KeypadKeyChangeUpdate> upon
success, undef on failure.

=cut

sub requestKeypadFunctionKeyIlluminationStatus {
    my $self = shift;
    my %args = @_;
    my $keypad;

    $self->_checkParam(
        { 'keypad' => { rules => $KEYPAD_PARAM, var => \$keypad }, }, \%args );

    warn Dumper \%args;

    $self->sendCommand( sprintf( 'kc%02d', $keypad ) );
    return $self->readMessage('KC');
}

# Method to calculate a house/unit code from a given index. The
# index value is given in the serial module documentation and
# also is the index for the textual string representing the
# light.

sub _calculateHouseUnitCode {
    my $self  = shift;
    my $index = shift;

    my $house = chr( 65 + ( ceil( $index / 16 ) - 1 ) );
    my $unit  = $index % 16;

    return ( $house, $unit );
}

=item $elk->turnOnPLCDevice( unit => 2, house => 'A' [ index => 123 ] );

Request that a PLC device be turned on. Requires either a house/unit code
or an index. The index is the numberical listing from the Elk documentation
and also is the number associated with the text string for that light. You
cannot specify both a unit/house code and an index. Use one or the other.
This method returns nothing, but you should recieve an 
L<ElkM1::Control::Message::PLCChangeUpdate> message when any PLC device 
changes state. 

=cut

sub turnOnPLCDevice {
    my $self = shift;
    my %args = @_;
    my $house;
    my $unit;
    my $index;

    $self->_checkParam(
        {
            'house' => { rules => $HOUSE_PARAM, var => \$house },
            'unit'  => { rules => $UNIT_PARAM,  var => \$unit },
        },
        'index' => {
            allow => sub { ( $_[0] >= 1 and $_[0] <= 256 ) },
            var         => \$index,
            description => 'an device index from 1..256'
        },
        \%args
    );

    croak "turnOnPLCDevice: house/unit and index cannot both be specified."
      if ( ( $house or $unit ) and $index );

    ( $house, $unit ) = $self->_calculateHouseUnitCode($index)
      if ($index);

    $self->sendCommand( sprintf( 'pn%s%02d', $house, $unit ) );
}

=item $elk->turnOffPLCDevice( unit => 2, house => 'A' [ index => 123 ] );

Request that a PLC device be turned off. Requires either a house/unit code
or an index. The index is the numberical listing from the Elk documentation
and also is the number associated with the text string for that light. You
cannot specify both a unit/house code and an index. Use one or the other.
This method returns nothing, but you should recieve an 
L<ElkM1::Control::Message::PLCChangeUpdate> message when any PLC device 
changes state. 

=cut

sub turnOffPLCDevice {
    my $self = shift;
    my %args = @_;
    my $house;
    my $unit;
    my $index;

    $self->_checkParam(
        {
            'house' => {
                allow => sub { ( ord( $_[0] ) >= 65 and ord( $_[0] ) <= 77 ) },
                var         => \$house,
                description => 'an valid house code A..P'
            },
            'unit' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
                var         => \$unit,
                description => 'an unit code from 1..16'
            },
            'index' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 256 ) },
                var         => \$index,
                description => 'an device index from 1..256'
            }
        },
        \%args
    );

    croak "turnOffPLCDevice: house/unit and index cannot both be specified."
      if ( ( $house or $unit ) and $index );

    ( $house, $unit ) = $self->_calculateHouseUnitCode($index)
      if ($index);

    $self->sendCommand( sprintf( 'pf%s%02d', $house, $unit ) );
}

=item $elk->togglePLCDevice( unit => 2, house => 'A' [ index => 123 ] );

Request that a PLC device be turned toggled. This means turned off if it
is currently on, and turned on if it is currently off.  Requires either 
a house/unit code or an index. The index is the numberical listing from 
the Elk documentation and also is the number associated with the text 
string for that light. You cannot specify both a unit/house code and an 
index. Use one or the other.  This method returns nothing, but you should
recieve an L<ElkM1::Control::Message::PLCChangeUpdate> message when any 
PLC device changes state. 

=cut

sub togglePLCDevice {
    my $self = shift;
    my %args = @_;
    my $house;
    my $unit;
    my $index;

    $self->_checkParam(
        {
            'house' => {
                allow => sub { ( ord( $_[0] ) >= 65 and ord( $_[0] ) < 77 ) },
                var         => \$house,
                description => 'an valid house code A..P'
            },
            'unit' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
                var         => \$unit,
                description => 'an unit code from 1..16'
            },
            'index' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 256 ) },
                var         => \$index,
                description => 'an device index from 1..256'
            },
        },
        \%args
    );

    croak "togglePCDDevice: house/unit and index cannot both be specified."
      if ( ( $house or $unit ) and $index );

    ( $house, $unit ) = $self->_calculateHouseUnitCode($index)
      if ($index);

    $self->sendCommand( sprintf( 'pt%c%02d', $house, $unit ) );
}

=item $elk->controlPLCDevice( unit => 2, house => 'A', [ index => 123 ], function => 2, extended => 54, ontime => 180 );

Control a PLC device given a function and extended X10 code. Requires 
either a house/unit code or an index. The index is the numberical listing 
from the Elk documentation and also is the number associated with the text 
string for that light. You cannot specify both a unit/house code and an 
index. Use one or the other. The function and extended arguments control
the action of the PLC device. See the manufacture of your PLC devices for
details. This is commonly used to activate scenes, or advanced commands of
some X10 devices.  This method returns nothing, but you should recieve 
an L<ElkM1::Control::Message::PLCChangeUpdate> message when any PLC device 
changes state. 

#TODO how to does this method work? does a PLCChangeUpdate get recieved?

=cut

sub controlPLCDevice {
    my $self = shift;
    my %args = @_;
    my $house;
    my $unit;
    my $index;
    my $function;
    my $extended;
    my $onTime;

    $self->_checkParam(
        {
            'house' => {
                allow => sub { ( $_[0] >= 'A' and $_[0] <= 'P' ) },
                required    => 1,
                var         => \$house,
                description => 'an valid house code A..P'
            },
            'unit' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
                required    => 1,
                var         => \$unit,
                description => 'an unit code from 1..16'
            },
            'index' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 256 ) },
                var         => \$index,
                description => 'an device index from 1..256'
            },
            'function' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
                required    => 1,
                var         => \$function,
                description => 'an function code from 1..16'
            },
            'extended' => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 99 ) },
                required    => 1,
                var         => \$extended,
                description => 'an extended code 0..99'
            },
            'ontime' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 9999 ) },
                default     => 0,
                var         => \$onTime,
                description => 'an ontime from 0..9999'
            },
        },
        \%args
    );

    croak "controlPLCDevice: house/unit and index cannot both be specified."
      if ( ( $house or $unit ) and $index );

    ( $house, $unit ) = $self->_calculateHouseUnitCode($index)
      if ($index);

    $self->sendCommand(
        sprintf(
            'pc%c%02d%02d%02d%04d',
            $house, $unit, $function, $extended, $onTime
        )
    );
}

=item $elk->requestPLCStatus( bank => 0 );

Request status of a PLC device.  Requires a bank number which represents
which devices will have status returned for. Bank 0 is devices A1-D16, 
Bank 1 is E1 to H16, Bank 2 is I1 to L16 and Bank 3 is M1 to P16. This 
method returns an L<ElkM1::Control::Message::PLCStatusReply> on success,
and undef on failure. 

=cut

sub requestPLCStatus {
    my $self = shift;
    my %args = @_;
    my $bank;

    $self->_checkParam(
        {
            'bank' => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 3 ) },
                required    => 1,
                var         => \$bank,
                description => 'an bank 0..3'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'ps%d', $bank ) );
    return $self->readMessage('PS');
}

=item $elk->displayTextOnLCDScreen( area => 1, line1 => 'hello", line2 => 'how are you?', beep => 0, clear => 1 );

Request that the specific text show on the LCD screen. Takes a hash
with the following options: area (defaults to 1 if not specified), 
line1 the first line of text, line2 the secone line of text, beep
true if beeping on the keypad, clear true if the user can clear by 
pressing * and timeout the number of seconds to display the message 
before automatically erasing it. 

Returns nothing.

=cut

sub displayTextOnLCDScreen {
    my $self = shift;
    my %args = @_;
    my ( $area, $clear, $beep, $timeout, $line1, $line2 );

    $self->_checkParam(
        {
            area    => { rules => $AREA_PARAM, var => \$area },
            'line1' => {
                allow =>
                  sub { ( length( $_[0] ) >= 0 and length( $_[0] ) <= 16 ) },
                var         => \$line1,
                default     => '',
                description => 'a line of text at most 16 characters'
            },
            'line2' => {
                allow =>
                  sub { ( length( $_[0] ) >= 0 and length( $_[0] ) <= 16 ) },
                var         => \$line2,
                default     => '',
                description => 'a line of text at most 16 characters'
            },
            'beep' => {
                allow       => qr/^(1|0)$/,
                default     => 0,
                var         => \$beep,
                description => 'must be 1 or 0'
            },
            'clear' => {
                allow       => qr/^(1|0)$/,
                default     => 1,
                var         => \$clear,
                description => 'must be 1 or 0'
            },
            'timeout' => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 65535 ) },
                default     => 0,
                var         => \$timeout,
                description => 'must be 1..65535'
            },
        },
        \%args
    );

    substr( $line1, length($line1), 1, '^' )
      if ( length($line1) < 16 );

    substr( $line2, length($line2), 1, '^' )
      if ( length($line1) < 16 );

    $self->sendCommand(
        sprintf(
            'dm%d%d%d%05d%-16s%-16s',
            $area, $clear, $beep, $timeout, $line1, $line2
        )
    );
}

=item $elk->requestStringTextDescription( type => '0', index => 43 );

Request that the text description for a zone, light, etc be reported
back via a L<ElkM1::Control::Message::StringTextDescriptionReply> 
message. Takes a hash with two arguments, a type which is a number
from 0..17 indicating the type of message and index a value from 
0..256. The index value depends on the type selected. This method
returns a L<ElkM1::Control::Message::StringTextDescriptionReply> 
upon succed, and undef on failure.

It should be noted that you may not get back the string you asked
for if it doesn't exist. According to the spec it may return
the next string available. It will return a reply with the index
set to 0 when there are no more strings available. This make it
faster to load all the strings from the panel. 

# TODO make type take a number or a name. 

=cut

sub requestStringTextDescription {
    my $self = shift;
    my %args = @_;
    my $type;
    my $index;

    $self->_checkParam(
        {
            'type' => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 17 ) },
                required    => 1,
                var         => \$type,
                description => 'must be a type 0..17'
            },
            'index' => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 256 ) },
                required    => 1,
                var         => \$index,
                description => 'must be an index 0..256'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( "sd%02d%03d", $type, $index ) );

    return $self->readMessage('SD');
}

=item $elk->requestTemperature( group => 1, device => 1)

Request the temperature from the specified group and device. The
group is either 0 for temperature probe, 1 for keypads and 2 for
thermostats. The device is the specific groups device number. This
method returns a L<ElkM1::Control::Message::TemperatureReply> 
with the information requested.

# TODO make group take a number of name.

=cut

sub requestTemperature {
    my $self = shift;
    my %args = @_;
    my $group;
    my $device;

    $self->_checkParam(
        {
            'group' => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 2 ) },
                required    => 1,
                var         => \$group,
                description => 'must be a group 0..2'
            },
            'device' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
                required    => 1,
                var         => \$device,
                description => 'must be an device 1..16'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'st%d%02d', $group, $device ) );
    return $self->readMessage('ST');
}

=item $elk->requestThermostatData( thermostat => 1 );

Request information from the specified thermostat. This method 
returns a L<ElkM1::Control::Message::ThermostatDataReply> with the 
information requested. 

=cut

sub requestThermostatData {
    my $self = shift;
    my %args = @_;
    my $thermostat;

    $self->_checkParam(
        {
            'thermostat' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
                required    => 1,
                var         => \$thermostat,
                description => 'must be an thermostat 1..16'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'tr%02d', $thermostat ) );
    return $self->readMessage('TR');
}

sub readCustomValue {
    my $self = shift;
    my %args = @_;
    my $index;

    $self->_checkParam(
        {
            'index' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 20 ) },
                required    => 1,
                var         => \$index,
                description => 'must be an index 1..20'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'cr%02d', $index ) );
    return $self->readMessage('CR');
}

sub readAllCustomValues {
    my $self = shift;

    $self->sendCommand('cp');
    return $self->readMessage('CR');
}

sub writeCustomValue {
    my $self = shift;
    my %args = @_;
    my $index;
    my $value;

    $self->_checkParam(
        {
            'value' => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 99999 ) },
                required    => 1,
                var         => \$value,
                description => 'must be a value 0..99999'
            },
            'index' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 20 ) },
                required    => 1,
                var         => \$index,
                description => 'must be an index 1..20'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( 'cw%02d%05d', $index, $value ) );
    return $self->readMessage('CR');
}

sub requestValidUserCodeAreas {
    my $self = shift;
    my %args = @_;
    my $area;
    my $code;

    $self->_checkParam( { code => { rules => $CODE_PARAM, var => \$code }, },
        \%args );

    $self->sendCommand( sprintf( 'ua%06d', $code ) );
    return $self->readMessage('UA');
}

sub requestKeypadAreaAssignments {
    my $self = shift;
    $self->sendCommand('ka');
    return $self->readMessage('KA');
}

sub requestKeypadFunctionKeyPress {
    my $self = shift;
    my %args = @_;
    my $keypad;
    my $functionkey;

    $self->_checkParam(
        {
            'keypad' => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 16 ) },
                var         => \$keypad,
                description => 'an keypad from 1..16'
            },
            'functionkey' => {
                allow => sub {
                    ( $_[0] >= 1 and $_[0] <= 6 )
                      or $_[0] eq '*'
                      or $_[0] eq 'C';
                },
                var         => \$functionkey,
                description => 'an functionkey 1..6, * or C'
            },
        },
        \%args
    );

    $self->sendCommand( 'kf' . $keypad . $functionkey );
    return $self->readMessage('KF');
}

sub requestZoneDefinitions {
    my $self = shift;

    $self->sendCommand('zd');
    return $self->readMessage('ZD');
}

sub requestZoneVoltage {
    my $self = shift;
    my %args = @_;
    my $zone;

    $self->_checkParam(
        {
            zone => {
                allow => sub { ( $_[0] <= 208 and $_[0] >= 1 ) },
                var         => \$zone,
                description => 'an zone 1..208'
            },
        },
        \%args
    );

    $self->sendCommand( sprintf( "zv%03d", $zone ) );
    return $self->readMessage('ZV');
}

sub requestRealTimeClock {
    my $self = shift;

    $self->sendCommand('rr');
    return $self->readMessage('RR');
}

sub writeRealTimeClock {
    my $self = shift;
    my %args = @_;
    my $zone;
    my ( $hour, $min, $sec, $day, $dayofweek, $month, $year );

    $self->_checkParam(
        {
            hour => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 23 ) },
                var         => \$hour,
                description => 'an hour 0..23'
            },
            min => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 59 ) },
                var         => \$min,
                description => 'an min 0..59'
            },
            sec => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 59 ) },
                var         => \$sec,
                description => 'an min 0..59'
            },
            day => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 31 ) },
                var         => \$day,
                description => 'an day of month 1..31'
            },
            dayofweek => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 7 ) },
                var         => \$dayofweek,
                description => 'an day of week 1..7'
            },
            month => {
                allow => sub { ( $_[0] >= 1 and $_[0] <= 12 ) },
                var         => \$month,
                description => 'an min 1..12'
            },
            year => {
                allow => sub { ( $_[0] >= 0 and $_[0] <= 99 ) },
                var         => \$year,
                description => 'an year 0..99'
            },
        },
        \%args
    );

    $self->sendCommand(
        sprintf(
            'rw%02d%02d%02d%d%02d%02d%02d',
            $sec, $min, $hour, $dayofweek, $day, $month, $year
        )
    );
    return $self->readMessage('RR');
}

sub requestAllTemperatureData {
    my $self = shift;

    $self->sendCommand('lw');
    return $self->readMessage('LW');
}

=item $elk->readMessage($type)

read a message from the ElkM1 panel. The type argument specifies
the type of message you would like to read according to the 
two character code for that message type. If a message is received
which doesn't match the requested type it is put in a queue and
the method continues reading. If no message is received undef is
returned. Otherwise a message object is returned. By not specifying
a $type messages of any type will be returned. 

=cut

sub readMessage {
    my $self = shift;
    my $type = shift;

    # Look through existing messages return any existing
    # if they match our requested type or no specific type was specified.
    for ( my $i = 0 ; $i < scalar( @{ $self->{_queue} } ) ; $i++ ) {
        my $elm = $self->{_queue}->[$i];
        if ( !defined($type) || $elm->type eq $type ) {
            splice @{ $self->{_queue} }, $i, 1;
            return $elm;
        }
    }

    while ( my $msg = $self->_readLine ) {
        $msg =~ s/\r\n//g;

        print "readMessage: rawMessage '" . $msg . "'\n"
          if ( $self->{debug} );
        my $msgObj = ElkM1::Control::MessageFactory->instantiate($msg);

        print "readMessage: " . $msgObj->toString . "\n"
          if ( $self->{debug} > 2 );

# Return the actual object only if its the type we want or no type was specified.
        return $msgObj
          if ( !defined($type) || $msgObj->type eq $type );

        print "readMessage: wanted $type, got "
          . $msgObj->type
          . ". Adding to queue.\n"
          if ( $self->{debug} );

        push @{ $self->{_queue} }, $msgObj;
    }

    return undef;
}

# Read a line from the socket with timeout and return of undef.

sub _readLine {
    my $self   = shift;
    my $socket = $self->{_socket};
    my $line   = undef;

    eval {
        local $SIG{ALRM} = sub { die "alarm\n"; };
        alarm 1;
        $line = (<$socket>);
        alarm 0;
    };

    if ($@) {
        return undef
          if ( $@ eq "alarm\n" );
        croak;
    }

    return $line;
}

sub sendCommand {
    my $self   = shift;
    my $msg    = shift;
    my $socket = $self->{_socket};

    $msg = new ElkM1::Control::Message( command => $msg )
      unless ( ref($msg) );

    my $cmd = $msg->message;

    warn "sendCommand: " . $msg->toString . "\n"
      if ( $self->{debug} );

    print $socket $cmd . "\r\n";
}
1;
__END__

=head1 VERSION

Version 0.1.1

=cut

=head1 AUTHOR

James A. Russo <jr@halo3>

=cut

=head1 TODO

    o Add serial communication support.
    o more documentation, cleanup returns on some methods in Command.
    o write some example applications. 

=cut
