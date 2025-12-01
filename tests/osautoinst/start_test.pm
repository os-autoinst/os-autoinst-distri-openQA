use Mojo::Base 'openQAcoretest', -signatures;
use testapi;
use utils;

use constant CLONE_ARGS => 'ASSET_1= ASSET_2= ASSET_256= ASSET_LIBVIRT= ASSET_VIRTUALBOX= ISO=';

sub fetch_job_id($groupid, $ttest, $flavor, $openqa_url) {
    # Stores the job id of the latest $ttest job for the most recent Tumbleweed build with matching architecture in $job_id on the shell on the SUT
    my $arch = get_var('ARCH');
    my $cmd = <<"EOF";
set -o pipefail
zypper -n in jq
resp=\$(OPENQA_CLI_RETRIES=6 OPENQA_CLI_RETRY_FACTOR=2 openqa-cli api --host $openqa_url jobs version=Tumbleweed scope=relevant arch='$arch' flavor=$flavor test='$ttest' groupid=$groupid latest=1)
job_id=\$(echo "\$resp" | jq -r '.jobs | map(select(.result == "passed")) | map(select (.settings.BUILD | match("^[0-9]+\$"))) | max_by(.settings.BUILD) .id')
echo "Job ID: \$job_id"
if [ -z \$job_id  ]; then echo "Unable to find a suitable job to clone from o3. The API query returned: \$resp" && false; fi
echo "Scenario: $arch-$ttest-$flavor: \$job_id"
EOF
    assert_script_run($_, $_ =~ m/openqa-cli/ ? (timeout => 300) : ()) foreach (split /\n/, $cmd);
}

sub full_run {
    # clone the latest "minimalx" job for the most recent Tumbleweed build with matching architecture
    my $openqa_url = get_var('OPENQA_HOST', 'https://openqa.opensuse.org');
    fetch_job_id(1, 'minimalx', 'NET', $openqa_url);
    assert_script_run("retry -r 5 -e -- openqa-clone-job --show-progress --from $openqa_url \$job_id " . CLONE_ARGS, timeout => 300);
}

sub full_run_multimachine {
    # clone the latest "ping_client" MM job for the most recent Tumbleweed build with matching architecture
    my $openqa_url = get_var('OPENQA_HOST', 'https://openqa.opensuse.org');
    fetch_job_id(1, 'ping_client', 'DVD', $openqa_url);
    assert_script_run("retry -r 5 -e -- openqa-clone-job --show-progress --skip-chained-deps --from $openqa_url \$job_id " . CLONE_ARGS, timeout => 600);
}

sub example_run {
    my $arch = get_var('ARCH');
    my $casedir = 'https://github.com/os-autoinst/os-autoinst-distri-example.git';
    my $needlesdir = '%%CASEDIR%%/needles';
    assert_script_run 'wget https://raw.githubusercontent.com/os-autoinst/os-autoinst-distri-example/main/scenario-definitions.yaml';
    assert_script_run "openqa-cli schedule --param-file SCENARIO_DEFINITIONS_YAML=scenario-definitions.yaml DISTRI=example VERSION=0 FLAVOR=DVD ARCH=$arch TEST=simple_boot _GROUP_ID=0 BUILD=test CASEDIR=$casedir NEEDLES_DIR=$needlesdir";

}

sub run {
    if (get_var('FULL_OPENSUSE_TEST')) {
        get_var('FULL_MM_TEST') ? full_run_multimachine : full_run;
    }
    else {
        example_run;
    }
    save_screenshot;
    clear_root_console;
}

sub post_fail_hook ($self) {
    $self->SUPER::post_fail_hook;
    get_log('ss -tlpen' => 'ss-tlpen.txt');
    script_run 'curl -I http://localhost/';
    script_run 'curl -I http://localhost:9526/';
    get_log('systemctl status openqa-webui' => 'systemctl_status_openqa-webui.txt');
    get_log('ausearch -m ALL' => 'audit_log.txt');
}

1;
