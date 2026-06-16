package susedistribution;
use Mojo::Base 'distribution', -signatures;
use File::Basename qw(basename);
use testapi qw(get_required_var check_var);

sub init ($self) {
    $self->SUPER::init();
    $self->add_console('root-console', 'tty-console', {tty => 3});
    my @hdd = split(/-/, basename get_required_var('HDD_1'));
    # older openSUSE Tumbleweed has x11 still on tty7
    # minimalx has x11 on tty7
    $self->add_console('x11', 'tty-console', {tty => ($hdd[3] < 20190617 or check_var('DESKTOP', 'minimalx')) ? 7 : 2});
}

1;
