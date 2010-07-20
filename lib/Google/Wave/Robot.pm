package Google::Wave::Robot;
# ABSTRACT: Wave Robot client library for Perl

use 5.010;

our $VERSION = '0.01';

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

method verification_token_info () {
}

method setup_oauth () {
}

method register_handler ( Str $event_class, CodeRef $handler ) {
}

method register_profile_handler () {
}

method capabilities_xml () {
}

method process_events () {
}

__PACKAGE__->meta->make_immutable;

1;

__END__
