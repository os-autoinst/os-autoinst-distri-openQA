use Mojo::Base 'openQAcoretest';
use testapi;

sub run {
    assert_and_click 'openqa-login';
    assert_screen 'openqa-logged-in';
}

1;
