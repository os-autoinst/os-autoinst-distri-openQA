use strict;
use base "openQAcoretest";
use testapi;

sub run {
    if (check_var('VERSION', '13.2')) {
        assert_script_run 'openqa-client isos post ISO=openSUSE-13.2-DVD-x86_64.iso DISTRI=opensuse VERSION=13.2 FLAVOR=DVD ARCH=x86_64 BUILD=0002';
    }
    else {
        # please forgive the hackiness: using the openQA API but parsing the
        # human-readable output of 'client' to get the most recent job
        my $arch = get_var('ARCH');
        my $ttest = 'minimalx';
        my $openqa_url = get_var('OPENQA_HOST_URL', 'https://openqa.opensuse.org');
        my $cmd = <<"EOF";
last_tw_build=\$(openqa-client --host $openqa_url assets get | sed -n 's/^.*name.*Tumbleweed-NET-$arch-Snapshot\\([0-9]\\+\\)-Media.*\$/\\1/p' | sort -n | tail -n 1)
echo "Last Tumbleweed build on openqa.opensuse.org: \$last_tw_build"
job_id=\$(openqa-client --host $openqa_url jobs get version=Tumbleweed scope=relevant arch=$arch build=\$last_tw_build flavor=NET | grep -B $range 'name.*$ttest' | grep -A $range group_id | sed -n 's/^\\s*\\<id.*=> \\([0-9]\\+\\).*\$/\\1/p' | sort -n | tail -n 1)
echo "scenario $arch-$ttest-NET: \$job_id"
sudo -u _openqa-worker touch /var/lib/openqa/factory/iso/.test || (echo "TODO: workaround, _openqa-worker should be able to write factory/iso" && mkdir -p /var/lib/openqa/factory/iso && chmod ugo+rwX /var/lib/openqa/factory/iso)
ls -la /var/lib/openqa/factory/iso
echo "Prevent bsc#1027347"
cd /tmp
sudo -u _openqa-worker /usr/share/openqa/script/clone_job.pl --from $openqa_url \$job_id
EOF
        assert_script_run($_) foreach (split /\n/, $cmd);
    }
    save_screenshot;
    type_string "clear\n";
}

1;
