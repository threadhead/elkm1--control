package ElkM1::Control::Message;

use Carp;
use warnings;
use strict;

=head1 NAME

ElkM1::Control::Message - Base class for all messages sent and recieved from the ElkM1.

=cut

=head1 SYNOPSIS

    # construct an disarm message for area 1, with code 3456. 
    $msg = ElkM1::Control::Message->new(command => 'a01003456');

    # construct the same message providing the complete message, 
    # not just the command.
    $msg = ElkM1::Control::Message->new(message => '0Da010034560038');

=cut

=head1 DESCRIPTION 

This is the base class for all messages used in the ElkM1::Control package. All of the responses from the Elk
panel should be a subclass from this. With this class you can provide a command (no size, 00 future use characters,
or checksum) and a message will automatically be constructed. You can also provide a message and it will be validated.

It's important to understand the difference between what we call messages and what we call commands. A message contains
a command. A message is a command with the length, 00 future use characters and checksum added. Once an object is constructed
you can access it via L<$msg->command> or L<$msg->message>. 

See the L<ElkM1::Control::MessageFactory> for a class which will construct message subclasses automatically based on their type. 

=cut

=head1 METHODS

=cut

=item ElkM1::Control::Message->new( message => '..', command => '..' )

    construct a ElkM1::Control::Message object. Takes one of two arguments
    in the form of a hash. 

    You can pass 'message' which will be a complete ready to send message 
    to the Elk panel. You must include everything from the size of the 
    message to the checksum. It will be validated, and if found not to be valid, 
    this method will croak.

    You can also pass a 'command' which is a command to send to the elk panel. The
    length, and checksum will be calculated and the two 'future use' characters (00)
    will also be added. 

    You cannot specify both command and message, use just one or the other. 

    On success a blessed object is returned, this method croaks on failure. 

=cut

sub new { 
	my $class = shift;
	my %obj; 

	my $self = bless \%obj, $class;

	croak "Unable to initalize $class"
        unless ($self->_init(@_));

	return $self;
}

sub _init {
	my $self = shift;
	my %args = @_;

	croak "command or message argument required."
		unless (defined($args{command}) or defined($args{message}));

	croak "command and message cannot be both specified"
		if (defined($args{command}) and defined($args{message}));

	$self->command($args{command})
		if ($args{command});

	$self->message($args{message})
		if ($args{message});

	croak "invalid message: ".$self->message
		unless ($self->_validate);

	return 1;
}

sub _assemble { 
	my $self = shift;
	my $command = shift;

	# Add the two future use characters. 
	$command .= '00';

	# Assemble it. 
	$self->{message} = sprintf('%0.2X',length($command) + 2).$command;
	$self->{message} .= $self->_calculateCksum($self->{message});
}

sub _calculateCksum { 
	my $self = shift;
	my $str = shift;
	my $val = 0;

	for (my $i=0;$i<length($str);$i++) { 
		$val += ord(substr($str,$i,1));
	}
	return sprintf('%0.2X',((~$val + 1) & 0xFF));
}

sub _validate {
	my $self = shift;
	my $length = length($self->message);
	my $val = hex(substr($self->message,$length-2,2));

	# Skip the actual checksum bytes.
	for (my $i=0;$i<length($self->message)-2;$i++) { 
		$val += ord(substr($self->message, $i, 1));
	}

	return ($val & 0xFF) == 0; 
}

=item $msg->type

    obtain the two character message type for this message. 

=cut

sub type { 
	my $self = shift;
	
	return substr($self->message,2,2);
}

=item $msg->message

    Obtain the message component of this message. This will be everything from 
    after the size, upto the future use characters (00).

=cut

sub message { 
	my $self = shift;

	$self->{message} = shift
		if (@_);

	return $self->{message};
}

=item $msg->command

    Obtain the full command ready to be sent to the ElkM1. 

=cut

sub command { 
	my $self = shift;
	my $command = shift;

	$self->_assemble($command)
		if ($command);

	return substr($self->message,2,length($self->message)-4);
}

=item $msg->toString

    Obtain a human readable string representing this message. 

=cut

sub toString { 
	my $self = shift;
	return 'Message: '.$self->message;
}

1;

__END__

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

ElkM1::Control, ElkM1::Control::MessageFactory

=cut

=head1 AUTHOR

James Russo <jr@halo3.net>

=cut
