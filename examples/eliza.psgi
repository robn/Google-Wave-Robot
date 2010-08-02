#!/usr/bin/env plackup

use 5.010;

use warnings;
use strict;

use Google::Wave::Robot;
use Google::Wave::Robot::Handler::PSGI;
use Chatbot::Eliza;

my $eliza = Chatbot::Eliza->new;

sub on_blip_submitted {
    my ($event, $wavelet) = @_;

    my $reply = $event->blip->continue_thread;
    $reply->append_markup($eliza->transform($event->blip->content));
}

my $robot = Google::Wave::Robot->new(
    name               => "eliza",
    profile_url        => "http://github.com/robn/Google-Wave-Robot/blob/master/examples/eliza.psgi",
    image_url          => "http://img38.imageshack.us/img38/518/elizabutton.jpg",
);

$robot->register_handler("Google::Wave::Robot::Event::BlipSubmitted", \&on_blip_submitted);

return sub { Google::Wave::Robot::Handler::PSGI->run($robot, shift) };
