package utils;

use Mojo::Base 'Exporter', -signatures;
use Exporter;
use testapi;
use File::Basename qw(basename);

our @EXPORT = qw(get_log install_packages clear_root_console switch_to_root_console switch_to_x11 wait_for_desktop login ensure_unlocked_desktop wait_for_container_log prepare_firefox_autoconfig disable_packagekit);

sub get_log ($cmd, $name) {
    my $ret = script_run "$cmd | tee $name";
    upload_logs($name) unless $ret;
}

sub install_packages($packages, $timeout = undef) {
    $timeout //= 4000; # The maximum of the retry is 3810 seconds
    assert_script_run(qq{retry -e -s 30 -r 7 -- sh -c "zypper -n --gpg-auto-import-keys ref && zypper --no-cd -n in $packages"}, $timeout);
}

sub clear_root_console {
    enter_cmd 'clear';
    enter_cmd 'cd';
    assert_screen 'root-console';
}

sub switch_to_root_console {
    send_key 'ctrl-alt-f3';
}

sub switch_to_x11 {
    my @hdd = split(/-/, basename get_required_var('HDD_1'));
    # older openSUSE Tumbleweed has x11 still on tty7
    # minimalx has x11 on tty7
    my $x11_tty = ($hdd[3] < 20190617 or check_var('DESKTOP', 'minimalx')) ? 'f7' : 'f2';
    send_key "ctrl-alt-$x11_tty";
}

sub handle_gui_password {
    assert_screen 'lockscreen-password-prompt';
    type_password;
    assert_screen 'lockscreen-typed-password';
    send_key 'ret';
}

sub wait_for_desktop {
    assert_screen([qw/boot-menu openqa-desktop/]);
    send_key 'ret' if match_has_tag('boot-menu');
    assert_screen 'openqa-desktop', 500;
    return if match_has_tag('generic-desktop');
    if (match_has_tag('openqa-desktop-locked')) {
        send_key 'esc';
    }
    elsif (match_has_tag('openqa-desktop-login')) {
        assert_and_click 'openqa-desktop-login';
    }
    handle_gui_password;
    assert_screen 'generic-desktop';
}

sub login {
    switch_to_root_console;
    assert_screen 'inst-console';
    type_string "root\n";
    assert_screen 'password-prompt';
    type_password;
    send_key 'ret';
    wait_still_screen(2);
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
sub wait_for_container_log ($container, $text, $cmd, $timeout = undef) {
    $timeout //= 50;
    while ($timeout > 0) {
        my $output = script_output("$cmd logs $container 2>&1");
        return if ($output =~ /$text/);
        $timeout--;
        sleep 1;
    }
    validate_script_output("$cmd logs $container 2>&1", qr/$text/);
}

# Use AutoConfig file for firefox to predefine some user values
# https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
sub prepare_firefox_autoconfig {
    # Enable AutoConfig by pointing to a cfg file
    type_string(q{cat <<EOF > $(rpm --eval %_libdir)/firefox/defaults/pref/autoconfig.js
pref("general.config.filename", "firefox.cfg");
pref("general.config.obscure_value", 0);
EOF
});
    # Create AutoConfig cfg file
    type_string(q{cat <<EOF > $(rpm --eval %_libdir)/firefox/firefox.cfg
// Mandatory comment
// https://firefox-source-docs.mozilla.org/browser/components/newtab/content-src/asrouter/docs/first-run.html
pref("app.normandy.enabled", false);
pref("browser.aboutwelcome.enabled", false);
pref("browser.discovery.enabled", false);
pref("browser.messaging-system.whatsNewPanel.enabled", false);
pref("browser.startup.upgradeDialog.enabled", false);
pref("browser.uitour.enabled", false);
pref("datareporting.policy.firstRunURL", "");
pref("messaging-system.rsexperimentloader.enabled", false);
pref("privacy.restrict3rdpartystorage.rollout.enabledByDefault", false);
pref("trailhead.firstrun.branches", "nofirstrun-empty");
// More modal dialogs as of 2024-08 https://bugzilla.mozilla.org/show_bug.cgi?id=1904102#c11
pref("browser.newtabpage.activity-stream.discoverystream.topicSelection.onboarding.enabled", false);
pref("browser.newtabpage.activity-stream.discoverystream.topicSelection.onboarding.maybeDisplay", false);
// AI Chatbot
pref("browser.ml.chat.enabled", false);
pref("browser.ml.chat.shortcuts", false);
pref("browser.ml.enable", false);
EOF
});
}

sub disable_packagekit {
    diag('Ensure packagekit is not interfering with zypper calls');
    assert_script_run 'systemctl mask --now packagekit';
    assert_script_run 'sudo -u bernhard gsettings set org.gnome.software download-updates false' if get_var('DESKTOP', 'gnome') eq 'gnome';
}

1;
