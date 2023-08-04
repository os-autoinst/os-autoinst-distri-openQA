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
    autotest::loadtest("/tests/$filename");
}

sub load_install_tests() {
    loadtest 'install/boot';
    loadtest 'install/openqa_webui';
    # for now when testing from git only tests the webui itself, not worker
    # interaction
    return 1 if get_var('OPENQA_FROM_GIT');
    loadtest 'install/openqa_worker' unless get_var('OPENQA_FROM_BOOTSTRAP');
    loadtest 'install/test_distribution';
}

sub load_multi_machine_tests() {
    loadtest 'install/multi_machine.py';
}

sub load_osautoinst_tests() {
    loadtest 'osautoinst/worker';
    loadtest 'osautoinst/start_test';
    loadtest 'osautoinst/test_running';
}

sub load_openQA_tests() {
    if (get_var('OPENQA_CONTAINERS')) {
      loadtest 'containers/build';
      loadtest 'containers/setup_env';
      loadtest 'containers/multiple_container_webui';
      loadtest 'containers/single_container_webui';
      loadtest 'containers/worker';
    }
    else {
      loadtest 'openQA/dashboard';
      loadtest 'openQA/login';
    }
}

sub load_python_tests() {
    loadtest 'openQA/search.py';
}

sub load_shutdown() {
    loadtest 'shutdown/shutdown';
}

# load tests in the right order
load_install_tests();
load_multi_machine_tests() if get_var('WITH_MULTI_MACHINE');
# testing from git only tests webui so far
load_osautoinst_tests() unless get_var('OPENQA_FROM_GIT');
load_openQA_tests();
load_python_tests() if get_var('LOAD_PYTHON_TEST_MODULES', 1);
load_shutdown();

1;
