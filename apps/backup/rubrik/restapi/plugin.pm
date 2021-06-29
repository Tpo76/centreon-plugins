#
# Copyright 2021 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package apps::backup::rubrik::restapi::plugin;

use strict;
use warnings;
use base qw(centreon::plugins::script_custom);

sub new {
    my ( $class, %options ) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;

    $self->{version} = '0.1';
    $self->{modes} = {
        'cluster'        => 'apps::backup::rubrik::restapi::mode::cluster',
        'compliance'     => 'apps::backup::rubrik::restapi::mode::compliance',
        'disks'          => 'apps::backup::rubrik::restapi::mode::disks',
        'nodes'          => 'apps::backup::rubrik::restapi::mode::nodes',
        'storage'        => 'apps::backup::rubrik::restapi::mode::storage',
        'tasks'          => 'apps::backup::rubrik::restapi::mode::tasks'
    };

    $self->{custom_modes}->{api} = 'apps::backup::rubrik::restapi::custom::api';
    return $self;
}

1;

__END__

=head1 PLUGIN DESCRIPTION

Check Rubrik using Rest API.

=cut
