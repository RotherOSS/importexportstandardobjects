# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2012-2020 Znuny GmbH, http://znuny.com/
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

package Kernel::Modules::AdminGroupImportExport;

use strict;
use warnings;

# core modules
use List::AllUtils qw(first);

# CPAN modules

# OTOBO modules
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Cache',
    'Kernel::System::Group',
    'Kernel::System::Log',
    'Kernel::System::Valid',
    'Kernel::System::Web::Request',
    'Kernel::System::YAML',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $YAMLObject   = $Kernel::OM->Get('Kernel::System::YAML');
    my $CacheObject  = $Kernel::OM->Get('Kernel::System::Cache');

    $Self->{Subaction} = $ParamObject->GetParam( Param => 'Subaction' ) || '';

    # ------------------------------------------------------------ #
    # Import
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Import' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my %UploadStuff = $ParamObject->GetUploadAll(
            Param => 'FileUpload',
        );

        my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' );

        my $PerlStructure = $YAMLObject->Load(
            Data => $UploadStuff{Content},
        );

        $CacheObject->Set(
            Type  => 'AdminGroupImportExport',
            Key   => 'AdminGroupImportExport::' . $Self->{UserID},
            Value => $PerlStructure,
            TTL   => 60 * 60,
        );

        return $Self->_Mask(
            Data                      => $PerlStructure,
            Type                      => $Self->{Subaction},
            OverwriteExistingEntities => $OverwriteExistingEntities || 0,
        );
    }

    # ------------------------------------------------------------ #
    # ImportAction
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ImportAction' ) {

        my $ImportData = $CacheObject->Get(
            Type => 'AdminGroupImportExport',
            Key  => 'AdminGroupImportExport::' . $Self->{UserID},
        );

        if ( !IsHashRefWithData($ImportData) ) {

            # redirect to AdminGroup
            my $HTML = $LayoutObject->Redirect(
                OP => "Action=AdminGroup"
            );

            return $HTML;
        }

        # check required parameters
        my @GroupsSelected            = $ParamObject->GetArray( Param => 'Groups' );
        my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || 0;

        $CacheObject->Delete(
            Type => 'AdminGroupImportExport',
            Key  => 'AdminGroupImportExport::' . $Self->{UserID},
        );

        # ------------------------------------------------------------ #
        # Import Groups
        # ------------------------------------------------------------ #
        if ( IsHashRefWithData( $ImportData->{Groups} ) ) {

            my %GroupsImport;
            GROUPNAME:
            for my $GroupName ( keys $ImportData->{Groups}->%* ) {

                my $Selected = grep { $GroupName eq $_ } @GroupsSelected;
                next GROUPNAME if !$Selected;

                next GROUPNAME if !IsHashRefWithData( $ImportData->{Groups}{$GroupName} );

                $GroupsImport{$GroupName} = $ImportData->{Groups}{$GroupName};
            }

            $Self->_ImportGroups(
                Groups                    => \%GroupsImport,
                OverwriteExistingEntities => $OverwriteExistingEntities,
            );
        }

        # redirect to AdminGroup
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminGroup"
        );

        return $HTML;
    }

    # ------------------------------------------------------------ #
    # Export
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Export' ) {

        return $Self->_Mask(
            %Param,
            Type => $Self->{Subaction},
        );

    }

    # ------------------------------------------------------------ #
    # ExportAction
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ExportAction' ) {

        # check required parameters
        my @Groups = $ParamObject->GetArray( Param => 'Groups' );

        my %Data;
        my $HTML;

        if (@Groups) {

            $Data{Groups} = $Self->_ExportGroups(
                Groups => \@Groups,
            );
        }

        if ( !%Data ) {

            # redirect to AdminGroupImportExport
            $HTML .= $LayoutObject->Redirect(
                OP => "Action=AdminGroupImportExport;Subaction=Export",
            );
            return $HTML;
        }

        # convert the group data hash to string
        my $GroupDataYAML = $YAMLObject->Dump( Data => \%Data );

        # Get the current time formatted like '2016-01-31 14:05:45'.
        # Hoping that nobody has registered object params for Kernel::System::DateTime
        my $TimeStamp = $Kernel::OM->Create('Kernel::System::DateTime')->ToString();

        # send the result to the browser
        $HTML = $LayoutObject->Attachment(
            ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
            Content     => $GroupDataYAML,
            Type        => 'attachment',
            Filename    => "Export_Groups_$TimeStamp.yml",
            NoCache     => 1,
        );

        return $HTML;

    }

    # ------------------------------------------------------------ #
    # ------------------------------------------------------------ #
    else {

        # redirect to AdminGroup
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminGroup"
        );

        return $HTML;
    }

    return;
}

sub _Mask {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');

    $LayoutObject->Block( Name => 'ActionOverview' );

    # call hint block
    $LayoutObject->Block(
        Name => $Param{Type} . 'Hint',
        Data => {
            %Param,
        },
    );

    if ( !$Param{Data} ) {

        $Param{Data}{Groups} = {};

        # export
        my %Groups = $GroupObject->GroupList(
            Valid => 0,
        );

        # get queue data
        for my $GroupID ( keys %Groups ) {
            my %GroupData = $GroupObject->GroupGet(
                ID => $GroupID,
            );

            $Param{Data}{Groups}{ $GroupData{Name} } = \%GroupData;
        }
    }

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # print the list of queues
    $Self->_GroupShow(
        %Param,
    );

    # output header
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminGroupImportExport',
        Data         => {
            %Param,
        },
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GroupShow {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');

    if ( IsHashRefWithData( $Param{Data}{Groups} ) ) {

        my @GroupsAlreadyUsed;

        GROUPNAME:
        for my $GroupName ( keys $Param{Data}{Groups}->%* ) {

            my $GroupData = $Param{Data}{Groups}{$GroupName};

            push @GroupsAlreadyUsed, $GroupData->{Name};

            next GROUPNAME if !IsHashRefWithData($GroupData);

            # convert ValidID to Validity string
            my $Valid = $GroupData->{Valid} || $ValidObject->ValidLookup(
                ValidID => $GroupData->{ValidID},
            );

            my %GroupData = (
                %{$GroupData},
                Valid => $Valid,
            );

            for my $Blocks ( 'GroupsRow', 'GroupCheckbox', $Param{Type} ) {

                # print each queue row
                $LayoutObject->Block(
                    Name => $Blocks,
                    Data => {
                        %GroupData,
                    },
                );
            }
        }
    }

    # otherwise show a no data found message
    else {
        $LayoutObject->Block(
            Name => 'NoDataFound',
            Data => \%Param,
        );
    }

    return;
}

sub _ExportGroups {
    my ( $Self, %Param ) = @_;

    my %GroupFilter;
    if ( IsArrayRefWithData( $Param{Groups} ) ) {
        %GroupFilter = map { $_ => 1 } $Param{Groups}->@*;
    }

    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');

    my %GroupList = $GroupObject->GroupList(
        Valid => 0,
    );

    my %ExportData;
    GROUPID:
    for my $GroupID ( sort keys %GroupList ) {

        my %GroupData = $GroupObject->GroupGet(
            ID => $GroupID,
        );

        if (%GroupFilter) {
            next GROUPID unless $GroupFilter{ $GroupData{Name} };
        }

        # translate IDs into names or name-like identifiers
        my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');

        ATTRIBUTE:
        for my $Attribute ( keys %GroupData ) {

            next ATTRIBUTE unless $Attribute =~ /ID/;

            if ( $Attribute eq 'ValidID' ) {
                my $Valid = $ValidObject->ValidLookup(
                    ValidID => $GroupData{ValidID},
                );
                $GroupData{Valid} = $Valid;
                delete $GroupData{ValidID};
            }
        }

        delete $GroupData{ChangeBy};
        delete $GroupData{ChangeTime};
        delete $GroupData{CreateBy};
        delete $GroupData{CreateTime};
        delete $GroupData{ID};

        $ExportData{ $GroupData{Name} } = \%GroupData;
    }

    return \%ExportData;
}

sub _ImportGroups {
    my ( $Self, %Param ) = @_;

    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
    my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');
    my %GroupList   = $GroupObject->GroupList(
        Valid => 0,
    );
    my %GroupLookup = reverse %GroupList;

    GROUPNAME:
    for my $GroupName ( keys $Param{Groups}->%* ) {
        my $GroupData = $Param{Groups}{$GroupName};

        my $GroupID = $GroupLookup{ $GroupData->{Name} };

        # skip if group with same name exists and overwrite is not set
        next GROUPNAME if ( !$Param{OverwriteExistingEntities} && $GroupID );

        # translate named data back to IDs
        $GroupData->{ValidID} = $ValidObject->ValidLookup(
            Valid => $GroupData->{Valid},
        );

        if ($GroupID) {
            my $Success = $GroupObject->GroupUpdate(
                $GroupData->%*,
                ID     => $GroupID,
                UserID => $Self->{UserID},
            );
            next GROUPNAME unless $Success;
        }
        else {
            my $GroupID = $GroupObject->GroupAdd(
                $GroupData->%*,
                UserID => $Self->{UserID},
            );
            next GROUPNAME unless $GroupID;
        }
    }

    return;
}

1;
