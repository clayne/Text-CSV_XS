#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Text::CSV_XS;

BEGIN {
    if ($] < 5.008002) {
	plan skip_all => "These tests require Encode and Unicode support";
	}
    else {
	require Encode;
	plan tests => 48;
	}
    require "./t/util.pl";
    }

$| = 1;

my $tfn = "_47cmnt.csv"; END { -f $tfn and unlink $tfn; }

foreach my $cstr ("#", "//", "Comment", "\xe2\x98\x83") {
    foreach my $rest ("", " 1,2", "a,b") {

	my $csv = Text::CSV_XS->new ({ binary => 1 });
	   $csv->comment_str ($cstr);

	my $fh;
	open  $fh, ">", $tfn or die "$tfn: $!\n";
	print $fh $cstr, $rest, "\n";
	print $fh "c,$cstr\n";
	print $fh " $cstr\n";
	print $fh "e,$cstr,$rest\n";
	print $fh $cstr, "\n";
	print $fh "g,i$cstr\n";
	print $fh $cstr, "\n";
	close $fh;

	open  $fh, "<", $tfn or die "$tfn: $!\n";

	my $cuni = Encode::decode ("utf-8", $cstr);
	my @rest = split m/,/ => $rest, -1; @rest or push @rest => "";

	is_deeply ($csv->getline ($fh), [ "c", $cuni ],		"$cstr , $rest");
	is_deeply ($csv->getline ($fh), [ " $cuni" ],		"leading space");
	is_deeply ($csv->getline ($fh), [ "e", $cuni, @rest ],	"not start of line");
	is_deeply ($csv->getline ($fh), [ "g", "i$cuni" ],	"not start of field");

	close $fh;

	unlink $tfn;
	}
    }

1;