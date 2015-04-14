package openQAcoretest;
use base "basetest";

# All steps belonging to core openQA functionality are 'fatal'.

sub test_flags() {
    return { 'fatal' => 1 };
}

1;
# vim: set sw=4 et:
