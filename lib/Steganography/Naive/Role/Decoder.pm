use 5.20.0;
use strict;
use warnings;

package Steganography::Naive::Role::Decoder {

    # VERSION
    # ABSTRACT: The role all decoders should do

    use Moose::Role;
    with qw/Steganography::Naive::Role::Internals/;
    use Types::Path::Tiny -types;
    use Types::Standard -types;
    use experimental qw/postderef signatures/;
    requires qw/decode/;

    sub do_simple_decoding($self, $decode_from, $decode_until) {

        my @chars = ();
        my $have_found_start_of_text = defined $decode_from ? 0 : 1;  # if $decode_from is undefined, search from the start
        my $current_bins = '';

        my $last_y = 0;
        my $last_x = 0;
        my $last_color = 0;

        Y:
        for my $y (0 .. $self->image->getheight - 1) {
            next Y if !$self->y_start_check($y);

            X:
            for my $x (0 .. $self->image->getwidth - 1) {
                next X if !$self->x_start_check($y, $x);

                $last_y = $y;
                $last_x = $x;

                my $color = $self->image->getpixel(x => $x, y => $y);
                my @colors = ($color->rgba)[0..2]; # don't want alpha

                COLORPART:
                for my $i (0 .. scalar @colors - 1) {
                    my $colorpart = $colors[$i];
                    next COLORPART if !$self->color_start_check($y, $x, $i);
                    next COLORPART if $colorpart == 255;

                    $current_bins .= $colorpart % 2;
                    $last_color = $i;

                    next COLORPART if length $current_bins != 8;

                    if($have_found_start_of_text) {
                        if($current_bins eq $decode_until) {
                            last Y;
                        }
                        else {
                            push @chars => chr(oct("0b$current_bins"));
                        }
                    }
                    if(defined $decode_from && !$have_found_start_of_text && $current_bins eq $decode_from) {
                        $have_found_start_of_text = 1;
                    }
                    $current_bins = '';
                }
            }
        }
        if($last_color < 2) {
            $self->start_color_index($last_color + 1);
            $self->start_x($last_x);
            $self->start_y($last_y);
        }
        else {
            $last_color = 0;

            if($last_x < $self->image->getwidth - 1) {
                $self->start_x($last_x + 1);
                $self->start_y($last_y);
            }
            elsif($last_y < $self->image->getheight - 1) {
                $self->start_x(0);
                $self->start_y($last_y + 1);
            }
            else {
                die 'Image does not appear large enough to contain the text';
            }
        }

        return join '' => @chars;

    }

}

1;

__END__

=pod

=head1 SYNOPSIS

    use Steganography::Naive::Role::Decoder;

=head1 DESCRIPTION

Steganography::Naive::Role::Decoder is ...

=head1 SEE ALSO

=cut
