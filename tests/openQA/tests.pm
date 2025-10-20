use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

sub visit_test($needle) {
    assert_and_click 'openqa-all-tests';
    send_key_until_needlematch $needle, 'end';
    click_lastmatch;
    assert_screen 'openqa-test-details';
    assert_and_click 'openqa-logo';
    assert_screen 'openqa-dashboard';
}

sub run {
    visit_test 'openqa-scheduled-test';
}

1;
