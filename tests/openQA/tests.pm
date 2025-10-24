use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

use constant TRIES => 3;

sub visit_test($needle) {
    assert_and_click 'openqa-all-tests';
    send_key_until_needlematch $needle, 'end';
    # in case of "full openSUSE test" the test is likely still running.
    # Because the content on the /tests page can move around if rendering has
    # not yet completed we need to be more creative
    wait_screen_change { assert_and_click $needle };
    for (1 .. TRIES) {
        die "Failed to find openQA test details after multiple retries" if $_ == TRIES;
        assert_screen [$needle, 'openqa-test-details'];
        last if match_has_tag 'openqa-test-details';
        click_lastmatch;
    }
    assert_and_click 'openqa-logo';
    assert_screen 'openqa-dashboard';
}

sub run {
    visit_test 'openqa-scheduled-test';
}

1;
