package Google::Wave::Robot::Annotation;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Str Int);

has name => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has value => (
    is      => "ro",
    isa     => Str,
    default => '',
);


subtype 'PositiveInt',
    as Int,
    where { $_ >= 0 };

has start => (
    is       => "ro",
    isa      => "PositiveInt",
    required => 1,
);

has end => (
    is       => "ro",
    isa      => "PositiveInt",
    required => 1,
);


method BUILD () {
    confess "start must be less than or equal to end" if $self->start > $self->end;
}


method serialize () {
    return {
        name  => $self->name,
        value => $self->value,
        range => {
            start => $self->start,
            end   => $self->end,
        },
    };
}

__PACKAGE__->meta->make_immutable;

1;
