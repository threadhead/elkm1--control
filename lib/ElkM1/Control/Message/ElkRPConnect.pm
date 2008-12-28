package ElkM1::Control::Message::ElkRPConnect;

# MessageType: 'RP'

use base qw/ElkM1::Control::Message/;
use strict;
use warnings;

=item toString()

    returns a human readable string containing all information for status of all areas. 

=cut

sub toString { 
	'ElkRPConnect';
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

