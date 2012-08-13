#!/usr/bin/env perl

use warnings;
use strict;

use Data::Dumper;
use FindBin;
use Text::CSV;
use Template;

my $config = {
    INTERPOLATE  => 1,               # expand "$var" in plain text
    POST_CHOMP   => 1,               # cleanup whitespace
    EVAL_PERL    => 1,               # evaluate Perl code blocks
    ABSOLUTE     => 1,
};

# create Template object
my $template = Template->new($config);

my $data_file = "$FindBin::Bin/../data/HMT_03_2008.csv";

my $csv = Text::CSV->new( { sep_char => ',' } );
open( my $data, '<', $data_file ) or die "Could not open '$data_file' $!\n";

my @fields = ("Symbols", "Hazardous materials descriptions and proper shipping names",	
				"Hazard class or Division", "Identification Numbers", "PG", "Label Codes", 
				"Special Provisions (§ 172.102)", { "Packaging" => ["Exceptions", "Non-bulk", "Bulk"]},
				{ "Quantity Limitations (see §§ 173.27 and 175.75)", => ["Passenger aircraft/rail"]},
				{ "Vessel Stowage" => ["Location", "Other"]});
				

my %vars = ( );
$vars{'codes'} = [ ];

while ( my $line = <$data> ) {
    chomp $line;

    if ( $csv->parse($line) ) {

        my @fields = $csv->fields();
		push (@{$vars{'codes'}}, { name => $fields[3], url => "./detail/$fields[3].html" });
		
		my $detail_template = "$FindBin::Bin/../templates/detail.tmpl.html";
		
		my %detail = ( );
		$detail{'code'} = $fields[3];
		$detail{'description'} = $fields[1];
		
		$template->process($detail_template, \%detail, "$FindBin::Bin/../www/detail/$fields[3].html")
		|| die $template->error();
    }
    else {
     #   print "Line could not be parsed: $line, reason $@\n";
    }
}

my $input = "$FindBin::Bin/../templates/index.tmpl.html";

$template->process($input, \%vars, "$FindBin::Bin/../www/index.html")
    || die $template->error();

