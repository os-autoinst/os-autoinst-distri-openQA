use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

sub visit_test($needle) {
    assert_and_click 'openqa-all-tests';
    send_key_until_needlematch $needle, 'down';
    assert_and_click $needle;
    assert_screen 'openqa-test-details';
    assert_and_click 'openqa-logo';
}

sub run {
    visit_test 'openqa-scheduled-test';
    visit_test 'openqa-scheduled-test-ping-client' if get_var('FULL_MM_TEST');
    assert_screen 'openqa-dashboard';
}

1;
