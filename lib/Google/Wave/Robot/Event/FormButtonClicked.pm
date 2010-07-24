package Google::Wave::Robot::Event::FormButtonClicked;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(Wavelet);

extends ("Google::Wave::Robot::Event");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "FORM_BUTTON_CLICKED",
    init_arg => undef,
);

has button_name => (
    is  => "ro",
    isa => Str,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    my $args = $class->SUPER::BUILDARGS(json => $json, wavelet => $wavelet);
    
    $args->{button_name} = $json->{properties}->{buttonName};

    return $args;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
