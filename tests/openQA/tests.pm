use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

sub visit_test($needle) {
    assert_and_click 'openqa-all-tests';
    send_key_until_needlematch $needle, 'down';
    click_lastmatch;
    assert_screen 'openqa-test-details';
    assert_and_click 'openqa-logo';
    assert_screen 'openqa-dashboard';
}

sub run {
    visit_test 'openqa-scheduled-test';
    visit_test 'openqa-scheduled-test-ping-client' if get_var('FULL_MM_TEST');
}

1;
