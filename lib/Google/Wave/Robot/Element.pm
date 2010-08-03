package Google::Wave::Robot::Element;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str HashRef);
use Google::Wave::Robot::Types qw(Wavelet);

my %element_class_for;
my %type_for;

method register_element_class ( ClassName $class: Str $type, Str :class($element_class)? ) {
    $element_class //= caller;
    $element_class_for{$type} = $element_class;
    $type_for{$element_class} = $type;
}

method type ( ClassName $class: ) {
    return $type_for{$class};
}

# XXX not sure what this needs yet
has properties => (
    is      => "ro",
    isa     => HashRef[Str],
    default => sub { {} },
);

method new_from_json ( ClassName $class: HashRef $json ) {
    my $type = $json->{type};
    confess "passed json has no type" if !$type;

    my $element_class = $element_class_for{$type};
    confess "element type '$type' not registered" if !$element_class;

    return $element_class->new_from_properties($json->{properties}) if exists $json->{properties};

    return $element_class->new;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
