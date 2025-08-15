use Mojo::Base 'openQAcoretest';
use testapi;

sub run {
    unless (get_required_var('VERSION') =~ /(tw|Tumbleweed)/) {
        record_soft_failure 'SKIPPED - module not ready for ' . get_required_var('VERSION');
        return;
    }
    assert_and_click 'openqa-login';
    assert_screen 'openqa-logged-in';
}

1;
