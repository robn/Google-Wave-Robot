package Google::Wave::Robot;
# ABSTRACT: Wave Robot client library for Perl

use 5.010;

our $VERSION = '0.01';

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Operation;
use Google::Wave::Robot::Event;

has "_handlers" => (
    is      => "rw",
    isa     => "HashRef",
    default => sub { {} },
);

has "capabilities_hash" => (
    is      => "ro",
    isa     => "Int",
    writer  => "_set_capabilities_hash",
    default => 0,
);

method verification_token_info () {
}

method setup_oauth () {
}

my $hash_func = sub {
    require B;
    return hex(B::hash(shift));
};

# XXX include context and filter
method register_handler ( Str $event_class, CodeRef $handler ) {
    my $type = $event_class->type;

    $self->_handlers->{$type} = {
        event_class => $event_class,
        handler     => $handler,
        # XXX context
        # XXX filter
    };

    $self->_set_capabilities_hash((
        $self->capabilities_hash * 13 +
        $hash_func->(Google::Wave::Robot::Operation::PROTOCOL_VERSION) + 
        $hash_func->($type)
        # XXX $hash_func->($context) +
        # XXX $hash_func->($filter)
    ) & 0xfffffff);
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
