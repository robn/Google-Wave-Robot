package Google::Wave::Robot::Participant::Set;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(HashRef Bool Str);
use Google::Wave::Robot::Types qw(Participant OperationQueue);

use Google::Wave::Robot::Participant;

has _participants => (
    traits  => [ "Hash" ],
    is      => "ro",
    isa     => HashRef[Participant],
    default => sub { {} },
    handles => {
        exists => 'exists',
        ids    => 'keys',
        _set   => 'set',
        get    => 'get',
    },
    #init_arg => "participants"
);

has wave_id => (
    is  => "ro",
    isa => Str,
);

has wavelet_id => (
    is  => "ro",
    isa => Str,
);

method standalone () {
    return !($self->wave_id && $self->wavelet_id);
}

has operation_queue => (
    is      => "ro",
    isa     => OperationQueue,
    default => sub { Google::Wave::Robot::Operation::Queue->new },
);

method add ( Str $id ) {
    return if $self->exists($id);
    $self->_set($id, Google::Wave::Robot::Participant->new(id => $id));

    if (!$self->standalone) {
        $self->operation_queue->wavelet_add_participant(
            wave_id        => $self->wave_id, 
            wavelet_id     => $self->wavelet_id, 
            participant_id => $id
        );
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__
