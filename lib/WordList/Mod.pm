package WordList::Mod;

# DATE
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
        $mod = "WordList::Mod::$mod" unless $mod =~ /\AWordList::Mod::/;
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

 use WordList::Mod qw(get_mod_wordlist);

 my $wl = get_mod_wordlist('EN::Foo', 'Bloom');
 $wl->word_exists("foo");


=head1 DESCRIPTION

EXPERIMENTAL.

This module instantiates a wordlist class (C<WordList::*>) then applies
per-object patches from one or more mod's (C<WordList::Mod::*> modules).


=head1 SEE ALSO

L<WordList>