#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use LWP::UserAgent;
use JSON::MaybeXS qw(encode_json);
use Data::Dumper;

# base strings -- for now in google docs for speed
my $csv_path =
    'https://docs.google.com/spreadsheets/d/1YBIn97E4D1ikIe3zWeRSMGHe0nLMUaxvUZ1jBb0kkPQ/export?format=csv';
my $csv_data;

my @langs = ( 'en', 'pt', 'fr', 'es' );
my %langs;

### get from google docs
my $ua = LWP::UserAgent->new(
    ssl_opts => { verify_hostname => 0 },
);
$ua->timeout(10);
$ua->env_proxy;

my $response = $ua->get($csv_path);

if ( $response->is_success ) {
    $csv_data = $response->decoded_content;
} else {
    die $response->status_line;
}

### process CSV
for my $line ( split /\n/, $csv_data ) {
    my ( $context, $id, $cmt, $pt, $en, $fr, $es ) = split /,/, $line;
    # TODO: redo this ugly thing
    if ($en) {
        $langs{en}{ $context . "." . $id } = $en;
    }
    if ($pt) {
        $langs{pt}{ $context . "." . $id } = $pt;
    }
    if ($fr) {
        $langs{fr}{ $context . "." . $id } = $fr;
    }
    if ($es) {
        $langs{es}{ $context . "." . $id } = $es;
    }
}

### process JSON
for my $lang (@langs) {
    open my $fh, ">", "lang.$lang.json";
    print $fh encode_json( $langs{$lang} );
    close $fh;
}
