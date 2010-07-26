package Google::Wave::Robot::Event;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str Int HashRef);
use Google::Wave::Robot::Types qw(Wavelet);

my %event_class_for;

method register_event_class ( ClassName $class: Str $type, Str :class($event_class)? ) {
    $event_class //= caller;
    $event_class_for{$type} = $event_class;
}

has type => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has wavelet => (
    is       => "ro",
    isa      => Wavelet,
    required => 1,
);

has modified_by => (
    is      => "ro",
    isa     => Str,
    default => '',
);

has timestamp => (
    is      => "ro",
    isa     => Int,
    default => 0,
);

has proxying_for => (
    is      => "ro",
    isa     => Str,
    default => '',
);

has blip_id => (
    is  => "ro",
    isa => Str,
);

method new_from_json ( ClassName $class: HashRef $json, Wavelet :$wavelet ) {
    my $type = $json->{type};
    confess "passed json has no type" if !$type;

    my $event_class = $event_class_for{$type};
    confess "event type '$type' not registered" if !$event_class;

    my %args = (
        type    => $type,
        wavelet => $wavelet,
    );

    $args{modified_by}  = $json->{modifiedBy}  if defined $json->{modifiedBy};
    $args{timestamp}    = $json->{timestamp}   if defined $json->{timestamp};
    $args{proxying_for} = $json->{proxyingFor} if defined $json->{proxyingFor};

    if (exists $json->{properties}) {
        for my $key ( keys %{$json->{properties}} ) {
            my $ukey = $key;
            $ukey =~ s/([A-Z])/'_'.lc($1)/ge;
            $args{$ukey} = $json->{properties}->{$key};
        }
    }

    return $event_class->new(%args);
}

method blip () {
    return if !$self->blip_id;
    return $self->wavelet->blip($self->blip_id);
}

__PACKAGE__->meta->make_immutable;

1;

__END__
