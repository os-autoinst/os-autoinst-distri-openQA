use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

sub visit_test($needle) {
    unless (get_required_var('VERSION') =~ /(tw|Tumbleweed)/) {
        record_soft_failure 'SKIPPED - module not ready for ' . get_required_var('VERSION');
        return;
    }
    assert_and_click 'openqa-all-tests';
    send_key_until_needlematch $needle, 'end';
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
