from testapi import *


def run(self):
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


def post_fail_hook(self):
    select_console('root-console')
    assert_script_run('openqa-cli api experimental/search q=shutdown.pm')


def test_flags(self):
    return {'fatal': 1}
