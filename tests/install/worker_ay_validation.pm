use Mojo::Base 'openQAcoretest';
use File::Basename;
use testapi;
use utils;

sub run {
    switch_to_root_console;
    my $profile = '/root/result.xml';
    install_packages('autoyast2 libxml2-tools');
    my $template_path = get_required_var('AUTOYAST');
    my $profile_template = basename($template_path);
    assert_script_run "wget $template_path";
    # run-scripts=true is not used because the salt-minion is not installed in the VM
    enter_cmd "yast2 autoyast check-profile filename=$profile_template output=$profile run-erb=true";
    assert_screen "check-autoyast-profile-ok", timeout => 300;
    clear_root_console;
    assert_script_run "xmllint $profile", fail_message => "generated profile '$profile' does not pass validation";
    upload_logs $profile;
    clear_root_console;
}

1;
