package susedistribution;
use base 'distribution';

# Base class for all test modules

use testapi qw(send_key assert_screen check_screen save_screenshot type_string mouse_hide);

1;
