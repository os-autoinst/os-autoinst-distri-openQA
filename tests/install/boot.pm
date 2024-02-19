use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

use OpenQA::Wheel::Launcher 'start_gui_program';

sub _prevent_inactivity_timeout { start_gui_program('xset s off -dpms', undef, valid => 1) }

sub run {
    wait_for_desktop;
    _prevent_inactivity_timeout;
}

1;

