package WordListMod;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(get_mod_wordlist);

use Monkey::Patch::Action qw(patch_object);

our @handles;

sub get_mod_wordlist {
    my ($wl_mod, @mod_mods) = @_;

    $wl_mod = "WordList::$wl_mod" unless $wl_mod =~ /\AWordList::/;

    (my $wl_mod_pm = "$wl_mod.pm") =~ s!::!/!g; require $wl_mod_pm;
    my $wl = $wl_mod->new;

    for my $mod (@mod_mods) {
        $mod = "WordListMod::$mod" unless $mod =~ /\AWordListMod::/;
        (my $mod_pm = "$mod.pm") =~ s!::!/!g; require $mod_pm;

        my $patches = \@{"$mod\::patches"};
        for my $p (@$patches) {
            push @handles, patch_object($wl, @$p);
        }
    }

    $wl;
}

1;
# ABSTRACT: Modified wordlist

=head1 SYNOPSIS

 use WordListMod qw(get_mod_wordlist);

 my $wl = get_mod_wordlist('EN::Foo', 'Bloom');
 $wl->word_exists("foo");


=head1 DESCRIPTION

EXPERIMENTAL.

This module instantiates a wordlist class (C<WordList::*>) then applies
per-object patches from one or more mod's (C<WordListMod::*> modules).


=head1 FUNCTIONS

None of the functions are exported by default, but they are exportable.

=head2 get_mod_wordlist

Usage:

 get_mod_wordlist($wl_mod, @mod_mods) => obj

Instantiate a wordlist class (C<< WordList::<$wl_mod> >>) then apply the patches
from zero or more "mod" modules (modules in C<WordListMod::*> namespace). The
patches are per-object.


=head1 SEE ALSO

L<WordList>
