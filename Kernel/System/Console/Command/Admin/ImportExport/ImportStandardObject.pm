# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2025 Rother OSS GmbH, https://otobo.io/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package Kernel::System::Console::Command::Admin::ImportExport::ImportStandardObject;

use strict;
use warnings;

# core modules

# CPAN modules

# OTOBO modules
use Kernel::System::VariableCheck qw(IsHashRefWithData);

use parent qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::System::GenericAgent',
    'Kernel::System::Group',
    'Kernel::System::Main',
    'Kernel::System::Queue',
    'Kernel::System::StandardTemplate',
    'Kernel::System::YAML',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('<TBD>.');
    $Self->AddOption(
        Name        => 'update',
        Description => "Flag if existing objects should be overwritten.",
        Required    => 0,
        HasValue    => 0,
        ValueRegex  => qr/.*/smx,
    );
    $Self->AddArgument(
        Name        => 'source',
        Description => "Specify the path to the file or directory which contains the data for importing.",
        Required    => 1,
        ValueRegex  => qr/.*/,
    );

    return;
}

sub PreRun {
    my ( $Self, %Param ) = @_;

    my $Source = $Self->GetArgument('source');
    if ( !$Source ) {

        # source is optional, even if an import without source is unsatisfying
    }
    elsif ( -d $Source ) {

        # a directory is fine
    }
    elsif ( -r $Source ) {

        # a readable file is fine
    }
    else {
        die "The source $Source does not exist or can not be read.";
    }

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Meaningful start message...</yellow>\n");

    # get (probably) necessary objects
    my $GenericAgentObject     = $Kernel::OM->Get('Kernel::System::GenericAgent');
    my $GroupObject            = $Kernel::OM->Get('Kernel::System::Group');
    my $QueueObject            = $Kernel::OM->Get('Kernel::System::Queue');
    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');
    my $YAMLObject             = $Kernel::OM->Get('Kernel::System::YAML');

    # object to sub mapping
    my %ImportSubMapping = (
        GenericAgent => sub {
            return $GenericAgentObject->ImportGenericAgents(
                @_,
            );
        },
        Group => sub {
            return $GroupObject->ImportGroups(
                @_,
            );
        },
        Queue => sub {
            return $QueueObject->ImportQueues(
                @_,
            );
        },
        Role => sub {
            return $GroupObject->ImportRoles(
                @_,
            );
        },
        StandardTemplate => sub {
            return $StandardTemplateObject->ImportTemplates(
                @_,
            );
        },
    );

    # fetch params
    my $File                      = $Self->GetArgument('source') || '';
    my $OverwriteExistingEntities = $Self->GetOption('update')   || 0;

    # shortcut for error printing
    my $Error = sub {
        $Self->Print("<red>$_[0]</red>\n");

        $Self->ExitCodeError();
    };

    # read file
    my $RawInput = $Kernel::OM->Get('Kernel::System::Main')->FileRead(
        Location => $File,
    );

    my $YAMLData = $YAMLObject->Load(
        Data => ${$RawInput},
    );

    if ( !IsHashRefWithData($YAMLData) ) {
        $Error->('The input file does not have the necessary structure.');
    }

    my ($RawObjectType) = keys $YAMLData->%*;

    # strip plural-s from object type
    my $ObjectType = $RawObjectType;
    if ( $RawObjectType =~ /(?<ObjectType>\w+)s$/ ) {
        $ObjectType = $+{ObjectType};
    }

    if ( !$ImportSubMapping{$ObjectType} ) {
        $Error->("Object type '$ObjectType' is not importable via this console command.");
    }

    my $ImportSuccess = $ImportSubMapping{$ObjectType}->(
        $RawObjectType            => $YAMLData->{$ObjectType},
        OverwriteExistingEntities => $OverwriteExistingEntities,
    );

    if ( !$ImportSuccess ) {
        $Error->('Import failed. Please review the logs for more information.');
    }

    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}

# sub PostRun {
#     my ( $Self, %Param ) = @_;
#
#     # This will be called after Run() (even in case of exceptions). Perform any cleanups here.
#
#     return;
# }

1;
