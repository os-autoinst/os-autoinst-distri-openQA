use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

use OpenQA::Wheel::Launcher 'start_gui_program';

sub run {
    prepare_firefox_autoconfig;
    switch_to_x11;
    ensure_unlocked_desktop();
    start_gui_program('firefox http://localhost', 60, valid => 1);
    assert_screen 'openqa-dashboard', 60;
    start_gui_program('firefox http://127.0.0.1', 60, valid => 1);
    assert_screen 'openqa-dashboard', 60;
    start_gui_program('firefox http://[::1]', 60, valid => 1);
    assert_screen 'openqa-dashboard', 60;
}
1;
