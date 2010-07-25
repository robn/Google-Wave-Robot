package Google::Wave::Robot::Blip::Set;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Types::Moose qw(HashRef);
use Google::Wave::Robot::Types qw(Blip);

has _blips => (
    traits  => [ "Hash" ],
    is      => "ro",
    isa     => HashRef[Blip],
    default => sub { {} },
    handles => {
        exists => 'exists',
        ids    => 'keys',
        add    => 'set',
        get    => 'get',
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
