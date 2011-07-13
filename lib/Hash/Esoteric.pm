package Hash::Esoteric;

use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw/keys_by_collisions keys_by_bucket/;
our @EXPORT;

our $VERSION = '0.01';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&Hash::Esoteric::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	*$AUTOLOAD = sub { $val };
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('Hash::Esoteric', $VERSION);

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 Hash::Esoteric

Hash::Esoteric - Perl extension for to provide esoteric information about hashes

=head1 SYNOPSIS

  use Hash::Esoteric qw/keys_by_collisions keys_by_buckets/;

  my %h = map { $_ => undef } "a" .. "j";

  my $href = keys_by_collisions \%h;

  for my $number_of_keys (sort { $a <=> $b } keys %$href) {
      print "these keys were in buckets that held $number_of_keys keys:\n";
      for my $key (@{$href->{$number_of_keys}}) {
          print "\t$key\n";
      }
  }

  my $aref = keys_by_bucket \%h;

  for my $bucket (0 .. $#$aref) {
      print "bucket $bucket holds\n";
      for my $key (@{$aref->[$bucket]}) {
          print "\t$key\n";
      }
  } 

=head1 DESCRIPTION

This module provides two ways of looking at the internals of
how a hash is storing data.  It may be useful in determining
if a hash is having efficiency problems.

Proper use of this module requires a basic understanding of
how hash tables work.

=head1 FUNCTIONS

=head2 my $href = keys_by_collisions(\%hash)

This function returns a hashref.  The key to the hashref is the
number of keys in a bucket and the value is an arrayref that holds
all of the keys that were in a bucket with that number keys.

The previous sentence may make no sense, but hopefully an example
will make things clearer.  Let's say that we have a hash with five
buckets.  In the first bucket we have the keys "a" and "b", in the
second bucket we have nothing, in the third bucket we have the keys
"c" and "d", in the fourth bucket we have the keys "e", "f", "g",
and in the fifth bucket we have no keys. In this case, the function
will return the following hashref:

  my $href = {
      2 => [ "a", "b", "c", "d" ],
      3 => [ "e", "f", "g" ],
  };

=head2 my $aref = keys_by_bucket(\%hash)

This function returns an arrayref that holds one arrayref per bucket
in the hash.  These arrayrefs hold the keys that are in the 
corresponding bucket.

The previous section may make no sense, but hopefully an example
will make things clearer.  Let's say that we have a hash with five
buckets.  In the first bucket we have the keys "a" and "b", in the
second bucket we have nothing, in the third bucket we have the keys
"c" and "d", in the fourth bucket we have the keys "e", "f", "g",
and in the fifth bucket we have no keys. In this case, the function
will return the following arrayref:

  my $aref = [
      ["a", "b"],
      [],
      ["c", "d"],
      ["e", "f", "g"],
      [],
  ];


=head1 AUTHOR

Chas. Owens, E<lt>chas.owens@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Chas. Owens

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
