package Google::Wave::Robot::Element::Attachment;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Element");

__PACKAGE__->register_element_class("ATTACHMENT", attributes => [qw(attachmentId attachmentUrl mimeType caption)]);

has attachment_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has attachment_url => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has mime_type => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

# XXX required?
has caption => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

=pod
# XXX python cl lists this. what is this?
has data => (
    is      => "ro",
    isa     => Str,
    default => '',
);
=cut



__PACKAGE__->meta->make_immutable;

1;

__END__
