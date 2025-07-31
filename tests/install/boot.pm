use Mojo::Base 'openQAcoretest';
use testapi;
use utils;

sub run {
    if (get_required_var('VERSION') =~ /(tw|Tumbleweed)/) {
	wait_for_desktop;
    } else {
	wait_to_boot;
    }
}

1;

