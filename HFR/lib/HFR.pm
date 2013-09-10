# CLASS
package HFR;

# CLEAN
use namespace::autoclean;

# MOOSE
use Moose;
use MooseX::NonMoose;

# OTHER PACKAGES
use DateTime;
use DateTime::Format::Epoch::MacOS;
extends qw(DateTime);

# ATTRIBUTES
# time
has 'start_time_string' => (
                            is        => 'rw',
                            isa       => 'Str',
                            lazy      => 1,
                            builder   => '_10_days_ago',
                            clearer   => 'clear_start_time_string',
                            predicate => 'has_start_time_string'
                           );
has 'stop_time_string'  => (
                            is        => 'rw',
                            isa       => 'Str',
                            lazy      => 1,
                            builder   => '_1_day_ago',
                            clearer   => 'clear_stop_time_string',
                            predicate => 'has_stop_time_string'
                           );
has 'delta_time'        => (
                            is        => 'rw',
                            isa       => 'Str',
                            lazy      => 1,
                            clearer   => 'clear_delta_time',
                            predicate => 'has_delta_time'
                           );
has 'mac_os_epoch'      => (
                            is        => 'ro',
                            isa       => 'DateTime',
                            init_arg  => undef,
                            lazy      => 1,
                            builder   => '_mac_os_epoch_datetime',
                            clearer   => 'clear_mac_os_epoch',
                            predicate => 'has_mac_os_epoch'
                           );
after 'set' => sub { $_[0]->clear_mac_os_epoch; };

# miscelaneous
has 'verbosity'         => (
                            is        => 'rw',
                            isa       => 'Int',
                            lazy      => 1,
                            default   => 1,
                            clearer   => 'clear_verbosity',
                            predicate => 'has_verbosity'
                           );
has 'debug'             => (
                            is        => 'rw',
                            isa       => 'Bool',
                            lazy      => 1,
                            default   => 0,
                            clearer   => 'clear_debug',
                            predicate => 'has_debug'
                           );
has 'use_qc'            => (
                            is        => 'rw',
                            isa       => 'Bool',
                            lazy      => 1,
                            default   => 0,
                            clearer   => 'clear_use_qc',
                            predicate => 'has_use_qc'
                           );

################################################################################
# BUILDERS
sub _10_days_ago {
    return DateTime->now->subtract(days => 10)->strftime("%F %T");
}
sub _1_day_ago {
    return DateTime->now->subtract(days => 1)->strftime("%F %T");
}
sub _mac_os_epoch_datetime {
    my $t_base = DateTime->new(
                               year   => 1904,
                               month  => 1,
                               day    => 1,
                               hour   => 0,
                               minute => 0,
                               second => 0,
                               zone   => 'UTC'
                              );
    my $tmp = DateTime::Format::Epoch::MacOS->new(
                                                   epoch             => $t_base,
                                                   unit              => 'seconds',
                                                   type              => 'int', # or 'float', 'bigint'
                                                   skip_leap_seconds => 1,
                                                   start_at          => 0,
                                                   local_epoch       => undef,
                                                  );
    return $tmp;

}

# ################################################################################
# sub load_configuration {

#     my($class,$args) = @_;

#     # CONFIGURATION FILE
#     my $self = { config_file => $args{config_file} || $ENV{"HOME"}.'/acorn_perl.yml' };

#     # PRIMARIES
#     $self = {
#              start => $args{start} || $self->{time}->{start},
#              stop  => $args{stop}  || $self->{}
#             };
#     my $self          = bless( {} , $class );

#     # load configuration file and bless to self
#     my $config_file = exists $args{config_file} ? $args{config_file} : $ENV{"HOME"}.'/acorn_perl.yml';
#     $self = LoadFile $config_file;

#     # REQUIRED INPUT PARAMETERS
#     my $start                 = exists $args{start} ? $args{start} : $self->{time}->{start};
#     $self->{time}->{start}    = $start;
#     my $stop                  = exists $args{stop} ? $args{stop} : $self->{time}->{stop};
#     $self->{time}->{stop}     = $stop;
#     my $verbose               = exists $args{verbose} ? $args{verbose} : $self->{misc}->{verbose};
#     $self->{misc}->{verbose}  = $verbose;

#     # RETURN
#     bless $self;
#     return $self;

# }

no Moose;

__PACKAGE__->meta->make_immutable;

#############################################################################

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

HFR - Perl extension for high frequency oceanographic radar data

=head1 SYNOPSIS

  use HFR;

=head1 DESCRIPTION

At present this will serve as notes on the direction of HFR module.
There are a few subroutines at present:

def_t : which takes a string input of yyyy-mm-dd HH:MM and returns a Date::Calc->Mktime result

distance : which takes in two geographic points and returns the straigth line distance between them

peak_rayliegh : computes the maximum spectrum power for a given range of power

vector_data_extract : extract vector data from a netcdf file on the qcif server

Listen, all of this is fine-and-dandy, but I really need to move away from this.  Here is what I would like to build:

$nc = HFR::ACORN::NetCDF->new( ssh => "<user>@<server>:<full_path_to_netcdf> )
or
$nc = HFR::ACORN::NetCDF->new( url => "<full_url_path_to_netcdf> )

These modules would need to be run first to generate the filename or list of filenames

$url = HFR::QCIF->new( name => "Cape Wiles" , time => "2010-10-12 12:00" , qc => 1 )
or
@url = HFR::QCIF->new( name => "Spencer" , time_start => "2010-10-12 12:00" , time_stop => "2011-10-12 23:00" , qc => 1 )

OR

$ssh = HFR::SSH->new( user => "codar" , server => "acorn" , name => "Cape Wiles" , time => "2010-10-12 12:00" , qc => 1 )
or
@ssh = HFR::SSH->new( user => "codar" , server => "acorn" , name => "Spencer" , time_start => "2010-10-12 12:00" , time_stop => "2011-10-12 23:00" , qc => 1 )

AND

Create new and load default parameters for a site or station
%params = HFR::Analysis::Parameters->load( site => "South Australian Gulf" ); *this will contain grid and mask information as well as standard parameters for site*
%params = HFR::Analysis::Parameters->amend( site => "SAG" , temporal_averaging => 86400 , temporal_gap_tolerance => 3600 , spatial_gap_tolerance => 5 , spatial_gap_units => "km" );
$vec = HFR::Analysis::Vectors->( stations => @station_names , configuration_parameters => %params , time_start => "2011-12-01" , time_stop => "now" , qc => 0 , write_date => 1 ); 
* the above sequence would load /SAG/ parameters, make an amendment to parameters so that 24 hour averages are made with an hour as maximum gap tolerance to average acrossxfb

---------------------------------------------------------
*There is also the potential for the following:
$inv = HFR::ACORN::Inventory->new;
$inv->list("Cape Wiles") or $inv->list("Wiles") or $inv->list("cwi") of which any of these would return a complete list of the inventory items at that station
or
$inv = HFR::ACORN::Inventory->new( station => "Spencer"); #create new MySQL table for station
$inv->add_item( name => "12 inch spanner" , condition => "rusty" );
$inv->add_item( name => "WERA RTU" , serial_no => "12312378" , photo => "wera_rack_rtu_cwi.png" , condition => "original" );

---------------------------------------------------------
Visualisation is another potential of the toolbox
$fig = HFR::Plot::Coverage->new( @nc_filenames );
or
$fig = HFR::Plot::Vectors->new( 


=head2 EXPORT

None by default.

=head1 SEE ALSO

packages used:
Date::Calc
PDL
PDL::NetCDF
PDL::Slatec
PDL::NiceSllice

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Daniel Atwater, E<lt>danielpath2o@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Daniel Patrick Lewis Atwater

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
