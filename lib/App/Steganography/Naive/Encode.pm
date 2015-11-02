use 5.20.0;
use strict;
use warnings;

package App::Steganography::Naive::Encode {

    # VERSION
    # ABSTRACT: Short intro

    use MooseX::App::Command;
    extends 'App::Steganography::Naive';

    use MooseX::AttributeShortcuts;
    use MooseX::AttributeDocumented;
    use Path::Tiny;
    use Types::Path::Tiny -types;
    use Types::Standard -types;

    use Steganography::Naive::Util;
    use experimental qw/postderef signatures/;

    option input_image => (
        is => 'ro',
        isa => File,
        coerce => 1,
        cmd_aliases => [qw/in/],
        required => 1,
    );
    option output_image => (
        is => 'ro',
        isa => Path,
        coerce => 1,
        cmd_aliases => [qw/out/],
        required => 1,
    );
    option encoder => (
        is => 'ro',
        isa => Str,
        default => 'Version1',
    );
    option text => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    option file => (
        is => 'ro',
        isa => File,
        coerce => 1,
        predicate => 1,
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
    

    sub run($self) {
        die "You need to set either '--text' or '--file" if !$self->has_text && !$self->has_file;
        die "Don't use the same image for input and output" if $self->input_image->realpath eq $self->output_image->realpath;

        my $encoder_class = sprintf 'Steganography::Naive::Plugin::%s::Encoder', $self->encoder;
        $self->set_header(encoder => $encoder_class);

        if($self->has_text) {
            $self->add_content($self->text);
        }
        else {
            $self->add_content($self->file->slurp_raw);
        }

        load_module $encoder_class;

        my $encoder = $encoder_class->new(input_image => $self->input_image->realpath,
                                          output_image => $self->output_image->realpath,
                                          header => $self->header,
                                          content => $self->content);
        $encoder->encode;
        say 'Saved in ' . $self->output_image->realpath;
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
