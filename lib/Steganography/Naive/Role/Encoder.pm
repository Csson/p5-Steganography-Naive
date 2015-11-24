use 5.20.0;
use strict;
use warnings;

package Steganography::Naive::Role::Encoder {

    # VERSION
    # ABSTRACT: The role all encoders should do

    use Moose::Role;
    with qw/Steganography::Naive::Role::Internals/;
    use Types::Path::Tiny -types;
    use Types::Standard -types;
    use JSON::MaybeXS;
    use experimental qw/postderef signatures/;

    has output_image => (
        is => 'ro',
        isa => Path,
        coerce => 1,
        required => 1,
    );
    has header => (
        is => 'ro',
        isa => HashRef,
        default => sub { {} },
        traits => ['Hash'],
        handles => {
            set_header => 'set',
            header_pairs => 'kv',
        },
    );
    has content => (
        is => 'ro',
        isa => ArrayRef,
        default => sub { [] },
        traits => ['Array'],
        handles => {
            all_contents => 'elements',
            add_content => 'push',
        },
    );

    requires qw/decoder_class encode/;

    sub prepare_header_payload($self) {
        return $self->to_binary_string(encode_json { header => map { { $_->[0] => $_->[1] } } ($self->header_pairs) });
    }

    before encode => sub ($self) {
        $self->do_simple_encoding('00000001' . $self->prepare_header_payload . '00000111');
    };
    after encode => sub ($self) {
        $self->image->write(file => $self->output_image->realpath, type => 'png') or die $self->image->errstr;
    };

    sub to_binary_string($self, $content) {
        return join '' => map { sprintf '%.8d' => sprintf '%b', ord $_ } split m// => $content;
    }

    sub do_simple_encoding($self, $content) {

        my @binaries = split m// => $content;

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
                my $colors = [($color->rgba)[0..2]]; # don't want alpha

                COLOR:
                for my $i (0 .. scalar @$colors - 1) {
                    next COLOR if !$self->color_start_check($y, $x, $i);

                    last Y if !scalar @binaries;
                    $last_color = $i;

                    # by doing this, when decoding we know:
                    # * 254, 255 carry no data
                    # * 0..253 carry data
                    if($colors->[$i] == 254 || $colors->[$i] == 255) {
                        $colors->[$i] = 255;
                        next COLOR;
                    }
                    my $binary = shift @binaries;
                    if($binary == 0 && $colors->[$i] % 2 == 1) {
                        $colors->[$i] -= 1;
                    }
                    elsif($binary == 1 && $colors->[$i] % 2 == 0) {
                        $colors->[$i] += 1;
                    }
                }
                $color->set(@$colors, 0);
                $self->image->setpixel(x => $x, y => $y, color => $colors);
            }
        }
        if(scalar @binaries) {
            die 'Image is not large enough to contain the text';
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
    }
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Steganography::Naive::Role::Encoder;

=head1 DESCRIPTION

Steganography::Naive::Role::Encoder is ...

=head1 SEE ALSO

=cut
