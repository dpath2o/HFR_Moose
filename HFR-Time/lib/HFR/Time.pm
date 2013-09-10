package HFR::Time;

# MOOSE IT
use Moose;

# PDL
use PDL::Lite;
use PDL::NiceSlice;
use PDL::Char;

# HELPFUL
use Date::Parse;

extends 'HFR';

# Preloaded methods go here.
################################################################################
sub determine_datetime {

  my $self = shift;

  $self->{time}->{start} = pdl[ str2time( $self->{start_time_string} ) ]; #Date::Parse
  $self->{time}->{stop}  = pdl[ str2time( $self->{stop_time_string} ) ];  #Date::Parse

  return $self;

}
################################################################################
sub define_datestrs {

  my $self = shift;

  my ($sc0,$mn0,$hr0, $dy0,$mo0,$yr0, $dow0,$doy0,$dst0) = localtime($self->{time}->{start}->sclr);
  my ($scN,$mnN,$hrN, $dyN,$moN,$yrN, $dowN,$doyN,$dstN) = localtime($self->{time}->{stop}->sclr);
  #my ($yr0,$mo0,$dy0, $hr0,$mn0,$sc0, $doy0,$dow0,$dst0) = Localtime($self->{time}->{start}->sclr);
  #my ($yrN,$moN,$dyN, $hrN,$mnN,$scN, $doyN,$dowN,$dstN) = Localtime($self->{time}->{stop}->sclr);

  my $t0_str = sprintf('%04d-%02d-%02d %02d:%02d',$yr0,$mo0,$dy0,$hr0,$mn0);
  my $tN_str = sprintf('%04d-%02d-%02d %02d:%02d',$yrN,$moN,$dyN,$hrN,$mnN);

  $self->{time}->{start_str} = $t0_str;
  $self->{time}->{stop_str}  = $tN_str;

  return $self;

}
################################################################################
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
################################################################################
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

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

HFR::Time - Perl extension for blah blah blah

=head1 SYNOPSIS

  use HFR::Time;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for HFR::Time, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Daniel Patrick Lewis Atwater, E<lt>dpath2o@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Daniel Patrick Lewis Atwater

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
