use 5.20.0;
use strict;
use warnings;

package Steganography::Naive::Plugin::Version1::Encoder {

    # VERSION
    # ABSTRACT: The default encoder

    use Moose;
    with qw/Steganography::Naive::Role::Encoder/;
    
    use experimental qw/signatures/;

    sub decoder_class { 'Steganography::Naive::Plugin::Version1::Decoder' }

    sub encode($self) {
        $self->do_simple_encoding($self->to_binary_string(join '' => $self->all_contents) . '00000011');
    }
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Steganography::Naive::Plugin::Version1;

=head1 DESCRIPTION

Steganography::Naive::Plugin::Version1 is ...

=head1 SEE ALSO

=cut
