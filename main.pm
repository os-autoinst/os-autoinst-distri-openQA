#!/usr/bin/perl -w
use Mojo::Base -strict, -signatures;
use testapi;
use autotest;
use needle;

my $distri = testapi::get_var('CASEDIR') . '/lib/susedistribution.pm';
require $distri;
testapi::set_distribution(susedistribution->new());

$testapi::password //= get_var('PASSWORD');
$testapi::password //= 'nots3cr3t';

sub loadtest ($test) {
    my $filename = $test =~ /\.p[my]$/ ? $test : $test . '.pm';
    autotest::loadtest("tests/$filename");
}

loadtest 'install/boot';
loadtest 'install/prepare';
loadtest 'reproducer';

1;
