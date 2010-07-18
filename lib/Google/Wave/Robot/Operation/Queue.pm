package Google::Wave::Robot::Operation::Queue;

use warnings;
use strict;

use Moose;
use MooseX::Method::Signatures;

use Clone qw(clone);

my $next_operation_id = 1;

has "_pending" => (
    is      => "rw",
    isa     => "ArrayRef",
    default => sub { [] },
);

has "_capability_hash" => (
    is  => "rw",
    isa => "Str"
);

has "_proxy_for_id" => (
    is  => "rw",
    isa => "Str",
);

method _new_blipdata ( Str :$wave_id,
                       Str :$wavelet_id, 
                       Str :$initial_content? = '', 
                       Str :$parent_blip_id? ) {
    
    my $blip_id = sprintf q{TBD_%s_0x%08x}, $wavelet_id, int rand 2**32;

    return {
        waveId       => $wave_id,
        wavletId     => $wavelet_id,
        blipId       => $blip_id,
        content      => $initial_content,
        parentBlipId => $parent_blip_id,
    };
}

method _new_waveletdata ( Str :$domain, ArrayRef :$participants ) {
    my $wave_id = sprintf q{%s!TBD_0x%08x}, $domain, int rand 2**32;
    my $wavelet_id = "$domain!conv+root";

    my $blip_data = $self->_new_blipdata(
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
    );

    my $wavelet_data = {
        waveId       => $wave_id,
        waveletId    => $wavelet_id,
        rootBlipId   => $blip_data->{blipId},
        participants => clone($participants),
    };

    return ($blip_data, $wavelet_data);
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__
