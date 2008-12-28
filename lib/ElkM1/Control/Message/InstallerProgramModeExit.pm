package ElkM1::Control::Message::InstallerProgramModeExited;

# MessageType: 'IE'

=head1 NAME

    ElkM1::Control::Message:InstallerProgramModeExited:

=cut

=head1 SYNOPSIS

    my $msg = $elk->readMessage();

    if (ref($msg) eq "ElkM1::Control::Message::InstallerProgramModeExited") { 
        print "program mode has been exited";
    }

=cut

=head1 DESCRIPTION 

    This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Installer Program Mode Exited'
    message from the ElkM1 control. This mesage is used to indicate the ElkM1 has exited program mode. 

    #TODO find out why we need to know we exited programming mode?

    This object is usually instantiated via the MessageFactory object when a message is read. One wouldn't normally
    instantiate this object directly.

=cut

use base qw/ElkM1::Control::Message/;
use strict;
use warnings;

=head1 METHODS

=cut

=item toString()

    returns a human readable string containing all information for status of all areas. 

=cut

sub toString { 
	'InstalledProgramModeExited';
}

=head1 VERSION 

1.0

=cut

=head1 SEE ALSO

ElkM1::Control, ElkM1::Control::Message, ElkM1::Control::MessageFactory

=cut

=head1 AUTHOR

James Russo <jr@halo3.net>

=cut

1;
