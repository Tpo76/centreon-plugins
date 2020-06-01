#
# Copyright 2020 Centreon (http://www.centreon.com/)
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

package apps::skype4business::local::mode::networkassessment;

use base qw(centreon::plugins::templates::counter);

use strict;
use warnings;


sub set_counters {
    my ($self, %options) = @_;
    
    $self->{maps_counters_type} = [
        { name => 'metrics', type => 0, skipped_code => { -10 => 1 } },
    ];

    $self->{maps_counters}->{metrics} = [
        { label => 'packet-loss', set => {
                key_values => [ { name => 'packet_loss' } ],
				output_template => "PacketLoss: %d %%",
                perfdatas => [
                    { label => 'packet.loss', value => 'packet_loss_absolute', template => '%.2f', 
					min => 0, max => 100, 
					unit => '%' },
                ]
            }
        },
		{ label => 'round-trip-latency', set => {
                key_values => [ { name => 'round_trip_latency' } ],
				output_template => "RoundTripLatency: %d ms",
				perfdatas => [
                    { label => 'round.trip.latency', value => 'round_trip_latency_absolute', template => '%d', 
					min => 0, unit => 'ms' },
                ]
            }
        },
		{ label => 'average-jitter', set => {
                key_values => [ { name => 'average_jitter' } ],
				output_template => "AverageJitter: %d ms",
				perfdatas => [
                    { label => 'average.jitter', value => 'average_jitter_absolute', template => '%.2f', 
					min => 0, unit => 'ms' },
                ]
            }
        },
		{ label => 'packet-reorder-ratio', set => {
                key_values => [ { name => 'packet_reorder_ratio' } ],
				output_template => "PacketReorderRatio: %d ms",
				perfdatas => [
                    { label => 'packet.reorder.ratio', value => 'packet_reorder_ratio_absolute', template => '%d', 
					min => 0 },
                ]
            }
        },
    ];
}

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options, force_new_perfdata => 1);
    bless $self, $class;

    $options{options}->add_options(arguments => {
        'performance-results:s'       => { name => 'performance_results' },
		'language:s'                  => { name => 'language' },
    });

    return $self;
}


sub check_options {
    my ($self, %options) = @_;
	$self->SUPER::check_options(%options);
	
    if (defined($self->{option_results}->{performance_results})) {
        $self->{results_file} = $self->{option_results}->{performance_results};
    } else {
        $self->{output}->add_option_msg(short_msg => "Need to specify performance-results file option.");
        $self->{output}->option_exit();
    }
	
	if (defined($self->{option_results}->{language})) {
	    if ($self->{option_results}->{language} =~ /^(en|fr)$/) {
		    $self->{language} = $self->{option_results}->{language};
	    } else {
		    $self->{output}->add_option_msg(short_msg => "Wrong language option. Could be 'en' or 'fr'");
            $self->{output}->option_exit();
		}
	} else {
        $self->{output}->add_option_msg(short_msg => "Need to specify language option");
        $self->{output}->option_exit();
	}
}

sub manage_selection {
    my ($self, %options) = @_;

    open(FILE, "<$self->{results_file}");
    my @file = <FILE>;
    chomp @file;
    close FILE;
	
	my $packet_loss = 0;
	my $round_trip_latancy = 0;
	my $average_jitter = 0;
	my $packet_reorder= 0;
	#CallStartTime	PacketLossRate	RoundTripLatencyInMs	PacketsSent	PacketsReceived	AverageJitterInMs	PacketReorderRatio
    #18/03/2020 14:51:05	0,00235849056603774	41	848	846	47,4421	0
	if ($self->{language} eq 'fr') {
	    if ($file[-1] =~ /^\d+\/\d+\/\d+\s+\d+:\d+:\d+\s+(.*)\s+(.*)\s+\d+\s+\d+\s+(.*)\s+(\d+)$/) {
	        $packet_loss = $1;
		    $round_trip_latancy = $2;
		    $average_jitter = $3;
		    $packet_reorder = $4;
		    $packet_loss =~ s/,/\./;
		    $average_jitter =~ s/,/\./;
            $round_trip_latancy =~ s/,/./;
		    
	    } else {
	       $self->{output}->add_option_msg(short_msg => "No data available.");
		   $self->{output}->option_exit();
	    }
	#CallStartTime	PacketLossRate	RoundTripLatencyInMs	PacketsSent	PacketsReceived	AverageJitterInMs	PacketReorderRatio
    #3/26/2020 5:14:18 PM	0.00117785630153121	18.5	849	848	9.813673	0
	} elsif ($self->{language} eq 'en') {
	    if ($file[-1] =~ /^\d+\/\d+\/\d+\s+\d+:\d+:\d+\s+\w+\s+(.*)\s+(.*)\s+\d+\s+\d+\s+(.*)\s+(\d+)$/) {
	        $packet_loss = $1;
		    $round_trip_latancy = $2;
		    $average_jitter = $3;
		    $packet_reorder = $4;
		    
	    } else {
	       $self->{output}->add_option_msg(short_msg => "No data available.");
		   $self->{output}->option_exit();
	    }
    }	
    $self->{metrics} = {
        packet_loss => $packet_loss,
        round_trip_latency => $round_trip_latancy,
	    average_jitter => $average_jitter,
		packet_reorder_ratio => $packet_reorder
    };

}

1;

__END__

=head1 MODE

Check alerts.

=over 8

=item B <--performance-results>

Path to 'performance_results.tsv' (required).

=item B <--language>

Language format file (required).
Could be 'en or 'fr'

=item B<--warning-*> B<--critical-*>

Thresholds.
Can be: 'packet-loss', 'round-trip-latancy', 'average-jitter', 'packet-reorder'.

=back

=cut
