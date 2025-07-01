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

package Kernel::Modules::AdminQueueImportExport;

use strict;
use warnings;

# core modules
use List::AllUtils qw(first);

# CPAN modules

# OTOBO modules
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Cache',
    'Kernel::System::Group',
    'Kernel::System::Log',
    'Kernel::System::Queue',
    'Kernel::System::Salutation',
    'Kernel::System::Signature',
    'Kernel::System::SystemAddress',
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
            Type  => 'AdminQueueImportExport',
            Key   => 'AdminQueueImportExport::' . $Self->{UserID},
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
            Type => 'AdminQueueImportExport',
            Key  => 'AdminQueueImportExport::' . $Self->{UserID},
        );

        if ( !IsHashRefWithData($ImportData) ) {

            # redirect to AdminQueue
            my $HTML = $LayoutObject->Redirect(
                OP => "Action=AdminQueue"
            );

            return $HTML;
        }

        # check required parameters
        my @QueuesSelected            = $ParamObject->GetArray( Param => 'Queues' );
        my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || 0;

        $CacheObject->Delete(
            Type => 'AdminQueueImportExport',
            Key  => 'AdminQueueImportExport::' . $Self->{UserID},
        );

        # ------------------------------------------------------------ #
        # Import Queues
        # ------------------------------------------------------------ #
        if ( IsArrayRefWithData( $ImportData->{Queues} ) ) {

            my @QueuesImport;
            QUEUEINDEX:
            for my $QueueIndex ( 0 .. $#{ $ImportData->{Queues} } ) {

                my $Selected = grep { $ImportData->{Queues}[$QueueIndex]{Name} eq $_ } @QueuesSelected;
                next QUEUE if !$Selected;

                next QUEUE if !IsHashRefWithData( $ImportData->{Queues}[$QueueIndex] );

                push @QueuesImport, $ImportData->{Queues}[$QueueIndex];
            }

            $Self->_ImportQueues(
                Queues                    => \@QueuesImport,
                OverwriteExistingEntities => $OverwriteExistingEntities,
            );
        }

        # redirect to AdminQueue
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminQueue"
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
        my @Queues = $ParamObject->GetArray( Param => 'Queues' );

        my %Data;
        my $HTML;

        if (@Queues) {

            $Data{Queues} = $Self->_ExportQueues(
                Queues => \@Queues,
            );
        }

        if ( !%Data ) {

            # redirect to AdminQueueImportExport
            $HTML .= $LayoutObject->Redirect(
                OP => "Action=AdminQueueImportExport;Subaction=Export",
            );
            return $HTML;
        }

        # convert the queue data hash to string
        my $QueueDataYAML = $YAMLObject->Dump( Data => \%Data );

        # Get the current time formatted like '2016-01-31 14:05:45'.
        # Hoping that nobody has registered object params for Kernel::System::DateTime
        my $TimeStamp = $Kernel::OM->Create('Kernel::System::DateTime')->ToString();

        # send the result to the browser
        $HTML = $LayoutObject->Attachment(
            ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
            Content     => $QueueDataYAML,
            Type        => 'attachment',
            Filename    => "Export_Queues_$TimeStamp.yml",
            NoCache     => 1,
        );

        return $HTML;

    }

    # ------------------------------------------------------------ #
    # ------------------------------------------------------------ #
    else {

        # redirect to AdminQueue
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminQueue"
        );

        return $HTML;
    }

    return;
}

sub _Mask {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $QueueObject  = $Kernel::OM->Get('Kernel::System::Queue');

    $LayoutObject->Block( Name => 'ActionOverview' );

    # call hint block
    $LayoutObject->Block(
        Name => $Param{Type} . 'Hint',
        Data => {
            %Param,
        },
    );

    if ( !$Param{Data} ) {

        $Param{Data}{Queues} = [];

        # export
        my %Queues = $QueueObject->QueueList(
            Valid => 0,
        );

        # get queue data
        for my $QueueID ( keys %Queues ) {
            my %QueueData = $QueueObject->QueueGet(
                ID => $QueueID,
            );

            push $Param{Data}{Queues}->@*, \%QueueData;
        }
    }

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # print the list of queues
    $Self->_QueueShow(
        %Param,
    );

    # output header
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminQueueImportExport',
        Data         => {
            %Param,
        },
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _QueueShow {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');

    # check if at least 1 dynamic field is registered in the system
    if ( IsArrayRefWithData( $Param{Data}{Queues} ) ) {

        my @QueuesAlreadyUsed;

        QUEUEINDEX:
        for my $QueueIndex ( 0 .. $#{ $Param{Data}{Queues} } ) {

            my $QueueData = $Param{Data}{Queues}[$QueueIndex];

            push @QueuesAlreadyUsed, $QueueData->{Name};

            next QUEUE if !IsHashRefWithData($QueueData);

            # convert ValidID to Validity string
            my $Valid = $ValidObject->ValidLookup(
                ValidID => $QueueData->{ValidID},
            );

            my %QueueData = (
                %{$QueueData},
                Valid => $Valid,
            );

            for my $Blocks ( 'QueuesRow', 'QueueCheckbox', $Param{Type} ) {

                # print each queue row
                $LayoutObject->Block(
                    Name => $Blocks,
                    Data => {
                        %QueueData,
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

sub _ExportQueues {
    my ( $Self, %Param ) = @_;

    my %QueueFilter;
    if ( IsArrayRefWithData( $Param{Queues} ) ) {
        %QueueFilter = map { $_ => 1 } $Param{Queues}->@*;
    }

    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

    my %QueueList = $QueueObject->QueueList(
        Valid => 0,
    );

    my @ExportData;
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
                $QueueData{Salutation} = \%Salutation;
                delete $QueueData{SalutationID};
            }
            elsif ( $Attribute eq 'SignatureID' ) {
                my %Signature = $SignatureObject->SignatureGet(
                    ID => $QueueData{SignatureID},
                );
                $QueueData{Signature} = \%Signature;
                delete $QueueData{SignatureID};
            }
            elsif ( $Attribute eq 'SystemAddressID' ) {
                my %SystemAddress = $SystemAddressObject->SystemAddressGet(
                    ID => 1,
                );
                $QueueData{SystemAddress} = \%SystemAddress;
                delete $QueueData{SystemAddressID};
            }
        }

        delete $QueueData{ChangeTime};
        delete $QueueData{CreateTime};
        delete $QueueData{Email};
        delete $QueueData{QueueID};
        delete $QueueData{Realname};

        push @ExportData, \%QueueData;
    }

    return \@ExportData;
}

sub _ImportQueues {
    my ( $Self, %Param ) = @_;

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

    # NOTE
    #   sorting not important as parent queue is not checked anywhere despite in the AdminQueue frontend module
    QUEUEINDEX:
    for my $QueueIndex ( 0 .. $#{ $Param{Queues} } ) {
        my $QueueData = $Param{Queues}[$QueueIndex];

        my $QueueID = $QueueLookup{ $QueueData->{Name} };

        # skip if queue with same name exists and overwrite is not set
        next QUEUEINDEX if ( !$Param{OverwriteExistingEntities} && $QueueID );

        # create or update necessary previous objects
        if ( $QueueData->{Salutation} ) {
            my %Salutation = $QueueData->{Salutation}->%*;

            # check if salutation already exists
            my $SalutationID = $SalutationLookup{ $Salutation{Name} };

            if ( $SalutationID && $Param{OverwriteExistingEntities} ) {
                my $Success = $SalutationObject->SalutationUpdate(
                    %Salutation,
                    ID     => $SalutationID,
                    UserID => $Self->{UserID},
                );
            }
            elsif ( !$SalutationID ) {
                my $SalutationID => $SalutationObject->SalutationAdd(
                    %Salutation,
                    UserID => $Self->{UserID},
                );
            }
        }
        if ( $QueueData->{Signature} ) {
            my %Signature = $QueueData->{Signature}->%*;

            # check if salutation already exists
            my $SignatureID = $SignatureLookup{ $Signature{Name} };

            if ( $SignatureID && $Param{OverwriteExistingEntities} ) {
                my $Success = $SignatureObject->SignatureUpdate(
                    %Signature,
                    ID     => $SignatureID,
                    UserID => $Self->{UserID},
                );
            }
            elsif ( !$SignatureID ) {
                my $SignatureID => $SignatureObject->SignatureAdd(
                    %Signature,
                    UserID => $Self->{UserID},
                );
            }
        }
        if ( $QueueData->{SystemAddress} ) {
            my %SystemAddress = $QueueData->{SystemAddress}->%*;

            my $SystemAddressID = $SystemAddressLookup{ $SystemAddress{Name} };

            if ( $SystemAddressID && $Param{OverwriteExistingEntities} ) {
                my $Success = $SystemAddressObject->SystemAddressUpdate(
                    %SystemAddress,
                    ID     => $SystemAddressLookup{ $SystemAddress{Name} },
                    UserID => $Self->{UserID},
                );
            }
            elsif ( !$SystemAddressID ) {
                my $SystemAddressID = $SystemAddressObject->SystemAddressAdd(
                    %SystemAddress,
                    UserID => $Self->{UserID},
                );
            }
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
            my $Success = $QueueObject->QueueUpdate(
                $QueueData->%*,
                QueueID => $QueueID,
                UserID  => $Self->{UserID},
            );
            next QUEUEINDEX unless $Success;
        }
        else {
            my $QueueID = $QueueObject->QueueAdd(
                $QueueData->%*,
                UserID => $Self->{UserID},
            );
            next QUEUEINDEX unless $QueueID;
        }
    }

    return;
}

1;
