use strict;
use base 'openQAcoretest';
use testapi;

sub run {
    assert_and_click 'openqa-home';
    assert_screen 'openqa-dashboard';
    # since the build image is very old all results already disappeared from
    # the dashboard. As there is no link to all test results in this old
    # version we have to workaround this by explicitly selecting the '/tests'
    # subroute
    send_key 'f6';
    send_key 'right';
    type_string "/tests\n";
    assert_and_click 'openqa-tests-build0001';
    assert_screen 'openqa-buildresults';
    assert_and_click 'openqa-passed-test';
    assert_screen 'openqa-testresults';
    assert_and_click 'openqa-needle';
    assert_screen 'openqa-screenshot';
    assert_and_click 'openqa-needle-editor';
    assert_screen 'openqa-needle-editor-screen';
    assert_and_click 'openqa-source-code';
    assert_screen 'openqa-source-screen';
}

1;
