use Mojo::Base 'openQAcoretest', -signatures;
use testapi;

sub run ($self) {
    select_console 'root-console';
    assert_screen 'root-console';
    enter_cmd 'poweroff';
    assert_shutdown 300;
}

sub post_fail_hook ($self) {
    # in case plymouth splash screen on shutdown hides some messages
    send_key 'esc' if check_screen 'plymouth';
    $self->SUPER::post_fail_hook;
}

1;
