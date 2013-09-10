package HFR::ACORN;

use 5.006;
use strict;
use warnings;
use Date::Parse;
use Date::Calc qw ( Localtime );
use PDL::Lite;
use YAML::XS qw(LoadFile);
our $VERSION = '1.45';

=head1 NAME

HFR-ACORN - for use with HF radar (HFR) and Australian Coastal Ocean Radar Network (ACORN) data.

=head1 VERSION

Version 1.45

=head1 SYNOPSIS

In a broad sense HFR-ACORN perl module is intended to be used as a class which utilises methods for manipulating ACORN derived data.  Plainly speaking, what we the author intends is that this module be used in an object-orientated way for extracting, visualising and running various computations on ACORN derived data.

Here's a quick example of one the myriad of possible uses. Say you'd like to build a list of radial files from ACORN Guilderton (GUI) station for certain time period:

EXAMPLE
C<<use HFR::ACORN;>>
C<<use PDL::Lite;>>
C<<use PDL::Char;>>
C<<$acorn = HFR::ACORN->new( sos => 'guilderton' , start => '12 sep 2011' , stop => '12 sep 2012 01:30' );>>
C<<$acorn->HFR::ACORN::FileOps::construct_file_list;>>
C<<if (-e $acorn->{full_file_list}->atstr(0)) { print "$_ exists\n"; } else { print "$_ does NOT exists\n"; }>>

The above example checks to see if first file list of files created exists and prints a message on its existence.
Plenty of assumptions (default parameters) are made in the above example when calling C<<HFR::ACORN->new>> (see below for the list of those parameters).

B<NOTE>: The backbone of HFR::ACORN is the B<YAML configuration file>. See L<HFR::YAML>.

=head1 SUBROUTINES/METHODS

=over

=item C<<new>>

Returns a new ACORN object, which has loaded the file configuration file (see L<HFR::YAML>)

=back

=head2 new

=cut


sub new {

   my($class, %args) = @_;
   my $self          = bless( {} , $class );

   # load configuration file and bless to self
   my $config_file = exists $args{config_file} ? $args{config_file} : $ENV{"HOME"}.'/acorn_perl.yml';
   $self = LoadFile $config_file;

   # REQUIRED INPUT PARAMETERS
   my $sos                   = exists $args{sos} ? $args{sos} : $self->{codenames}->{sos}; 
   $self->{codenames}->{sos} = $sos;
   my $start                 = exists $args{start} ? $args{start} : $self->{time}->{start};
   $self->{time}->{start}    = $start;
   my $stop                  = exists $args{stop} ? $args{stop} : $self->{time}->{stop};
   $self->{time}->{stop}     = $stop;
   my $verbose               = exists $args{verbose} ? $args{verbose} : $self->{misc}->{verbose};
   $self->{misc}->{verbose}  = $verbose;

   # RETURN
   bless $self;
   return $self;

}

=head2 is_wera

Given C<<$acorn->{sos}>> check to see if that name is a I<<WERA station or site>>

=cut

sub is_wera { 

  my $self = shift;

  if ( $self->{codenames}->{sos} ~~ @{$self->{codenames}->{wera_all}} ) { return 1; } else { return 0; }

}

=head2 is_site 

Given C<<$acorn->{sos}>> check to see if that name is a I<<site>>

=cut

sub is_site {

  my $self = shift;

  if ($self->{codenames}->{sos} ~~ @{$self->{codenames}->{sites}} ) { return 1; } else { return 0; }

}

=head2 is_site_seasonde

Given C<<$acorn->{sos}>> check to see if that name is a I<<SeaSonde site>>

=cut


sub is_site_seasonde {

  my $self = shift;

  if ($self->{codenames}->{sos} ~~ @{$self->{codenames}->{codar_sites}} ) { return 1; } else { return 0; }

}

=head2 is_site_wera

Given C<<$acorn->{sos}>> check to see if that name is a I<<WERA site>>

=cut

sub is_site_wera {

  my $self = shift;

  if ($self->{codenames}->{sos} ~~ @{$self->{codenames}->{wera_sites}} ) { return 1; } else { return 0; }

}

=head2 determine_site

Given C<<$acorn->{sos}>> return C<<$acorn->{site}>>

=cut

sub determine_site {

  my $self = shift;

  my $regex1 = qr/$self->{codenames}->{green_head}|$self->{codenames}->{lancelin}|$self->{codenames}->{cervantes}|$self->{codenames}->{seabird}|$self->{codenames}->{turquoise_coast}/i;
  my $regex2 = qr/$self->{codenames}->{nora_creina}|$self->{codenames}->{blackfellows_caves}|$self->{codenames}->{bonney_coast}/i;
  my $regex3 = qr/$self->{codenames}->{fremantle}|$self->{codenames}->{guilderton}|$self->{codenames}->{rottnest_island}/i;
  my $regex4 = qr/$self->{codenames}->{cape_wiles}|$self->{codenames}->{cape_spencer}|$self->{codenames}->{south_australia_gulf}/i;
  my $regex5 = qr/$self->{codenames}->{north_nambucca}|$self->{codenames}->{red_rock}|$self->{codenames}->{coffs_harbour}/i;
  my $regex6 = qr/$self->{codenames}->{lady_elliot_island}|$self->{codenames}->{tannumb_sands}|$self->{codenames}->{capricorn_bunker_group}/i;

  if ($self->{codenames}->{sos} =~ $regex1) { $self->{site} = $self->{codenames}->{turquoise_coast}; }
  elsif ($self->{codenames}->{sos} =~ $regex2) { $self->{site} = $self->{codenames}->{bonney_coast}; }
  elsif ($self->{codenames}->{sos} =~ $regex3) { $self->{site} = $self->{codenames}->{rottnest_island}; }
  elsif ($self->{codenames}->{sos} =~ $regex4) { $self->{site} = $self->{codenames}->{south_australia_gulf}; }
  elsif ($self->{codenames}->{sos} =~ $regex5) { $self->{site} = $self->{codenames}->{coffs_harbour}; }
  elsif ($self->{codenames}->{sos} =~ $regex6) { $self->{site} = $self->{codenames}->{capricorn_bunker_group}; }
  else { warn 'given station name is NOT and ACORN site'; $self->{site} = ''; }

  return $self;

}

=head2 determine_datetime

Given both C<<$acorn->{start}>> I<and> C<<$acorn->{stop}>> are defined as parse-able date-string then
return C<<$acorn->{start}>> and C<<$acorn->{stop}>> as POSIX time as a PDL scalar.
See 

=cut

sub determine_datetime {

  my $self = shift;

  $self->{time}->{start} = pdl[ str2time( $self->{time}->{start} ) ];
  $self->{time}->{stop}  = pdl[ str2time( $self->{time}->{stop} ) ];

  return $self;

}

=head2 define_datestrs



=cut

sub define_datestrs {

  my $self = shift;

  my ($yr0,$mo0,$dy0, $hr0,$mn0,$sc0, $doy0,$dow0,$dst0) = Localtime($self->{time}->{start}->sclr);
  my ($yrN,$moN,$dyN, $hrN,$mnN,$scN, $doyN,$dowN,$dstN) = Localtime($self->{time}->{stop}->sclr);

  my $t0_str = sprintf('%04d-%02d-%02d %02d:%02d',$yr0,$mo0,$dy0,$hr0,$mn0);
  my $tN_str = sprintf('%04d-%02d-%02d %02d:%02d',$yrN,$moN,$dyN,$hrN,$mnN);

  $self->{time}->{start_str} = $t0_str;
  $self->{time}->{stop_str}  = $tN_str;

  return $self;

}

=head2 determine_delta_time



=cut

sub determine_delta_time {

  my $self = shift;

  if ( $self->{codenames}->{sos} ~~ @{$self->{codenames}->{wera_stations}} ) {

    $self->{time}->{dt} = pdl[600]; #10 minutes
    printf("Delta time of 600 seconds for site/station %s\n",$self->{codenames}->{sos}) if ($self->{misc}->{verbose}>=3);

  } elsif ( $self->{codenames}->{sos} ~~ [ @{$self->{codenames}->{codar_all}} , @{$self->{codenames}->{wera_sites}}] ) {

    $self->{time}->{dt} = pdl[3600]; #60 minutes
    printf("Delta time of 3600 seconds for site/station %s\n",$self->{codenames}->{sos}) if ($self->{misc}->{verbose}>=3);

  } else {

    die "could not determine delta time";

  }

  return $self;

}

=head2 determine_offset_time



=cut

sub determine_offset_time {

  my $self = shift;

  if ( $self->{codenames}->{sos} ~~ @{$self->{codenames}->{wera_t_off_5}} ) { 

    $self->{time}->{start}+=pdl[300];
    $self->{time}->{stop}+=pdl[300];
    printf("Time offset by 300 seconds for station %s\n",$self->{codenames}->{sos}) if ($self->{misc}->{verbose}>=3);

  } elsif ( $self->{codenames}->{sos} ~~ @{$self->{codenames}->{wera_sites}} ) {

    $self->{time}->{start}+=pdl[1800];
    $self->{time}->{stop}+=pdl[1800];
    printf("Time offset by 1800 seconds for site %s\n",$self->{codenames}->{sos}) if ($self->{misc}->{verbose}>=3);

  } else {

    printf("Time offset not necessary for %s\n",$self->{codenames}->{sos}) if ($self->{misc}->{verbose}>=3);

  }

  return $self;

}

=head2 determine_codename



=cut

sub determine_codename {

  my $self = shift;

  if ( $self->{codenames}->{sos} =~ /cervantes|crvt/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{cervantes};

  } elsif ( $self->{codenames}->{sos} =~ /green head|ghed/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{green_head};

  } elsif ( $self->{generalities}->(sos} =~ /lancelin|lanc/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{lancelin};

  } elsif ( $self->{codenames}->{sos} =~ /seabird|sbrd/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{seabird};

  } elsif ( $self->{codenames}->{sos} =~ /guilderton|gui/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{guilderton};

  } elsif ( $self->{codenames}->{sos} =~ /fremantle|fre/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{fremantle};

  } elsif ( $self->{codenames}->{sos} =~ /cape wiles|eyre peninsula|cwi/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{cape_wiles};

  } elsif ( $self->{codenames}->{sos} =~ /cape spencer|yorke peninsula|csp/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{cape_spencer};

  } elsif ( $self->{codenames}->{sos} =~ /nora|nora creina|robe|nocr/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{nora_creina};

  } elsif ( $self->{codenames}->{sos} =~ /blackfellows|blackfellows caves|bfcv/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{blackfellows_caves};

  } elsif ( $self->{codenames}->{sos} =~ /nambucca|nambucca heads|nnb/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{north_nambucca};

  } elsif ( $self->{codenames}->{sos} =~ /red rock|rrk/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{red_rock};

  } elsif ( $self->{codenames}->{sos} =~ /lady elliot|lady elliot island|lei/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{lady_elliot_island};

  } elsif ( $self->{codenames}->{sos} =~ /tannum|tannum sands|tan/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{tannum_sands};

  } elsif ( $self->{codenames}->{sos} =~ /turquoise|turquoise coast|turq/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{turquoise_coast};

  } elsif ( $self->{codenames}->{sos} =~ /rottnest|rottnest island|rot/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{rottnest_island};

  } elsif ( $self->{codenames}->{sos} =~ /sa gulf|south australian? gulf|sag/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{south_australia_gulf};

  } elsif ( $self->{codenames}->{sos} =~ /bonney coast|limestone coast|bonc/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{bonney_coast};

  } elsif ( $self->{codenames}->{sos} =~ /coffs|coffs harbour|cof/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{coffs_harbour};

  } elsif ( $self->{codenames}->{sos} =~ /capricorn|capricorn bunker group|cbg/i ) {

    $self->{codenames}->{sos} = $self->{codenames}->{capricorn_bunker_group};

  }

  printf("Station/site is %s\n",$self->{codenames}->{sos}) if ($self->{misc}->{verbose}>=3);

  return $self;

}

=head1 AUTHOR

Atwater, Daniel Patrick Lewis, C<< <danielpath2o at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-hfr-acorn at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HFR-ACORN>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HFR::ACORN

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HFR-ACORN>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HFR-ACORN>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HFR-ACORN>

=item * Search CPAN

L<http://search.cpan.org/dist/HFR-ACORN/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Atwater, Daniel Patrick Lewis.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of HFR::ACORN
