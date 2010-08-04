package Google::Wave::Robot::Element;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str HashRef ArrayRef);
use Google::Wave::Robot::Types qw(Wavelet);

my %element_class_for;
my %type_for;
my %attributes_for;

method register_element_class ( ClassName $class: Str $type, Str :class($element_class)?, ArrayRef[Str] :$attributes? ) {
    $element_class //= caller;
    $element_class_for{$type} = $element_class;
    $type_for{$element_class} = $type;

    $attributes //= [];
    for my $attribute (@$attributes) {
        my ($name, $target) = $attribute =~ m/^([^=]+)=?(.*)$/;
        confess "couldn't parse element attribute '$attribute'" if !$name;

        if (!$target) {
            $target = $name;
            $target =~ s/([A-Z])/'_'.lc($1)/ge;
        }

        $attributes_for{$type}->{$name} = $target;
    }
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

    my %args;

    if (exists $json->{properties}) {
        $args{properties} = $json->{properties};

        for my $name (keys %{$attributes_for{$type}}) {
            next if !exists $args{properties}->{$name};
            $args{$attributes_for{$type}->{$name}} = $json->{properties}->{$name};
        }
    }

    return $element_class->new(%args);
}

__PACKAGE__->meta->make_immutable;

1;

__END__
