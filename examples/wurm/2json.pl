#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use LWP::UserAgent;
use JSON::MaybeXS qw(encode_json);
use XML::Writer;

use Data::Dumper;

# base strings -- for now in google docs for speed
my $csv_path =
    'https://docs.google.com/spreadsheets/d/1YBIn97E4D1ikIe3zWeRSMGHe0nLMUaxvUZ1jBb0kkPQ/export?format=csv';
my $csv_data;

my @langs = ( 'en', 'pt', 'fr', 'es' );
my %langs;

### get from google docs
my $ua = LWP::UserAgent->new(
    ssl_opts => { verify_hostname => 0 },    # ¯\_(ツ)_/¯
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
mkdir "JSON";
for my $lang (@langs) {
    open my $fh, ">", "JSON/lang.$lang.json";
    print $fh encode_json( $langs{$lang} );
    close $fh;
}

### process Android
mkdir "ANDROID";
mkdir "ANDROID/res";
for my $lang (@langs) {
    mkdir "ANDROID/res/values-$lang";

    my $output = new IO::File(">ANDROID/res/values-$lang/strings.xml");

    my $writer = new XML::Writer(
        NAMESPACES  => 'utf-8',
        DATA_INDENT => 10,
        DATA_MODE   => 1,
        OUTPUT      => $output
    );
    $writer->xmlDecl("UTF-8");
    $writer->startTag("resources");
    for my $key ( sort keys $langs{$lang} ) {
        $writer->dataElement( "string", $langs{$lang}{$key}, name => $key );
    }
    $writer->endTag("resources");
    $writer->end();
    $output->close();
} ## end for my $lang (@langs)

### process iOS
mkdir "IOS";
for my $lang (@langs) {
    mkdir "IOS/$lang.lproj";
    open my $fh, ">", "IOS/$lang.lproj/Localizable.strings";
    for my $key ( sort keys $langs{$lang} ) {
        print $fh '"' . $key . '" = "' . $langs{$lang}{$key} . '";' . "\n";
    }
    close $fh;

}

### process XLIFF
mkdir "XLIFF";
for my $lang (@langs) {
    my $output = new IO::File(">XLIFF/$lang.xliff") || die "$!";

    my $writer = new XML::Writer(
        NAMESPACES  => 'utf-8',
        DATA_INDENT => 10,
        DATA_MODE   => 1,
        OUTPUT      => $output
    );
    $writer->xmlDecl("UTF-8");
    $writer->startTag( "xliff", version => '1.0' );
    $writer->startTag(
        "file",
        'source-language' => 'zbroing',
        'target-language' => $lang
    );
    $writer->startTag('body');
    for my $key ( sort keys $langs{$lang} ) {
        $writer->dataElement( "string", $langs{$lang}{$key}, name => $key );
    }
    $writer->endTag("body");
    $writer->endTag("file");
    $writer->endTag("xliff");
    $writer->end();
    $output->close() || print "$@";
} ## end for my $lang (@langs)

__DATA__
<xliff version="1.1" xmlns="urn:oasis:names:tc:xliff:document:1.1">
   <file source-language="en-US" datatype="plaintext" target-language="de">
      <body>
        <string name="firstrun_textview_language_array_names1">Englisch</string>
        <string name="firstrun_textview_language_array_names2">i dont know</string>
     </body>
   </file>
</xliff>
