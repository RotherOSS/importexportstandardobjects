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

## no critic (Modules::RequireExplicitPackage)

use Kernel::System::Group ();    ## no perlimports

package Kernel::System::Group;   ## no critic (Modules::RequireFilenameMatchesPackage)

use strict;
use warnings;
use v5.24;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::Group',
    'Kernel::System::Valid',
);

sub ExportRoles {
    my ( $Self, %Param ) = @_;

    my %RoleFilter;
    if ( IsArrayRefWithData( $Param{Roles} ) ) {
        %RoleFilter = map { $_ => 1 } $Param{Roles}->@*;
    }

    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');

    my %RoleList = $GroupObject->RoleList(
        Valid => 0,
    );

    my %ExportData;
    ROLEID:
    for my $RoleID ( sort keys %RoleList ) {

        my %RoleData = $GroupObject->RoleGet(
            ID => $RoleID,
        );

        if (%RoleFilter) {
            next ROLEID unless $RoleFilter{ $RoleData{Name} };
        }

        # translate IDs into names or name-like identifiers
        my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');

        ATTRIBUTE:
        for my $Attribute ( keys %RoleData ) {

            next ATTRIBUTE unless $Attribute =~ /ID/;

            if ( $Attribute eq 'ValidID' ) {
                my $Valid = $ValidObject->ValidLookup(
                    ValidID => $RoleData{ValidID},
                );
                $RoleData{Valid} = $Valid;
                delete $RoleData{ValidID};
            }
        }

        delete $RoleData{ChangeBy};
        delete $RoleData{ChangeTime};
        delete $RoleData{CreateBy};
        delete $RoleData{CreateTime};
        delete $RoleData{ID};

        $ExportData{ $RoleData{Name} } = \%RoleData;
    }

    return \%ExportData;
}

sub ImportRoles {
    my ( $Self, %Param ) = @_;

    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
    my $ValidObject = $Kernel::OM->Get('Kernel::System::Valid');
    my %RoleList    = $GroupObject->RoleList(
        Valid => 0,
    );
    my %RoleLookup = reverse %RoleList;

    ROLENAME:
    for my $RoleName ( keys $Param{Roles}->%* ) {
        my $RoleData = $Param{Roles}{$RoleName};

        my $RoleID = $RoleLookup{ $RoleData->{Name} };

        # skip if role with same name exists and overwrite is not set
        next ROLENAME if ( !$Param{OverwriteExistingEntities} && $RoleID );

        # translate named data back to IDs
        $RoleData->{ValidID} = $ValidObject->ValidLookup(
            Valid => $RoleData->{Valid},
        );

        if ($RoleID) {
            my $Success = $GroupObject->RoleUpdate(
                $RoleData->%*,
                ID     => $RoleID,
                UserID => $Self->{UserID},
            );
            next ROLENAME unless $Success;
        }
        else {
            my $RoleID = $GroupObject->RoleAdd(
                $RoleData->%*,
                UserID => $Self->{UserID},
            );
            next ROLENAME unless $RoleID;
        }
    }

    return;
}

1;
