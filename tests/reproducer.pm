use Mojo::Base 'openQAcoretest';
use testapi;

sub run {
    assert_script_run("/bin/false");
}

sub post_fail_hook {
    force_soft_failure 'this should be only a softfail';
}

1;

