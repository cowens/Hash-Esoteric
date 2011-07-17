use strict;
use warnings;

use Test::More;
use Scalar::Util qw/looks_like_number/;

BEGIN {
	use_ok 'Hash::Esoteric', qw(
		keys_by_bucket
		keys_by_collisions
		hash_seed
		rehashed
	);
};

{
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
	my $aref = keys_by_bucket \%h;
	my @keys = keys %h;
	my @a    = map { @$_ } @$aref;

	is_deeply \@a, \@keys, "all keys exist and are in order";

	my $used = () = grep { @$_ } @$aref;
	is "$used/" . @$aref, scalar %h, "used/buckets agrees with scalar %h";

	my $href = keys_by_collisions \%h;
	my @b = sort map { @$_ } values %$href;
	is_deeply \@b, [ sort @keys ], "all keys exist";
}

my @pathological = map { "\0" x $_ } 1 .. 30;
my $orig_key_order;
{
	my (%h, %i);
	ok !rehashed(\%h), "empty hash is not rehashed";
	ok !rehashed(\%i), "other empty hash is not rehashed";
	@h{@pathological} = ();
	ok rehashed(\%h), "after pathological keys, it is";
	$orig_key_order = join ",", keys %h;
}

{
	my $seed = hash_seed;
	#can't think of a better way to test this
	ok looks_like_number($seed), "hash_seed return a number";
	is hash_seed($seed + 1), $seed + 1, "hash_seed returns the new seed";
	is hash_seed, $seed + 1, "the seed changed";
	my %h;
	@h{@pathological} = ();
	isnt join(",", keys %h), $orig_key_order, "keys are sorted differently";
}

done_testing;
