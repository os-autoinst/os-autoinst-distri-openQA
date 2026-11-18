package susedistribution;
use Mojo::Base 'distribution', -signatures;
use File::Basename qw(basename);
use autotest;
use testapi qw(get_required_var check_var assert_screen);
use utils qw(ensure_unlocked_desktop);

sub init ($self) {
    $self->SUPER::init();
    $self->add_console('root-console', 'tty-console', {tty => 3});
    my @hdd = split(/-/, basename get_required_var('HDD_1'));
    # older openSUSE Tumbleweed has x11 still on tty7
    # minimalx has x11 on tty7
    $self->add_console('x11', 'tty-console', {tty => ($hdd[3] < 20190617 or check_var('DESKTOP', 'minimalx')) ? 7 : 2});
}

sub activate_console ($self, $console, %args) {  # override to allow passing %args (even if only used in console_selected)
    $self->SUPER::console_selected($console);
}

sub console_selected ($self, $console, %args) {
    $self->SUPER::console_selected($console);
    $args{await_console} //= 1;
    $args{tags} //= $console;
    $args{timeout} //= 30;
    return if !$args{await_console} || ($autotest::current_test && $autotest::current_test->{post_fail_hook_running});
    return ensure_unlocked_desktop if $args{tags} =~ /x11/;
    assert_screen($args{tags}, no_wait => 1, timeout => $args{timeout});
}

1;
