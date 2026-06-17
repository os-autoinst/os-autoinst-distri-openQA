use Mojo::Base 'openQAcoretest', -signatures;
use Mojo::File qw(path);
use testapi;

# Summary: Run and Verify workers' confinement
# First stage runs operations on the SUT
# - Read the shadow password file
# - Read sudoers configuration
# - exposes secrets passed at boot
# - various operations
#
# Second stage runs host-level operations
# - write to host /etc.
# - write to the worker's own home directory.
# - verify the cache directory is readable. ReadOnlyPaths must include it for the cache service to work
# - try to write to the cache directory. should be blocked when ReadOnlyPaths is active
# - verify this worker slot cannot read another slot's pool directory
# - can we read a sensitive host file from Perl?
# - can we read another process /proc/<pid>/environ on the host? 

sub run ($self) {
    # select_console 'root-console';
    send_key('ctrl-alt-f3');
    record_info('VM-level', 'exercise API commands inside VM');
    record_info('id', script_run 'id');
    record_info('whoami', script_run 'whoami');

    script_run 'cat /etc/shadow';
    upload_logs '/etc/shadow', failok => 1;

    script_run 'cat /etc/sudoers';
    upload_logs '/etc/sudoers', failok => 1;

    script_run 'cat /proc/1/environ | tr "\\0" "\\n"';
    script_run 'systemctl list-units --all --no-pager';
    script_run 'systemctl list-unit-files --no-pager';
    script_run 'systemctl list-timers --no-pager';

    # various operations
    script_run 'mkdir -p /etc/systemd/system/sshd.service.d';
    script_run q{echo -e '[Service]\n# worker-confinement-probe' > /etc/systemd/system/sshd.service.d/probe.conf};
    script_run 'cat /etc/systemd/system/sshd.service.d/probe.conf';
    script_run 'systemctl daemon-reload';
    script_run 'rm -rf /etc/systemd/system/sshd.service.d';
    script_run 'systemctl daemon-reload';
    script_run 'for u in $(cut -d: -f1 /etc/passwd); do crontab -u "$u" -l 2>/dev/null && echo "--- $u ---"; done';
    save_screenshot;

    record_info('Host-level operations', 'exercise access to the host with system()');
    # Without hardening they succeed — demonstrating the attack.
    #   "Read-only file system" → EROFS  = systemd namespace enforcing the restriction
    #   "Permission denied"     → EACCES = only DAC, systemd hardening NOT active
    my $classified_errors = sub {
        my ($err) = @_;
        return 'EROFS (systemd-confined)'  if $err =~ /Read-only file system/;
        return 'EACCES (DAC-only, not confined)' if $err =~ /Permission denied/;
        return "other: $err";
    };

    # Both confined and unconfined fail here, but for different reasons — the
    # error message is the proof: EROFS means ProtectSystem=strict is active.
    system('mkdir -p /etc/systemd/system/worker-probe.d 2>/tmp/probe-etc-err');
    if (my $etc_err = path('/tmp/probe-etc-err')->slurp =~ s/\n+$//r) {
        record_info('ETC-WRITE', $classified_errors->($etc_err));
        system('rmdir /etc/systemd/system/worker-probe.d 2>/dev/null');
    }
    else {
        record_info('ETC-WRITE', 'UNCONFINED: wrote to host /etc/systemd/system/', result=>'fail');
        system('rmdir /etc/systemd/system/worker-probe.d');
    }

    my $probe_file = $ENV{HOME} . '/.worker-probe-test';
    system(qq{touch '$probe_file' 2>/tmp/probe-home-err});
    if (my $home_err = path('/tmp/probe-home-err')->slurp =~ s/\n+$//r) {
        record_info('HOME-WRITE', $classified_errors->($home_err));
    }
    else {
        record_info('HOME-WRITE', 'UNCONFINED: wrote to host $HOME directly', result => 'fail');
        unlink $probe_file;
    }

    my $cachedir = $ENV{OPENQA_BASEDIR} . '/openqa/cache';
    if (opendir my $cache_dh, $cachedir) {
        closedir $cache_dh;
        record_info('CACHE-ACCESS', "Cache directory accessible: $cachedir", result => 'softfail');
    }
    else {
        record_info('CACHE-ACCESS', "Cache directory not accessible ($!): $cachedir");
    }

    my $cache_probe = "$cachedir/.worker-write-probe";
    system(qq{touch '$cache_probe' 2>/tmp/probe-cache-write-err});
    if (my $cachedir_err = path('/tmp/probe-cache-write-err')->slurp =~ s/\n+$//r) {
        record_info('CACHE-WRITE', $classified_errors->($cachedir_err));
    }
    else {
        record_info('CACHE-WRITE', "UNCONFINED: worker can write to cache directory $cachedir", result => 'fail');
        unlink $cache_probe;
    }

    my $poolbase = $ENV{OPENQA_BASEDIR} . '/openqa/pool';
    my $mypool   = $ENV{OPENQA_POOLDIR} // '';
    if (opendir my $pool_dh, $poolbase) {
        my @siblings = grep { /^\d+$/ && "$poolbase/$_" ne $mypool } readdir $pool_dh;
        closedir $pool_dh;
        if (@siblings) {
            if (my $accessible = grep { my $sdh; opendir $sdh, "$poolbase/$_" } @siblings) {
                record_info('SLOT-ISOLATION', "UNCONFINED: can read $accessible sibling pool dir(s) under $poolbase", result => 'fail');
            }
            else {
                record_info('SLOT-ISOLATION', "Sibling pool directories not readable (confined)");
            }

            # try to write to the first sibling pool directory
            my $sibling = "$poolbase/$siblings[0]";
            my $pool_probe = "$sibling/.worker-write-probe";
            system(qq{touch '$pool_probe' 2>/tmp/probe-pool-write-err});
            if (my $pooldir_err = path('/tmp/probe-pool-write-err')->slurp =~ s/\n+$//r) {
                record_info('POOL-ISOLATION', $classified_errors->($pooldir_err) . " (cannot write to $sibling)");
            }
            else {
                record_info('POOL-ISOLATION', "UNCONFINED: worker can write to sibling pool $sibling", result => 'fail');
                unlink $pool_probe;
            }
        }
        else {
            record_info('SLOT-ISOLATION', "No sibling pool directories found under $poolbase — cannot test isolation");
        }
    }
    else {
        record_info('SLOT-ISOLATION', "Cannot open pool base $poolbase: $!", result => 'fail');
    }

    if (open my $fh, '<', '/etc/shadow') {
        my $fline = <$fh>;
        record_info('SHADOW-READABLE', "UNCONFINED: worker Perl read host /etc/shadow: $fline", result => 'fail');
    }
    else {
        record_info('SHADOW-BLOCKED', "host /etc/shadow not readable from worker Perl: $!");
    }

    opendir(my $dh, '/proc') or die "cannot open /proc: $!";
    my @pids = grep { /^\d+$/ } readdir($dh);
    closedir($dh);
    my $visible = grep { -r "/proc/$_/environ" } @pids;
    record_info('PROC-VISIBILITY', "Worker Perl can read environ of $visible / " . scalar(@pids) . " host PIDs", result => 'fail');

}

sub test_flags ($self) {
    return {fatal => 0};
}

1;
