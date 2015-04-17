use strict;
use base "openQAcoretest";
use testapi;

sub run {
    assert_and_click 'openqa-running-test';
    assert_screen 'openqa-liveresults', 5;
    send_key 'pgdn';
    assert_screen 'openqa-liveresults-2', 5;
    send_key 'pgdn';
    send_key 'pgdn';
    assert_screen 'openqa-liveresults-3', 5;
    send_key 'pgup';
    send_key 'pgup';
    send_key 'pgup';
    send_key 'pgup';
}

1;
