package App::optex::msdoc;

use 5.014;
use strict;
use warnings;

our $VERSION = "0.01";

=encoding utf-8

=head1 NAME

msdoc - module to replace MS document by its text contents

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

optex command -Mmsdoc

=head1 DESCRIPTION

This module replaces argument which terminate with I<.docx>, I<pptx>
or I<xlsx> files by node representing its text information.  File
itself is not altered.

For examle, you can check the text difference between ms word files
like this:

    $ optex diff -Mmsdoc OLD.docx NEW.docx

If you have symbolic link named B<diff> to B<optex>, and following
setting in your F<~/.optex.d/diff.rc>:

    option default --msdoc
    option --msdoc -Mmsdoc $<move>

Next command simply produces the same result.

    $ diff OLD.docx NEW.docx

Text data is extracted by B<greple> command with B<-Mmsdoc> module,
and above command is almost equivalent to below bash command using
process substitution.

    $ diff <(greple -Mmsdoc --dump OLD.docx) \
           <(greple -Mmsdoc --dump NEW.docx)

=head1 SEE ALSO

L<https://github.com/kaz-utashiro/optex-msdoc>

It is possible to use other data conversion program, like L<pandoc> or
L<Apache Tika>.  Feel to free to modify this module.  I'm reluctant to
use them, because they work quite leisurely.

=head1 LICENSE

Copyright (C) Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kazumasa Utashiro

=cut

package App::optex::msdoc;

use utf8;
use Encode;
use Data::Dumper;

binmode STDIN,  ":encoding(utf8)";
binmode STDOUT, ":encoding(utf8)";

my($mod, $argv);
sub initialize {
    ($mod, $argv) = @_;
    msdoc();
}

sub argv (&) {
    my $sub = shift;
    @$argv = $sub->(@$argv);
}

use App::optex::Tmpfile;

my @persist;

sub msdoc {
    argv {
	for (@_) {
	    my($suffix) = /\.(docx|pptx|xlsx)$/x or next;
	    my $tmp = new App::optex::Tmpfile;
	    $tmp->write(`greple -Mmsdoc --dump "$_"`)->rewind;
	    push @persist, $tmp;
	    $_ = $tmp->path;
	}
	@_;
    };
}

1;

__DATA__
