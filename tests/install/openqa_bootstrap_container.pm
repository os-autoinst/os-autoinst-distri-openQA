use strict;
use base "openQAcoretest";
use testapi;
use utils;


sub run {
    send_key "ctrl-alt-f2";
    assert_screen "inst-console";
    type_string "root\n";
    assert_screen "password-prompt";
    type_string $testapi::password . "\n";
    wait_still_screen(2);
    diag('Ensure packagekit is not interfering with zypper calls');
    script_run('systemctl stop packagekit.service; systemctl mask packagekit.service');

	if (script_run('stat /dev/kvm') != 0) {
		record_info('No nested virt', 'Creating dummy /dev/kvm');
		assert_script_run('mknod /dev/kvm c 10 232');
	}

	assert_script_run('zypper -n in openQA-bootstrap');
	assert_script_run('/usr/share/openqa/script/openqa-bootstrap-container', 1600);

	assert_screen('openqa-container-created');
    save_screenshot;
    type_string "clear\n";
}

1;
