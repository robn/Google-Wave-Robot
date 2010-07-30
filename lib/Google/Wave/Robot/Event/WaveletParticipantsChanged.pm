package Google::Wave::Robot::Event::WaveletParticipantsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str ArrayRef);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("WAVELET_PARTICIPANTS_CHANGED");

#
# XXX should these be Participant objects, more like the ones in Wavelet.pm?
# if they were then we could more easily do lookups against them eg
#
# for my $p ($e->participants_added) {
#   my $role        = $p->role;
#   my $participant = $p->profile;
# }
#     vs
#   my $role    = $e->wavelet->get_participant($p)->role;
#   my $profile = $e->wavelet->get_participant($p)->profile;
#

has _participants_added => (
    traits   => [ "Array" ],
    is       => "ro",
    isa      => ArrayRef[Str],
    default  => sub { [] },
    init_arg => "participants_added",
    handles  => {
        participants_added => 'elements',
    },
);

has _participants_removed => (
    traits   => [ "Array" ],
    is       => "ro",
    isa      => ArrayRef[Str],
    default  => sub { [] },
    init_arg => "participants_removed",
    handles  => {
        participants_removed => 'elements',
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
