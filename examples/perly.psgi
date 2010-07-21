#!/usr/bin/env plackup

use 5.010;

use warnings;
use strict;

use Google::Wave::Robot;
use Google::Wave::Robot::Handler::PSGI;

sub on_wavelet_participants_changed {
    my ($event, $wavelet) = @_;
}

sub on_wavelet_self_added {
    my ($event, $wavelet) = @_;
}

my $robot = Google::Wave::Robot->new(
    name        => "perly",
    profile_url => "http://www.perl.org/",
    image_url   => "http://www.perl.org/i/icons/camel.png",
);

$robot->register_handler("Google::Wave::Robot::Event::WaveletParticipantsChanged", \&on_wavelet_participants_changed);
$robot->register_handler("Google::Wave::Robot::Event::WaveletSelfAdded",           \&on_wavelet_self_added);

return sub { Google::Wave::Robot::Handler::PSGI->run($robot, shift) };
