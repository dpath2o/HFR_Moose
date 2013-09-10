package HFR::ACORN::FileOps;

use 5.006;
use strict;
use warnings;
use Data::Dumper;
use PDL;
use PDL::NiceSlice;
use PDL::Char;
use Date::Calc qw( Localtime );
use HFR;
use HFR::ACORN;

our $VERSION = '0.01';

=head1 NAME

HFR::ACORN::FileOps - The great new HFR::ACORN::FileOps!

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=head2 define_full_path

=cut

sub define_full_path {

  my $self = shift;

  # DIRECTORY DATA TYPE
  my $directory_data_type;
  $directory_data_type = $self->{site_directory_data_type_qc} if ( $self->HFR::ACORN::is_site and $self->{use_qc} );
  $directory_data_type = $self->{site_directory_data_type_nonqc} if ( $self->HFR::ACORN::is_site and !$self->{use_qc} );
  $directory_data_type = $self->{station_directory_data_type_qc} if ( !$self->HFR::ACORN::is_site and $self->{use_qc} );
  $directory_data_type = $self->{station_directory_data_type_nonqc} if ( !$self->HFR::ACORN::is_site and !$self->{use_qc} );

  $self->{full_path} = sprintf( "%s/%s/%s/%04d/%02d/%02d" ,
				$self->{remote_base_directory} ,
				$directory_data_type,
				uc($self->{station_site}) ,
				$self->{file_year} ,
				$self->{file_month} ,
				$self->{file_day} );

  return $self;

}

=head2 define_file_time

=cut

sub define_file_time {
  my $self                                 = shift;
  my $t                                    = shift;
  my ($yr,$mo,$dy,$HR,$MN,$SC,$DD,$DW,$DT) = Localtime($t);
  $self->{file_time}                       = sprintf "%04d%02d%02dT%02d%02d00Z", $yr,$mo,$dy,$HR,$MN;
  $self->{file_year}                       = $yr;
  $self->{file_month}                      = $mo;
  $self->{file_day}                        = $dy;
  return $self;
}

=head2 define_filename

=cut

sub define_filename {
  my $self = shift;
  my ($data_version,$data_type,$qc_version);
  if ($self->HFR::ACORN::is_site) {
    $data_version = $self->{vector_data_version};
    $data_type    = $self->{vector_data_type};
  } else {
    $data_version = $self->{radial_data_version};
    $data_type    = $self->{radial_data_type};
  }
  if ($self->{use_qc}) {
    $qc_version = $self->{file_version_qc};
  } else {
    $qc_version = $self->{file_version_nonqc};
  }
  $self->{filename} = sprintf("%s_%s_%s_%s_%s_%s.nc" ,
			      uc($self->{filename_prefix}),
			      uc($data_version),
			      $self->{file_time},
			      uc($self->{station_site}),
			      uc($qc_version),
			      $data_type,
			     );
  $self->{url_filename} = sprintf("%s_%s_%s_%s_%s_%s.nc.html" ,
			      uc($self->{filename_prefix}),
			      uc($data_version),
			      $self->{file_time},
			      uc($self->{station_site}),
			      uc($qc_version),
			      $data_type,
			     );
  return $self;
}

=head2 construct_file_list

=cut

sub construct_file_list {

  my $self = shift;

  # make sure the parameters are in the correct format
  $self->HFR::ACORN::determine_codename;
  $self->HFR::determine_datetime;
  $self->HFR::ACORN::determine_site;

  # determine how often netcdf files are created
  $self->HFR::determine_delta_time;
  $self->HFR::determine_offset_time;

  # determine how many intervals to loop over
  my $t_n = rint(( $self->{stop_time} - $self->{start_time} ) / $self->{dt})->sclr;

  my @full_file_list     = ();
  my @full_file_list_url = ();

  # create a list of files or just a single file
  if ( $t_n > 2 ) {
    my $tmp1 = ( zeroes(($t_n - 1),1)->xlinvals(1,($t_n - 1)) * $self->{dt} ) + $self->{start_time}; 
    my $tmp2 = pdl[ $self->{start_time} ];
    my $t    = $tmp2->append($tmp1);
    foreach ($t->list) {
      $self->HFR::ACORN::FileOps::define_file_time($_);
      $self->HFR::ACORN::FileOps::define_filename;
      $self->HFR::ACORN::FileOps::define_full_path;
      push @full_file_list , sprintf( "%s/%s" , $self->{full_path},$self->{filename} );
      push @full_file_list_url , sprintf( "%s/%s" , $self->{full_path},$self->{url_filename} );
    }
  } elsif ( $t_n == 2 ) {
    my $t = pdl[$self->{start_time},$self->{start_time}+$self->{dt},$self->{stop_time}];
    foreach ($t->list) {
      $self->HFR::ACORN::FileOps::define_file_time($_);
      $self->HFR::ACORN::FileOps::define_filename;
      $self->HFR::ACORN::FileOps::define_full_path;
      push @full_file_list , sprintf( "%s/%s" , $self->{full_path},$self->{filename} );
      push @full_file_list_url , sprintf( "%s/%s" , $self->{full_path},$self->{url_filename} );
    }
  } elsif ( $t_n == 1 ) {
    my $t = pdl[$self->{start_time},$self->{stop_time}];
    foreach ($t->list) {
      $self->HFR::ACORN::FileOps::define_file_time($_);
      $self->HFR::ACORN::FileOps::define_filename;
      $self->HFR::ACORN::FileOps::define_full_path;
      push @full_file_list , sprintf( "%s/%s" , $self->{full_path},$self->{filename} );
      push @full_file_list_url , sprintf( "%s/%s" , $self->{full_path},$self->{url_filename} );
    }
  } else {
    my $t = $self->{start_time};
    $self->HFR::ACORN::FileOps::define_file_time($_);
    $self->HFR::ACORN::FileOps::define_filename;
    $self->HFR::ACORN::FileOps::define_full_path;
    push @full_file_list , sprintf( "%s/%s" , $self->{full_path},$self->{filename} ) ;
    push @full_file_list_url , sprintf( "%s/%s" , $self->{full_path},$self->{url_filename} ) ;
  }

  $self->{full_file_list}     = PDL::Char->new( @full_file_list );
  $self->{full_file_list_url} = PDL::Char->new( @full_file_list_url );

  return $self;

}


=head1 AUTHOR

Atwater, Daniel Patrick Lewis, C<< <danielpath2o at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-hfr-acorn-fileops at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HFR-ACORN-FileOps>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HFR::ACORN::FileOps


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HFR-ACORN-FileOps>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HFR-ACORN-FileOps>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HFR-ACORN-FileOps>

=item * Search CPAN

L<http://search.cpan.org/dist/HFR-ACORN-FileOps/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Atwater, Daniel Patrick Lewis.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of HFR::ACORN::FileOps
