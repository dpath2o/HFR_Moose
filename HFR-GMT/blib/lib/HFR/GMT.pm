package HFR::GMT;

use 5.006;
use strict;
use warnings;
use PDL;
use PDL::NiceSlice;
use PDL::Math;
use PDL::Char;
use PDL::Constants qw( PI );

=head1 NAME

HFR::GMT - The great new HFR::GMT!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use HFR::GMT;

    my $foo = HFR::GMT->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {

   my($class, %args) = @_;
   my $self          = bless( {} , $class );

   my $executables_directory      = exists $args{executables_directory} ? $args{executables_directory} : '/opt/local/lib/gmt5/bin';
   $self->{executables_directory} = $executables_directory;
   my $frame                      = exists $args{frame} ? $args{frame} : '-B1g1f15m';
   $self->{frame}                 = $frame;
   my $projection                 = exists $args{projection} ? $args{projection} : '-JM35';
   $self->{projection}            = $projection;
   my $page_offset                = exists $args{page_offset} ? $args{page_offset} : '-Xc -Yc';
   $self->{page_offset}           = $page_offset;
   my $circle_size                = exists $args{circle_size} ? $args{circle_size} : '0.25c';
   $self->{circle_size}           = $circle_size;
   my $region                     = exists $args{region} ? $args{regions} : '';
   $self->{region}                = $region;
   my $frame_longitudes           = exists $args{frame_longitudes} ? $args{frame_longitudes} : pdl [];
   $self->{frame_longitudes}      = $frame_longitudes;
   my $frame_latitudes            = exists $args{frame_latitudes} ? $args{frame_latitudes} : pdl [];
   $self->{frame_latitudes}       = $frame_latitudes;
   my $use_predefined_region      = exists $args{use_predefined_region} ? $args{use_predefined_region} : 0;
   $self->{use_predefined_region} = $use_predefined_region;

   return $self;

}


=head2 define_region

=cut

sub define_region {

  my $self = shift;
  my $lons = $self->{frame_longitudes};
  my $lats = $self->{frame_latitudes};

  my ($lonmin,$lonmax,$latmin,$latmax);

  my $fudge = 0.1;

  if ( $lons->max >= 0 ) { $lonmax = $lons->max + $fudge; } else { $lonmax = $lons->max - $fudge; }
  if ( $lons->min >= 0 ) { $lonmin = $lons->min - $fudge; } else { $lonmin = $lons->min + $fudge; }
  if ( $lats->min >= 0 ) { $latmin = $lats->min - $fudge; } else { $latmin = $lats->min + $fudge; }
  if ( $lats->max >= 0 ) { $latmax = $lats->max + $fudge; } else { $latmax = $lats->max - $fudge; } 

  $self->{region} = sprintf("-R%3.6f/%3.6f/%3.6f/%3.6f",$lonmin,$lonmax,$latmin,$latmax);

  return $self;

}

=head2 predefined_acorn_regions

=cut

sub predefined_acorn_regions {

  my $self = shift;
  my $site = shift;

  if ( $site =~ /turq/ ) { $self->{region} = '-R112.5/116.25/-33.25/-28.5'; }
  if ( $site =~ /rot/ ) { $self->{region} = '-R112.75/116/-34/-30'; }
  if ( $site =~ /sag/ ) { $self->{region} = '-R134.75/137.25/-36.75/-34.75'; }
  if ( $site =~ /bonc/ ) { $self->{region} = '-R137.75/141/-39.5/-36.5'; }
  if ( $site =~ /cof/ ) { $self->{region} = '-R153/155/-31.75/-29.5'; }
  if ( $site =~ /cbg/ ) { $self->{region} = '-R151.1/153.1/-24.25/-22.5'; }
 
  return $self;

}

=head1 AUTHOR

Atwater, Daniel Patrick Lewis, C<< <danielpath2o at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-hfr-gmt at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HFR-GMT>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HFR::GMT


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HFR-GMT>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HFR-GMT>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HFR-GMT>

=item * Search CPAN

L<http://search.cpan.org/dist/HFR-GMT/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Atwater, Daniel Patrick Lewis.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of HFR::GMT
