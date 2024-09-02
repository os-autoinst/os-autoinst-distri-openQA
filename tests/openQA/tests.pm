use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub run {
    assert_and_click 'openqa-all-tests';
    send_key_until_needlematch 'openqa-scheduled-test', 'down';
    assert_and_click 'openqa-scheduled-test';
    assert_screen 'openqa-test-details';
    assert_and_click 'openqa-all-tests';
}

1;
