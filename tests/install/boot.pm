use Mojo::Base 'openQAcoretest';
use utils;
use testapi;

sub run {
    record_info "Lets boot";
    wait_for_desktop;
}

1;

