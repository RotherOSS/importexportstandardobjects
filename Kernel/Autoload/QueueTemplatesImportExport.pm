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

use Kernel::System::Queue ();    ## no perlimports

package Kernel::System::Queue;   ## no critic (Modules::RequireFilenameMatchesPackage)

use strict;
use warnings;
use v5.24;
use utf8;

# core modules

# CPAN modules

# OTOBO modules
use Kernel::System::VariableCheck qw(IsArrayRefWithData);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Group',
    'Kernel::System::Queue',
    'Kernel::System::Salutation',
    'Kernel::System::Signature',
    'Kernel::System::SystemAddress',
    'Kernel::System::Valid',
);

sub ExportQueueTemplates {
    my ( $Self, %Param ) = @_;

    my %QueueFilter;
    if ( IsArrayRefWithData( $Param{Queues} ) ) {
        %QueueFilter = map { $_ => 1 } $Param{Queues}->@*;
    }

    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

    my %QueueList = $QueueObject->QueueList(
        Valid => 0,
    );

    my %ExportData;
    QUEUEID:
    for my $QueueID ( sort keys %QueueList ) {

        my %QueueData = $QueueObject->QueueGet(
            ID => $QueueID,
        );

        if (%QueueFilter) {
            next QUEUEID unless $QueueFilter{ $QueueData{Name} };
        }

        # translate IDs into names or name-like identifiers
        my $GroupObject         = $Kernel::OM->Get('Kernel::System::Group');
        my $SalutationObject    = $Kernel::OM->Get('Kernel::System::Salutation');
        my $SignatureObject     = $Kernel::OM->Get('Kernel::System::Signature');
        my $SystemAddressObject = $Kernel::OM->Get('Kernel::System::SystemAddress');
        my $ValidObject         = $Kernel::OM->Get('Kernel::System::Valid');
        my %FollowUpOptions     = $QueueObject->GetFollowUpOptionList(
            Valid => 0,
        );

        ATTRIBUTE:
        for my $Attribute ( keys %QueueData ) {

            next ATTRIBUTE unless $Attribute =~ /ID/;

            if ( $Attribute eq 'ValidID' ) {
                my $Valid = $ValidObject->ValidLookup(
                    ValidID => $QueueData{ValidID},
                );
                $QueueData{Valid} = $Valid;
                delete $QueueData{ValidID};
            }
            elsif ( $Attribute eq 'FollowUpID' ) {
                $QueueData{FollowUp} = $FollowUpOptions{ $QueueData{FollowUpID} };
                delete $QueueData{FollowUpID};
            }
            elsif ( $Attribute eq 'GroupID' ) {
                my $Group = $GroupObject->GroupLookup(
                    GroupID => $QueueData{GroupID},
                );
                $QueueData{Group} = $Group;
                delete $QueueData{GroupID};
            }
            elsif ( $Attribute eq 'SalutationID' ) {
                my %Salutation = $SalutationObject->SalutationGet(
                    ID => $QueueData{SalutationID},
                );

                # transform IDs into names and clean up unnecessary attributes
                $Salutation{Valid} = $ValidObject->ValidLookup(
                    ValidID => $Salutation{ValidID},
                );
                delete $Salutation{ValidID};

                delete $Salutation{ChangeTime};
                delete $Salutation{CreateTime};
                delete $Salutation{ID};

                $QueueData{Salutation} = \%Salutation;
                delete $QueueData{SalutationID};
            }
            elsif ( $Attribute eq 'SignatureID' ) {
                my %Signature = $SignatureObject->SignatureGet(
                    ID => $QueueData{SignatureID},
                );

                # transform IDs into names and clean up unnecessary attributes
                $Signature{Valid} = $ValidObject->ValidLookup(
                    ValidID => $Signature{ValidID},
                );
                delete $Signature{ValidID};

                delete $Signature{ChangeTime};
                delete $Signature{CreateTime};
                delete $Signature{ID};

                $QueueData{Signature} = \%Signature;
                delete $QueueData{SignatureID};
            }
            elsif ( $Attribute eq 'SystemAddressID' ) {
                my %SystemAddress = $SystemAddressObject->SystemAddressGet(
                    ID => $QueueData{SystemAddressID},
                );

                # transform IDs into names and clean up unnecessary attributes
                $SystemAddress{Valid} = $ValidObject->ValidLookup(
                    ValidID => $SystemAddress{ValidID},
                );
                delete $SystemAddress{ValidID};
                $SystemAddress{Queue} = $QueueList{ $SystemAddress{QueueID} };
                delete $SystemAddress{QueueID};

                delete $SystemAddress{ChangeTime};
                delete $SystemAddress{CreateTime};
                delete $SystemAddress{ID};

                $QueueData{SystemAddress} = \%SystemAddress;
                delete $QueueData{SystemAddressID};
            }
        }

        delete $QueueData{ChangeTime};
        delete $QueueData{CreateTime};
        delete $QueueData{Email};
        delete $QueueData{QueueID};
        delete $QueueData{Realname};

        $ExportData{ $QueueData{Name} } = \%QueueData;
    }

    return \%ExportData;
}

sub ImportQueueTemplates {
    my ( $Self, %Param ) = @_;

    my $UserID = $Self->{UserID} || $Param{UserID};

    my $GroupObject         = $Kernel::OM->Get('Kernel::System::Group');
    my $QueueObject         = $Kernel::OM->Get('Kernel::System::Queue');
    my $SalutationObject    = $Kernel::OM->Get('Kernel::System::Salutation');
    my $SignatureObject     = $Kernel::OM->Get('Kernel::System::Signature');
    my $SystemAddressObject = $Kernel::OM->Get('Kernel::System::SystemAddress');
    my $ValidObject         = $Kernel::OM->Get('Kernel::System::Valid');
    my %FollowUpOptionList  = $QueueObject->GetFollowUpOptionList(
        Valid => 0,
    );
    my %FollowUpOptionLookup = reverse %FollowUpOptionList;
    my %QueueList            = $QueueObject->QueueList(
        Valid => 0,
    );
    my %QueueLookup    = reverse %QueueList;
    my %SalutationList = $SalutationObject->SalutationList(
        Valid => 0,
    );
    my %SalutationLookup = reverse %SalutationList;
    my %SignatureList    = $SignatureObject->SignatureList(
        Valid => 0,
    );
    my %SignatureLookup   = reverse %SignatureList;
    my %SystemAddressList = $SystemAddressObject->SystemAddressList(
        Valid => 0,
    );
    my %SystemAddressLookup = reverse %SystemAddressList;

    QUEUENAME:
    for my $QueueName ( keys $Param{Queues}->%* ) {
        my $QueueData = $Param{Queues}{$QueueName};

        # in case of child queue, check if all parent queues are present
        #   either in the system or in the import data
        my @NameElements = split( /::/, $QueueData->{Name} );

        # check if queue levels conform to system configuration
        my $MaxQueueLevel = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Frontend::MaxQueueLevel');
        if ( scalar @NameElements > $MaxQueueLevel ) {
            next QUEUENAME;
        }

        if ( scalar @NameElements > 1 ) {
            my $NameStrg = '';
            for my $Index ( 0 .. $#NameElements - 1 ) {
                $NameStrg .= $NameElements[$Index];

                if ( !$QueueLookup{$NameStrg} && !$Param{Queues}{$NameStrg} ) {

                    # parent element not found, skipping
                    next QUEUENAME;
                }
            }
        }

        my $QueueID = $QueueLookup{ $QueueData->{Name} };

        # skip if queue with same name exists and overwrite is not set
        next QUEUENAME if ( !$Param{OverwriteExistingEntities} && $QueueID );

        # create or update necessary previous objects
        if ( $QueueData->{Salutation} ) {
            my %Salutation = $QueueData->{Salutation}->%*;

            # transform names back to IDs where necessary
            $Salutation{ValidID} = $ValidObject->ValidLookup(
                Valid => $Salutation{Valid},
            );

            # check if salutation already exists
            my $SalutationID = $SalutationLookup{ $Salutation{Name} };

            if ( $SalutationID && $Param{OverwriteExistingEntities} ) {
                my $Success = $SalutationObject->SalutationUpdate(
                    %Salutation,
                    ID     => $SalutationID,
                    UserID => $UserID,
                );

                next QUEUENAME unless $Success;
            }
            elsif ( !$SalutationID ) {
                $SalutationID = $SalutationObject->SalutationAdd(
                    %Salutation,
                    UserID => $UserID,
                );
            }
            $QueueData->{SalutationID} = $SalutationID;
        }
        if ( $QueueData->{Signature} ) {
            my %Signature = $QueueData->{Signature}->%*;

            # transform names back to IDs where necessary
            $Signature{ValidID} = $ValidObject->ValidLookup(
                Valid => $Signature{Valid},
            );

            # check if salutation already exists
            my $SignatureID = $SignatureLookup{ $Signature{Name} };

            if ( $SignatureID && $Param{OverwriteExistingEntities} ) {
                my $Success = $SignatureObject->SignatureUpdate(
                    %Signature,
                    ID     => $SignatureID,
                    UserID => $UserID,
                );

                next QUEUENAME unless $Success;
            }
            elsif ( !$SignatureID ) {
                $SignatureID = $SignatureObject->SignatureAdd(
                    %Signature,
                    UserID => $UserID,
                );
            }
            $QueueData->{SignatureID} = $SignatureID;
        }

        # translate named data back to IDs
        $QueueData->{FollowUpID} = $FollowUpOptionLookup{ $QueueData->{FollowUp} };
        $QueueData->{GroupID}    = $GroupObject->GroupLookup(
            Group => $QueueData->{Group},
        );
        $QueueData->{ValidID} = $ValidObject->ValidLookup(
            Valid => $QueueData->{Valid},
        );

        if ($QueueID) {

            # get system address id and set it
            if ( $QueueData->{SystemAddress} ) {
                my %SystemAddress = $QueueData->{SystemAddress}->%*;

                # transform names back to IDs where necessary
                $SystemAddress{ValidID} = $ValidObject->ValidLookup(
                    Valid => $SystemAddress{Valid},
                );

                # TODO use $QueueID instead...?
                $SystemAddress{QueueID} = $QueueObject->QueueLookup(
                    Queue => $SystemAddress{Queue},
                );

                my $SystemAddressID = $SystemAddressLookup{ $SystemAddress{Name} };

                if ( $SystemAddressID && $Param{OverwriteExistingEntities} ) {
                    my $Success = $SystemAddressObject->SystemAddressUpdate(
                        %SystemAddress,
                        ID     => $SystemAddressLookup{ $SystemAddress{Name} },
                        UserID => $UserID,
                    );

                    next QUEUENAME unless $Success;
                }
                elsif ( !$SystemAddressID ) {
                    $SystemAddressID = $SystemAddressObject->SystemAddressAdd(
                        %SystemAddress,
                        UserID => $UserID,
                    );
                }
                $QueueData->{SystemAddressID} = $SystemAddressID;
            }

            my $Success = $QueueObject->QueueUpdate(
                $QueueData->%*,
                QueueID => $QueueID,
                UserID  => $UserID,
            );
            next QUEUENAME unless $Success;
        }
        else {
            my $QueueID = $QueueObject->QueueAdd(
                $QueueData->%*,
                UserID => $UserID,
            );
            next QUEUENAME unless $QueueID;

            # system address needs QueueID as attribute
            if ( $QueueData->{SystemAddress} ) {
                my %SystemAddress = $QueueData->{SystemAddress}->%*;

                # transform names back to IDs where necessary
                $SystemAddress{ValidID} = $ValidObject->ValidLookup(
                    Valid => $SystemAddress{Valid},
                );

                # TODO use $QueueID instead...?
                $SystemAddress{QueueID} = $QueueObject->QueueLookup(
                    Queue => $SystemAddress{Queue},
                );

                my $SystemAddressID = $SystemAddressLookup{ $SystemAddress{Name} };

                if ( $SystemAddressID && $Param{OverwriteExistingEntities} ) {
                    my $Success = $SystemAddressObject->SystemAddressUpdate(
                        %SystemAddress,
                        ID     => $SystemAddressLookup{ $SystemAddress{Name} },
                        UserID => $UserID,
                    );

                    next QUEUENAME unless $Success;
                }
                elsif ( !$SystemAddressID ) {
                    $SystemAddressID = $SystemAddressObject->SystemAddressAdd(
                        %SystemAddress,
                        UserID => $UserID,
                    );
                }

                # update queue and set system address id
                my $Success = $QueueObject->QueueUpdate(
                    $QueueData->%*,
                    QueueID         => $QueueID,
                    SystemAddressID => $SystemAddressID,
                    UserID          => $UserID,
                );
                next QUEUENAME unless $Success;
            }
        }
    }

    return;
}

1;
