package ElkM1::Control::Message::ValidUserCodeAreasReply;

#MessageType: 'UA'

use base ElkM1::Control::Message;
use strict;

our $VERSION = '1.0';

=head1 NAME

    ElkM1::Control::Message::ValidUserCodeAreasReply

=cut

=head1 SYNOPSIS

    $obj = $elk->requestValidUserCodeAreas(code => 1234); 
    print "code is valid in area 1? ". $obj->isValidInArea(1) ? "yes" : "no";
    print "code type is ". $obj->getCodeTypeName;

=cut

=head1 DESCRIPTION 

This is the subclass of the L<ElkM1::Control::Message> object which represents the 'Valid User Code Areas Reply'
message from the ElkM1 control. This mesage is sent in response to a 'Request Valid User Code Area' message. This
message information on where the specified user code is valid along with the type of code. 

=cut

my %TYPES = ('1' => 'User', 
			 '2' => 'Master',
			 '3' => 'Installer',
			 '4' => 'ElkRP');

=head1 Methods

=cut

=item getCode() 

    Obtain the code which is being requested as status as in integer. 

=cut

sub getCode { 
	my $self = shift;
	int(substr($self->command,2,6));
}

=item getAreaMask() 

    Obtain the area mask. This is a mask which indicates where the provided
    code is valid. See L<isValidInArea()> for a more user friendly method.

=cut

sub getAreaMask { 
	my $self = shift;
	int(hex(substr($self->command,8,2)));
}

=item isValidInArea($area) 

    Return true if the code is valid in the area provided, false otherwise.

=cut

sub isValidInArea { 
    my $self = shift;
    my $area = shift; 
    my $mask = (1<<($area - 1));

    return ($self->getAreaMask & $mask) == $mask;
}

=item getDiagnosticData() 

    Return the diagnostic data provided in the response packet. No information
    in the Elk documentation is provided on what this information is for.

=cut

sub getDiagnosticData { 
	my $self = shift;
	substr($self->command,10,8);
}

=item getUserCodeLength() 

    Return the number of digits in the user code. 

=cut

sub getUserCodeLength { 
	my $self = shift;
	int(substr($self->command,18,1));
}

=item getCodeType() 

    Return the value for the type of code according to the elk documentation. 1 for user code, 
    2 for master code, 3 for installer code and 4 for ElkRP.

=cut

sub getCodeType { 
	my $self = shift;
	substr($self->command,19,1);
}

=item getCodeTypeName() 

    Return a human readable name for the type of code. Returns one of
    'user', 'master', 'installer', or 'elkrp'.

=cut

sub getCodeTypeName { 
	my $self = shift;
	exists $TYPES{$self->getCodeType} ? $TYPES{$self->getCodeType} : '<unknown>';
}

=item toString()

    returns a human readable string containing all information for status of all areas. 

=cut

sub toString {
	my $self = shift;
	"ValidUserCodeAreasReply: code=".$self->getCode.
			", codeType=".$self->getCodeType.
			", codeTypeName=".$self->getCodeTypeName.
			", diag=".$self->getDiagnosticData.
			", areaMask=".$self->getAreaMask.
			", codeLength=".$self->getUserCodeLength;
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
