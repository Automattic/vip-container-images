#!/usr/bin/env perl
#
##################################################
# Manages versions of WordPress container images.
#   uses an algorithm to decide which versions should be available 
#   Runs processes to make the actual images correct accordding to that list
##################################################

package utils;

use strict;
use warnings;

use File::Basename;
use FileHandle;
use HTTP::Request;
use JSON;
use LWP::UserAgent ();

use Data::Dumper;
####################################################################################

my $path = dirname( __FILE__ );
my %cfg = get_config( "$path/version-manager.cfg" );
my @image_list = get_live_image_list( $cfg{'GITHUB_OAUTH_TOKEN'} );
my @tag_list = get_tag_list();
my @version_list = collate_tag_list( tags => \@tag_list, size => 12 );

print "image list\n";
print Dumper(\@image_list);

print "version list\n";
print Dumper(\@version_list);

####################################################################################
# Collate list of tags to produce a list that we want users to in the dev-env
sub collate_tag_list {
    my %params = @_;
    my @new_tag_list; my @parts;
    my $major_version; my $version; my $release;

    die "Parameter 'tags' is required" if not $params{tags};
    die "Parameter 'size' is required" if not $params{size};

    #sort tags
	my @tags = reverse(@{ $params{tags} });

    #create tag indexes
    my %indexes = index_tags(@tags);

    #nested loop to walk through and curate WordPress versions
    OUTER: for my $i (0 .. $#{ $indexes{'major_versions'} }) {
        $major_version = $indexes{'major_versions'}[$i];
        for my $j (0 .. $#{ $indexes{'versions'}{$major_version} }) {
            $version = $indexes{'versions'}{$major_version}[$j];

            # If its the first and second version of the current major version,
            # Add all releases
            if ($i == 0 && $j < 2) {
                push(@new_tag_list, @{ $indexes{'releases'}{$version} });
            } else {
                # Otherwise only select the newest release of the major version
                push(@new_tag_list, $indexes{'releases'}{$version}[0]);
            }

            if (scalar(@new_tag_list) >= $params{size}) {
                last OUTER;
            }
        }
    }

    return @new_tag_list;
}

# Creates indexes with the tags
sub index_tags {
    my (@tags) = (@_);
    my %indexes;
    my @major_versions;
    my %versions;
    my %releases;
    my $major_version; my $version; my $release;

    #index tags
    foreach my $tag (@tags) {
        if (index($tag, '.') == -1) {
            next;
        }

        ($major_version, $version, $release) = split(/\./, $tag);
        $release = 0 unless defined $release;

        # Index major_version
        # If major_version is not found in the @major_versions index
        if ( ! grep( /^$major_version$/, @major_versions ) ) {
            push(@major_versions, $major_version);
        }

        #Index version
        # If new index key
        if (!exists $versions{$major_version}) {
            $versions{$major_version} = ();
        }

        # If version is not found in the @versions index
        if ( ! grep( /^$major_version\.$version$/, @{ $versions{$major_version} } ) ) {
            push @{ $versions{$major_version} }, "$major_version.$version"
        }

        #Index release
        # If new index key
        if (!exists $releases{"$major_version.$version"}) {
            $releases{"$major_version.$version"} = ();
        }

        # If release is not found in the @releases index
        if ( ! grep( /^$tag$/, @{ $releases{"$major_version.$version"} } ) ) {
            push @{ $releases{"$major_version.$version"} }, $tag
        }

        if ($release != 0) {
            if ( ! grep( /^$tag$/, @{ $releases{"$major_version.$version"} } ) ) {
                push @{ $releases{"$major_version.$version"} }, $tag
            }
        }
    }

    return ( 'major_versions'   => \@major_versions,
	         'versions'         => \%versions, 
    	     'releases'         => \%releases )
}

# Gets a list of the WordPress tags from the official SVN
sub get_tag_list {
    my @list=`svn ls https://core.svn.wordpress.org/tags`;
    my @tags;

    # Format the version tags
    foreach my $tag (@list) {
        # remove all characters except number and period
        $tag =~ s/[^0-9.]//g;
        push(@tags, $tag);
    }

    return @tags;
}

# Produces a list of live WordPress images on github packeges
sub get_live_image_list {
    my $token = shift;
    my $formatted; my @tags; my @images;
    my $package_res = get_github_packages($token);
    my @packages = @{decode_json($package_res)};

    foreach my $package (@packages) {
        @tags = @{$package->{'metadata'}->{'container'}->{'tags'}};
        foreach my $tag (@tags) {
            $tag =~ s/[^0-9.]//;
            push(@images, $tag);
        }
    }

    return reverse( sort( @images ) );
}

# Query Github API for Packages.
sub get_github_packages {
    my $token = shift;
    my $url = 'https://api.github.com/orgs/Automattic/packages/container/vip-container-images%2Fwordpress/versions?per_page=100&repo=vip-container-images&package_type=container';
    my $header = [
        'Authorization' => "Bearer $token",
        'User-Agent'    => 'VIP',
        'Accept'        => 'application/vnd.github.v3+json'
    ];

    my $r = HTTP::Request->new('GET', $url, $header);
    my $ua = LWP::UserAgent->new();
    my $res = $ua->request($r);

    if ($res->is_success) {
        return $res->decoded_content;
    } else {
        die $res->status_line;
    }
}

# Read the content of configure file.
sub read_cfg_file {
    my $file = shift;
    return unless defined $file && -e $file;
    my @lines;

    open( my $fh, '<', $file ) or die( "Unable to read $file: $!" );
    while ( my $line = <$fh> ) {
        chomp $line;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next if $line eq '';
        next if $line =~ /^#/;

        push( @lines, $line );
    }
    close $fh;

    return @lines;
}

# Return the config as a hash table.
sub get_config {
    my $file = shift;
    return unless defined $file && -e $file;
    my %config;
    my @pair;
    my $line;

    foreach $line (read_cfg_file($file)) {
        @pair = split('=', $line);
        $config{$pair[0]} = $pair[1];
    }

    return %config;
}

# Prints the results of the command to the console.
sub command_result {
    my ($exit, $err, $operation_str, @cmd) = @_;

    if ($exit == -1) {
        print "failed to execute: $err \n";
        exit $exit;
    }
    elsif ($exit & 127) {
        printf "child died with signal %d, %s coredump\n",
            ($exit & 127),  ($exit & 128) ? 'with' : 'without';
        exit $exit;
    }
    else {
        printf "$operation_str exited with value %d\n", $exit >> 8;
    }
}

