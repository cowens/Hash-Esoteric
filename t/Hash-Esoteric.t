use strict;
use warnings;

use Test::More;
BEGIN { use_ok('Hash::Esoteric') };

my %h = (
	a => 1,
	b => 1,
	c => 1,
	d => 1,
	e => 1,
	f => 1,
	g => 1,
	h => 1,
);
my $aref = Hash::Esoteric::keys_by_bucket \%h;
my @keys = keys %h;
my @a    = map { @$_ } @$aref;

is_deeply \@a, \@keys, "all keys exist and are in order";

my $href = Hash::Esoteric::keys_by_collisions \%h;
my @b = sort map { @$_ } values %$href;
is_deeply \@b, [ sort @keys ], "all keys exist";

done_testing;
