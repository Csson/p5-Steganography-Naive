use 5.20.0;
use strict;
use warnings;

package Steganography::Naive::Role::Internals {

    # VERSION
    # ABSTRACT: ...

    use Moose::Role;
    use MooseX::AttributeShortcuts;
    use Types::Path::Tiny -types;
    use Types::Standard -types;
    use Imager;
    use experimental qw/postderef signatures/;

    has input_image => (
        is => 'ro',
        isa => File,
        coerce => 1,
        required => 1,
    );
    has image => (
        is => 'ro',
        isa => Any,
        lazy => 1,
        builder => 1,
    );
    has start_x => (
        is => 'rw',
        isa => Int,
        default => 0,
    );
    has start_y => (
        is => 'rw',
        isa => Int,
        default => 0,
    );
    has start_color_index => (
        is => 'rw',
        isa => Int, # 0..2
        default => 0,
    );

    sub _build_image($self) {
        my $image = Imager->new;
        $image->read(file => $self->input_image) or die $image->errstr;
    }
    sub y_start_check($self, $y) {
        return $self->start_y <= $y ? 1 : 0;
    }
    sub x_start_check($self, $y, $x) {
        return $self->start_y < $y || $self->start_x <= $x ? 1 : 0;
    }
    sub color_start_check($self, $y, $x, $color) {
        return $self->start_y < $y || $self->start_x < $x || $self->start_color_index <= $color ? 1 : 0;
    }

}

1;
