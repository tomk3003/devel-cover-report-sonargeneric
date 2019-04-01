package Devel::Cover::Report::SonarGeneric;

use strict;
use warnings;
use Path::Tiny qw(path);

our $VERSION = '0.1';

sub report {
    my ($pkg, $db, $options) = @_;

    my $cover = $db->cover;

    my $otxt = qq(<coverage version="1">\n);
    for my $file ( @{ $options->{file} } ) {

        my $f  = $cover->file($file);
        my $st = $f->statement;
        my $br = $f->branch;

        $otxt .= qq(  <file path="$file">\n);

        for my $lnr ( sort { $a <=> $b } $st->items ) {
            my $sinfo = $st->location($lnr);
            if ( $sinfo ) {
                my $covered = 0;
                for my $o ( @$sinfo ) {
                    my $ocov = $o->covered // 0;
                    my $ounc = $o->uncoverable // 0;
                    $covered |= $ocov || $ounc;
                }
                my $covtxt = $covered > 0 ? 'true' : 'false';
                if ( $br and my $binfo = $br->location($lnr) ) {
                    my $btot = $binfo->[0]->total;
                    my $bcov = $binfo->[0]->covered;
                    $otxt .= qq(    <lineToCover lineNumber="$lnr" covered="$covtxt" branchesToCover="$btot" coveredBranches="$bcov"/>\n);
                } else {
                    $otxt .= qq(    <lineToCover lineNumber="$lnr" covered="$covtxt"/>\n);
                }
            }
        }

        $otxt .= qq(  </file>\n);
    }

    $otxt .= qq(</coverage>\n);

    path('cover_db/sonar_generic.xml')->spew($otxt);
}

1;
