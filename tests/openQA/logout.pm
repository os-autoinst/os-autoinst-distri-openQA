use strict;
use base "openQAcoretest";
use testapi;

sub run {
	assert_and_click 'openqa-logged-in';
    	assert_and_click 'openqa-logout';
    	assert_screen 'openqa-login';
}

1;
