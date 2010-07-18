package Google::Wave::Robot::Operation;

use warnings;
use strict;

use Moose;
use MooseX::Method::Signatures;

use constant PROTOCOL_VERSION => "0.22";

use constant {
    WAVELET_APPEND_BLIP             => 'wavelet.appendBlip',
    WAVELET_SET_TITLE               => 'wavelet.setTitle',
    WAVELET_ADD_PARTICIPANT         => 'wavelet.participant.add',
    WAVELET_DATADOC_SET             => 'wavelet.datadoc.set',
    WAVELET_MODIFY_TAG              => 'wavelet.modifyTag',
    WAVELET_MODIFY_PARTICIPANT_ROLE => 'wavelet.modifyParticipantRole',
    BLIP_CREATE_CHILD               => 'blip.createChild',
    BLIP_DELETE                     => 'blip.delete',
    DOCUMENT_APPEND_MARKUP          => 'document.appendMarkup',
    DOCUMENT_INLINE_BLIP_INSERT     => 'document.inlineBlip.insert',
    DOCUMENT_MODIFY                 => 'document.modify',
    ROBOT_CREATE_WAVELET            => 'robot.createWavelet',
    ROBOT_FETCH_WAVE                => 'robot.fetchWave',
    ROBOT_NOTIFY                    => 'robot.notifyCapabilitiesHash',
    ROBOT_SEARCH                    => 'robot.search',
};

use constant NOTIFY_OP_ID => '0';

has "method" => (
    is       => "ro",
    isa      => "Str",
    required => 1,
);

has "id" => (
    is       => "ro",
    isa      => "Str",
    required => 1,
);

has "params" => (
    is  => "ro",
    isa => "HashRef",
);

method serialize ( Str :$method_prefix? = '') {
    $method_prefix += '.' if $method_prefix;
    return {
        method => $method_prefix.$self->method,
        id     => $self->id,
        params => $self->params,
    };
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__
