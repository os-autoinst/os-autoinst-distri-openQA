use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub full_run {
    # clone the latest "minimalx" job for the most recent Tumbleweed build with matching architecture
    my $arch = get_var('ARCH');
    my $ttest = 'minimalx';
    my $openqa_url = get_var('OPENQA_HOST', 'https://openqa.opensuse.org');
    my $cmd = <<"EOF";
set -o pipefail
zypper -n in jq
resp=\$(OPENQA_CLI_RETRIES=5 openqa-cli api --host $openqa_url jobs version=Tumbleweed scope=relevant arch='$arch' flavor=NET test='$ttest' latest=1)
job_id=\$(echo "\$resp" | jq -r '.jobs | max_by(.settings.BUILD) .id')
echo "Job ID: \$job_id"
if [ -z \$job_id  ]; then echo "Unable to find a suitable job to clone from o3. The API query returned: \$resp" && false; fi
echo "Scenario: $arch-$ttest-NET: \$job_id"
EOF
    assert_script_run($_) foreach (split /\n/, $cmd);
    assert_script_run("retry -e -- openqa-clone-job --show-progress --from $openqa_url \$job_id", timeout => 120);
}

sub example_run {
    my $arch = get_var('ARCH');
    my $casedir = 'https://github.com/os-autoinst/os-autoinst-distri-example.git';
    my $needlesdir = '%%CASEDIR%%/needles';
    assert_script_run 'wget https://raw.githubusercontent.com/os-autoinst/os-autoinst-distri-example/main/scenario-definitions.yaml';
    assert_script_run "openqa-cli schedule --param-file SCENARIO_DEFINITIONS_YAML=scenario-definitions.yaml DISTRI=example VERSION=0 FLAVOR=DVD ARCH=$arch TEST=simple_boot _GROUP_ID=0 BUILD=test CASEDIR=$casedir NEEDLES_DIR=$needlesdir";

}

sub run {
    get_var('FULL_OPENSUSE_TEST') ? full_run : example_run;
    save_screenshot;
    clear_root_console;
}

1;
