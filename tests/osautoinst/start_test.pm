use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    # clone the latest "minimalx" job for the most recent Tumbleweed build with matching architecture
    my $arch       = get_var('ARCH');
    my $ttest      = 'minimalx';
    my $openqa_url = get_var('OPENQA_HOST', 'https://openqa.opensuse.org');
    my $cmd        = <<"EOF";
set -o pipefail
zypper -n in jq
resp=\$(OPENQA_CLI_RETRIES=5 openqa-cli api --host $openqa_url jobs version=Tumbleweed scope=relevant arch='$arch' flavor=NET test='$ttest' latest=1)
job_id=\$(echo "\$resp" | jq -r '.jobs | max_by(.settings.BUILD) .id')
echo "Job ID: \$job_id"
if [ -z \$job_id  ]; then echo "Unable to find a suitable job to clone from o3. The API query returned: \$resp" && false; fi
echo "Scenario: $arch-$ttest-NET: \$job_id"
EOF
    assert_script_run($_) foreach (split /\n/, $cmd);
    assert_script_run("retry -- openqa-clone-job --show-progress --from $openqa_url \$job_id", timeout => 120);
    save_screenshot;
    clear_root_console;
}

1;
