#!/usr/bin/perl -w
use strict;
use testapi;
use autotest;
use needle;
use File::Find;

my $distri = testapi::get_var("CASEDIR") . '/lib/susedistribution.pm';
require $distri;
testapi::set_distribution(susedistribution->new());

$testapi::password //= get_var("PASSWORD");
$testapi::password //= 'nots3cr3t';

sub loadtest($) {
    my ($test) = @_;
    autotest::loadtest("/tests/$test");
}

# subs for test types
sub load_update_tests() {
    loadtest "update/zypper_up.pm";
    loadtest "update/reboot.pm";
}

sub load_install_tests() {
    loadtest "install/boot.pm";
    loadtest "install/openqa_webui.pm";
    # for now when testing from git only tests the webui itself, not worker
    # interaction
    return 1 if check_var('OPENQA_FROM_GIT', 1);
    loadtest "install/openqa_worker.pm";
    loadtest "install/test_distribution.pm";
}

sub load_osautoinst_tests() {
    loadtest "osautoinst/worker.pm";
    loadtest "osautoinst/start_test.pm";
    loadtest "osautoinst/test_running.pm";
}

sub load_openQA_tests() {
    loadtest "openQA/dashboard.pm";
    loadtest "openQA/login.pm";
    return 1 if get_var('INSTALL_ONLY');
    loadtest "openQA/build_results.pm";
    loadtest "openQA/test_live.pm";
    loadtest "openQA/test_results.pm";
    loadtest "openQA/tests.pm";
    loadtest "openQA/admin.pm";
}

sub load_shutdown() {
    loadtest "shutdown/shutdown.pm";
}

# load tests in the right order
if (get_var('UPDATE')) {
    load_update_tests();
}
elsif (get_var('INSTALL')) {
    load_install_tests();
}
# testing from git only tests webui so far
load_osautoinst_tests() unless check_var('OPENQA_FROM_GIT', 1);
load_openQA_tests();
load_shutdown();

1;
