use Mojo::Base 'openQAcoretest';
use testapi;

sub run {
    assert_screen [qw(openqa-logged-in openqa-login)];
    return undef if match_has_tag 'openqa-logged-in';
    click_lastmatch;
    assert_screen 'openqa-logged-in';
}

1;
