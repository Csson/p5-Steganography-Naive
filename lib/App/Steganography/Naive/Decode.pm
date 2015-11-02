use 5.20.0;
use strict;
use warnings;

package App::Steganography::Naive::Decode {

    # VERSION
    # ABSTRACT: Short intro

    use MooseX::App::Command;
    extends 'App::Steganography::Naive';

    use Types::Path::Tiny -types;
    use Types::Standard -types;
    use JSON::MaybeXS;

    use Steganography::Naive::Util;
    use experimental qw/postderef signatures/;

    option input_image => (
        is => 'ro',
        isa => Path,
        coerce => 1,
        cmd_aliases => [qw/in/],
        required => 1,
    );

    sub run($self) {
        my $dummy_decoder_class = 'Steganography::Naive::Plugin::Version1::Decoder';
        load_module $dummy_decoder_class;
        
        my $bootstrapped_decoder = $dummy_decoder_class->new(input_image => $self->input_image->realpath);
        my $header = decode_json $bootstrapped_decoder->do_simple_decoding('00000001', '00000111');

        my $encoder_class = $header->{'header'}{'encoder'};
        load_module $encoder_class;

        my $decoder_class = $encoder_class->decoder_class;
        load_module $decoder_class;

        my $decoder = $decoder_class->new(
                                    input_image => $self->input_image->realpath,
                                    start_y => $bootstrapped_decoder->start_y,
                                    start_x => $bootstrapped_decoder->start_x,
                                    start_color_index => $bootstrapped_decoder->start_color_index,
                                );
        say $decoder->decode;

    }


}

1;

__END__

=pod

=head1 SYNOPSIS

    use Steganography::Naive::Encode;

=head1 DESCRIPTION

Steganography::Naive is ...

=head1 SEE ALSO

=cut
