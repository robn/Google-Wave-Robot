package Google::Wave::Robot::Event::FormButtonClicked;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::JSON qw(JSON);
use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "FORM_BUTTON_CLICKED";

has "button_name" => (
    is  => "ro",
    isa => "Str",
);

method BUILDARGS ( ClassName $class: JSON :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        button_name => $json->{properties}->{buttonName};
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
