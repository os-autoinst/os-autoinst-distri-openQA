from testapi import *


def run(self):
    if not get_required_var('VERSION') in ['tw', 'Tumbleweed']:
        record_soft_failure('SKIPPED - module not ready for ' + get_required_var('VERSION'))
        return

    assert_screen('openqa-logged-in')
    assert_and_click('openqa-search')
    for i in range(3):
        # ensure that searchbar is selected
        if check_screen('openqa-search-selected'):
            break
        assert_and_click('openqa-search')
    type_string('shutdown.pm')
    send_key('ret')
    assert_screen('openqa-search-results')


def switch_to_root_console():
    send_key('ctrl-alt-f3')


def post_fail_hook(self):
    switch_to_root_console()
    assert_script_run('openqa-cli api experimental/search q=shutdown.pm')


def test_flags(self):
    return {'fatal': 1}
