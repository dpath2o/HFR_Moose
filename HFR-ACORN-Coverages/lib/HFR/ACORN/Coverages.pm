package HFR::ACORN::Coverages;

use 5.006;
use strict;
use HFR;
use HFR::ACORN;
use PDL;
use PDL::NiceSlice;
use PDL::NetCDF;
use LWP::Simple;
use Date::Calc qw( Localtime );

our $VERSION = '0.01';

=head1 NAME

HFR::ACORN::Coverages - The great new HFR::ACORN::Coverages!

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=head2 construct_figure_file

=cut

sub construct_figure_file {

  my $self = shift;

  if ( $self->HFR::ACORN::is_site  and (!defined $self->{figure_directory}) ) {
    $self->{figure_directory} = sprintf('%s/%s/coverages',$self->{base_fig_directory},$self->{station_site});
  } else {
    $self->{figure_directory} = sprintf('%s/%s/%s/coverages',$self->{base_fig_directory},$self->{site},$self->{station_site});
  }

  if (!(-d $self->{figure_directory})) { 
    umask 000; # ensure the permissions you set are the ones you get
    mkdir $self->{figure_directory};
    chmod 0755, $self->{figure_directory};
  }

  my $t0 = $self->{start_time}->sclr;
  my $tN = $self->{stop_time}->sclr;

  my ($yr0,$mo0,$dy0, $hr0,$mn0,$sc0, $doy0,$dow0,$dst0) = Localtime($t0);
  my ($yrN,$moN,$dyN, $hrN,$mnN,$scN, $doyN,$dowN,$dstN) = Localtime($tN);

  $self->{figure_file} = sprintf('%s/%s_coverage_FROM_%04d%02d%02dT%02d%02d_TO_%04d%02d%02dT%02d%02d.%s',
				 $self->{figure_directory},$self->{station_site},
				 $yr0,$mo0,$dy0,$hr0,$mn0,
				 $yrN,$moN,$dyN,$hrN,$mnN,
				 $self->{coverage_file_suffix}
				);
  return $self;

}

=head2 compute_coverage

=cut

sub compute_coverage {

  my $self = shift;

  my $occs = zeros($self->{grid_longitudes}->nelem,1);

  # loop over each file
  # extract lon/lat from each file
  # using attributes and GMT function 'grdmask' find all the lon/lat pairs within 10 meters of each grid point
  # keep track of these occurrences -- i.e. keep a running total
  my @filedims = $self->{full_file_list}->dims;
  for (my $l1=0;$l1<$filedims[1];$l1++) {

    if (-e $self->{full_file_list}->atstr($l1) or head($self->{full_file_list_url}->atstr($l1)) ) {

      printf("Extracting lon/lat from: %s\n", $self->{full_file_list}->atstr($l1)) if ($self->{verbose}>=2);
      my $nc = PDL::NetCDF->new( $self->{full_file_list}->atstr($l1) );

      if ($self->HFR::ACORN::is_site_seasonde) {

	# For the site data will go off any non-zero currents ('speed'>0)
	my $speed = $nc->get('SPEED');
	# since speed is 'gridded' we need to reshape it into the same dimensions as the grid
	$speed->reshape($self->{grid_longitudes}->nelem);
	$occs( which($speed<$self->{site_badval_flag} & $speed>0) )++;
      
      } elsif ($self->HFR::ACORN::is_site_wera) {

	# get the grid on the same indeces since there are no indeces in the nc file
	if ($l1==0) {
	  my $latD = $nc->get('LATITUDE');
	  my $lonD = $nc->get('LONGITUDE');
	  my $grid = cat( $lonD->(:, *$latD->nelem), $latD->(*$lonD->nelem, :) )->mv(-1,0);
	  my $LAT  = $grid(1,:,:);
	  my $LON  = $grid(0,:,:);
	  $LON->reshape( ($lonD->nelem)*($latD->nelem) );
	  $LAT->reshape( ($lonD->nelem)*($latD->nelem) );
	  $self->{grid_latitudes}  = $LAT;
	  $self->{grid_longitudes} = $LON;
	  $occs = zeros($self->{grid_longitudes}->nelem,1);
	}

	# For the site data will go off any non-zero currents ('speed'>0)
	my $speed = $nc->get('SPEED');
	# since speed is 'gridded' we need to reshape it into the same dimensions as the grid
	$speed->reshape($self->{grid_longitudes}->nelem);
	$occs( which($speed<$self->{site_badval_flag} & $speed>0) )++;
      
      } else {

	my($lonD,$latD,$D);
	my $latD = $nc->get('LATITUDE');
	my $lonD = $nc->get('LONGITUDE');
	my $N    = $latD->nelem;
	printf("Station coverage on %i data lon/lats on %s \n",$N,$self->{grid_file}) if ($self->{verbose}>=3) ;
	for (my $l2=0;$l2<$N;$l2++) {
	  # compute distances, Law of Cosines is sufficient
	  my $D = HFR::distance_law_of_cosines( $lonD($l2) , $latD($l2) , $self->{grid_longitudes} , $self->{grid_latitudes} );
	  # Log grid indeces that are within n kilometers of lon/lat data 
	  if ( any($D<$self->{data_to_grid_distance_tolerance} & $D>0) ) {
	    $occs( which($D<$self->{data_to_grid_distance_tolerance} & $D>0) )++;
	  }
	}

      }

    } else {
      printf("FILE DOES NOT EXIST, SKIPPING: %s\n", $self->{full_file_list}->atstr($l1)) if ($self->{verbose}>=1);
    }

  }
  
  my $percs = $occs/($occs->max);
  $percs(which($percs==0)).='nan';
  $self->{coverage} = $percs;

  # write out data
  $self->{coverage_data_full_file} = $self->{hot_directory}.'/'.$self->{coverage_data_file};
  unlink($self->{coverage_data_full_file}) if (-e $self->{coverage_data_full_file});
  wcols $self->{grid_longitudes},$self->{grid_latitudes},$self->{coverage}, $self->{coverage_data_full_file};
  printf("Created temporary coverage data file: %s\n",$self->{coverage_data_full_file}) if (-e $self->{coverage_data_full_file} and $self->{verbose}>=1);

  return $self;

}

=head1 AUTHOR

Atwater, Daniel Patrick Lewis, C<< <danielpath2o at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-hfr-acorn-coverages at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HFR-ACORN-Coverages>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HFR::ACORN::Coverages


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HFR-ACORN-Coverages>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HFR-ACORN-Coverages>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HFR-ACORN-Coverages>

=item * Search CPAN

L<http://search.cpan.org/dist/HFR-ACORN-Coverages/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Atwater, Daniel Patrick Lewis.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of HFR::ACORN::Coverages
