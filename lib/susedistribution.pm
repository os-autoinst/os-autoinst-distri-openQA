package susedistribution;
use base 'distribution';

# Base class for all test modules

use testapi qw(send_key %cmd assert_screen check_screen check_var get_var save_screenshot type_password type_string wait_idle wait_serial mouse_hide);

sub init {
    my ($self) = @_;

    $self->SUPER::init();
}

sub x11_start_program {
    my ($self, $program, $timeout, $options) = @_;
    send_key 'alt-f2';
    mouse_hide(1);
    assert_screen('desktop-runner', $timeout);
    type_string $program;
    if ($options->{terminal}) {
        wait_screen_change { send_key 'alt-t' };
    }
    save_screenshot;
    send_key 'ret';
    # make sure desktop runner executed and closed when have had valid value
    # exec x11_start_program( $program, $timeout, { valid => 1 } );
    if ($options->{valid}) {
        foreach my $i (1 .. 3) {
            last unless check_screen 'desktop-runner-border', 2;
            send_key 'ret';
        }
    }
}

# this needs to move to the distribution
sub ensure_installed {
    my ($self, @pkglist) = @_;
    my $timeout;
    if ($pkglist[-1] =~ /^[0-9]+$/) {
        $timeout = $pkglist[-1];
        pop @pkglist;
    }
    else {
        $timeout = 80;
    }

    testapi::x11_start_program("xterm");
    assert_screen('xterm-started');
    type_string("pkcon install @pkglist\n");
    my @tags = qw/Policykit Policykit-behind-window PolicyKit-retry pkcon-proceed-prompt pkcon-succeeded/;
    while (1) {
        my $ret = assert_screen(\@tags, $timeout);
        if ($ret->{needle}->has_tag('Policykit') ||
            $ret->{needle}->has_tag('PolicyKit-retry')) {
            type_password;
            send_key("ret", 1);
            @tags = grep { $_ ne 'Policykit' } @tags;
            @tags = grep { $_ ne 'Policykit-behind-window' } @tags;
            if ($ret->{needle}->has_tag('PolicyKit-retry')) {
                # Only a single retry is acceptable
                @tags = grep { $_ ne 'PolicyKit-retry' } @tags;
            }
            next;
        }
        if ($ret->{needle}->has_tag('Policykit-behind-window')) {
            send_key("alt-tab");
            sleep 3;
            next;
        }
        if ($ret->{needle}->has_tag('pkcon-proceed-prompt')) {
            send_key("y");
            send_key("ret");
            @tags = grep { $_ ne 'pkcon-proceed-prompt' } @tags;
            next;
        }
        if ($ret->{needle}->has_tag('pkcon-succeeded')) {
            send_key("alt-f4");    # close xterm
            return;
        }
    }

    if ($password) { type_password; send_key("ret", 1); }
    wait_still_screen(7, 90);      # wait for install
}

sub script_sudo {
    my ($self, $prog, $wait) = @_;

    type_string "clear\n";
    type_string "su -c '$prog'\n";
    if (!get_var("LIVETEST")) {
        assert_screen 'password-prompt';
        type_password;
        send_key "ret";
    }
    wait_idle $wait;
}

sub become_root {
    my ($self) = @_;

    $self->script_sudo('bash', 1);
    type_string "whoami > /dev/$testapi::serialdev\n";
    wait_serial("root", 2) || die "Root prompt not there";
    type_string "cd /tmp\n";
    type_string "clear\n";
}

1;
