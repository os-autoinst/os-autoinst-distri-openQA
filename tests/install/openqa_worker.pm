use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

# work around libsvtav1 crashing in the VM without `-svtav1-params lp=…`
# see https://progress.opensuse.org/issues/204756#note-5 and https://gitlab.com/AOMediaCodec/SVT-AV1/-/work_items/2383
use constant DEFAULT_FFMPEG_CMD => 'ffmpeg -y -hide_banner -nostats -r 24 -f image2pipe -vcodec ppm -i - -pix_fmt yuv420p';
use constant SVTAV1_LP1_CMD => DEFAULT_FFMPEG_CMD . ' -c:v libsvtav1 -svtav1-params lp=1 -crf 50 -preset 7 -b:v 0';
use constant ENCODER_SETTINGS => 'EXTERNAL_VIDEO_ENCODER_CMD = ' . SVTAV1_LP1_CMD;

sub run {
    diag('worker setup');
    install_packages('openQA-worker', 3800);
    diag('Login once with fake authentication on openqa webUI to actually create preconfigured API keys for worker authentication');
    assert_script_run('curl --fail-with-body http://localhost/login');
    diag('adding temporary, preconfigured API keys to worker config');
    type_string('cat >> /etc/openqa/client.conf <<EOF
[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
');
    if (get_var('FULL_MM_TEST')) {
        # add tap class to worker config
        my $arch = get_required_var('ARCH');
        my $class = "WORKER_CLASS=qemu_$arch,tap";
        assert_script_run sprintf q{if [ -e /etc/openqa/workers.ini ]; then sed -i -e "s/\(\[global\]\)/\1\n%s/" /etc/openqa/workers.ini; else echo -e "[global]\n%s" > /etc/openqa/workers.ini.d/base.ini; fi}, $class, $class;
    }
    assert_script_run sprintf q{echo -e "[global]\n%s" > /etc/openqa/workers.ini.d/enc.ini}, ENCODER_SETTINGS;
    my $worker_setup = <<'EOF';
systemctl enable --now openqa-worker@1
systemctl status --no-pager openqa-worker@1
EOF
    assert_script_run($_) foreach (split /\n/, $worker_setup);
    assert_script_run "systemctl enable --now openqa-worker@2" if get_var('FULL_MM_TEST');
    assert_script_run('os-autoinst-setup-multi-machine', timeout => 120);
    assert_script_run('systemctl status --no-pager os-autoinst-openvswitch');
    save_screenshot;
    clear_root_console;
}

1;
