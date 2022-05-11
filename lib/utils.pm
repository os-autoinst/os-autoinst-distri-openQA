package utils;

use base Exporter;
use Exporter;
use strict;
use testapi;
use File::Basename qw(basename);

our @EXPORT = qw(clear_root_console switch_to_x11 wait_for_desktop ensure_unlocked_desktop wait_for_container_log script_retry);

sub clear_root_console {
    enter_cmd('clear');
    assert_screen 'root-console';
}

sub switch_to_x11 {
    my @hdd = split(/-/, basename get_required_var('HDD_1'));
    # older openSUSE Tumbleweed has x11 still on tty7
    my $x11_tty = $hdd[3] < 20190617 ? 'f7' : 'f2';
    send_key "ctrl-alt-$x11_tty";
}

sub wait_for_desktop {
    assert_screen([qw/boot-menu openqa-desktop/]);
    if (match_has_tag('boot-menu')) {
        send_key 'ret';
    }
    assert_screen 'openqa-desktop', 500;
    if (match_has_tag('openqa-desktop-locked')) {
        send_key 'esc';
        wait_still_screen(1);
        type_string $testapi::password . "\n";
        assert_screen 'openqa-desktop';
    }
    elsif (match_has_tag('openqa-desktop-login')) {
        assert_and_click 'openqa-desktop-login';
        wait_still_screen(1);
        type_string $testapi::password . "\n";
        assert_screen 'openqa-desktop';
    }
}


# if stay under tty console for long time, then check
# screen lock is necessary when switch back to x11
# all possible options should be handled within loop to get unlocked desktop
sub ensure_unlocked_desktop {
    my $counter = 10;
    while ($counter--) {
        assert_screen [qw(displaymanager displaymanager-password-prompt generic-desktop screenlock gnome-screenlock-password)], no_wait => 1;
        if (match_has_tag 'displaymanager') {
            if (check_var('DESKTOP', 'minimalx')) {
                type_string "$username";
                save_screenshot;
            }
            send_key 'ret';
        }
        if ((match_has_tag 'displaymanager-password-prompt') || (match_has_tag 'gnome-screenlock-password')) {
            type_password;
            send_key 'ret';
        }
        if (match_has_tag 'generic-desktop') {
            send_key 'esc';
            unless (get_var('DESKTOP', '') =~ m/minimalx|awesome|enlightenment|lxqt|mate/) {
                # gnome might show the old 'generic desktop' screen although that is
                # just a left over in the framebuffer but actually the screen is
                # already locked so we have to try something else to check
                # responsiveness.
                # open run command prompt (if screen isn't locked)
                mouse_hide(1);
                wait_screen_change { send_key 'alt-f2' };
                assert_screen [qw(desktop-runner screenlock)];
                next if match_has_tag 'screenlock';
                send_key 'esc';
                assert_screen 'generic-desktop';
            }
            last;    # desktop is unlocked, mission accomplished
        }
        if (match_has_tag 'screenlock') {
            wait_screen_change {
                send_key 'esc';    # end screenlock
            };
        }
        wait_still_screen 2;                                                                              # slow down loop
        die 'ensure_unlocked_desktop repeated too much. Check for X-server crash.' if ($counter eq 1);    # die loop when generic-desktop not matched
    }
}

# Waits until a text ($text) is found in the container logs.
# Controlled by a timeout (50s)
# Params:
# - $container: The container name or ID
# - $text: The text to search in the logs
# - $cmd: The containers runner (docker, podman,...)
# - $timeout: Time in seconds until this fails
#
sub wait_for_container_log {
    my ($container, $text, $cmd, $timeout) = @_;
    $timeout //= 50;
    while ($timeout > 0) {
        my $output = script_output("$cmd logs $container 2>&1");
        return if ($output =~ /$text/);
        $timeout--;
        sleep 1;
    }
    validate_script_output("$cmd logs $container 2>&1", qr/$text/);
}

=head2 script_retry

 script_retry($cmd, [expect => $expect], [retry => $retry], [delay => $delay], [timeout => $timeout], [die => $die]);

Repeat command until expected result or timeout.

C<$expect> refers to the expected command exit code and defaults to C<0>.

C<$retry> refers to the number of retries and defaults to C<10>.

C<$delay> is the time between retries and defaults to C<30>.

The command must return within C<$timeout> seconds (default: 25).

If the command doesn't return C<$expect> after C<$retry> retries,
this function will die, if C<$die> is set.

Example:

 script_retry('ping -c1 -W1 machine', retry => 5);

=cut
sub script_retry {
    my ($cmd, %args) = @_;
    my $ecode = $args{expect} // 0;
    my $retry = $args{retry} // 10;
    my $delay = $args{delay} // 30;
    my $timeout = $args{timeout} // 30;
    my $die = $args{die} // 1;

    my $ret;

    my $exec = "timeout $timeout $cmd";
    # Exclamation mark needs to be moved before the timeout command, if present
    if (substr($cmd, 0, 1) eq "!") {
        $cmd = substr($cmd, 1);
        $cmd =~ s/^\s+//;    # left trim spaces after the exclamation mark
        $exec = "! timeout $timeout $cmd";
    }
    for (1 .. $retry) {
        # timeout for script_run must be larger than for the 'timeout ...' command
        $ret = script_run($exec, ($timeout + 3));
        last if defined($ret) && $ret == $ecode;

        die("Waiting for Godot: $cmd") if $retry == $_ && $die == 1;
        sleep $delay if ($delay > 0);
    }

    return $ret;
}

1;
