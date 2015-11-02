use 5.20.0;
use strict;
use warnings;

package Steganography::Naive::Util {

    # VERSION
    # ABSTRACT: ..

    use Try::Tiny;
    use Module::Load 'load';

    use Sub::Exporter::Progressive -setup => {
        exports => [qw/load_module/],
        groups => {
            default => [qw/load_module/],
        },
    };

    sub load_module($) {
        my $module = shift;

        try {
            load $module;
        }
        catch {
            die "Can't load $module: $_";
        };
    }

}

1;
