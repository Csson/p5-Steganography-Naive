use 5.20.0;
use strict;
use warnings;

package Steganography::Naive::Plugin::Version1::Decoder {

    # VERSION
    # ABSTRACT: The default decoder

    use Moose;
    with qw/Steganography::Naive::Role::Decoder/;
    
    use experimental qw/signatures/;

    sub decode($self) {
        return $self->do_simple_decoding(undef, '00000011');
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
