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

package Kernel::Modules::AdminGenericAgentImportExport;

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
    'Kernel::System::GenericAgent',
    'Kernel::System::Lock',
    'Kernel::System::Log',
    'Kernel::System::Priority',
    'Kernel::System::Queue',
    'Kernel::System::State',
    'Kernel::System::User',
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
            Type  => 'AdminGenericAgentImportExport',
            Key   => 'AdminGenericAgentImportExport::' . $Self->{UserID},
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
            Type => 'AdminGenericAgentImportExport',
            Key  => 'AdminGenericAgentImportExport::' . $Self->{UserID},
        );

        if ( !IsHashRefWithData($ImportData) ) {

            # redirect to AdminGenericAgent
            my $HTML = $LayoutObject->Redirect(
                OP => "Action=AdminGenericAgent"
            );

            return $HTML;
        }

        # check required parameters
        my @GenericAgentsSelected     = $ParamObject->GetArray( Param => 'GenericAgents' );
        my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || 0;

        $CacheObject->Delete(
            Type => 'AdminGenericAgentImportExport',
            Key  => 'AdminGenericAgentImportExport::' . $Self->{UserID},
        );

        # ------------------------------------------------------------ #
        # Import GenericAgents
        # ------------------------------------------------------------ #
        if ( IsHashRefWithData( $ImportData->{GenericAgents} ) ) {

            my %GenericAgentsImport;
            GENERICAGENTNAME:
            for my $GenericAgentName ( keys $ImportData->{GenericAgents}->%* ) {

                my $Selected = grep { $GenericAgentName eq $_ } @GenericAgentsSelected;
                next GENERICAGENTNAME if !$Selected;

                next GENERICAGENTNAME if !IsHashRefWithData( $ImportData->{GenericAgents}{$GenericAgentName} );

                $GenericAgentsImport{$GenericAgentName} = $ImportData->{GenericAgents}{$GenericAgentName};
            }

            $Self->_ImportGenericAgents(
                GenericAgents             => \%GenericAgentsImport,
                OverwriteExistingEntities => $OverwriteExistingEntities,
            );
        }

        # redirect to AdminGenericAgent
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminGenericAgent"
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
        my @GenericAgents = $ParamObject->GetArray( Param => 'GenericAgents' );

        my %Data;
        my $HTML;

        if (@GenericAgents) {

            $Data{GenericAgents} = $Self->_ExportGenericAgents(
                GenericAgents => \@GenericAgents,
            );
        }

        if ( !%Data ) {

            # redirect to AdminGenericAgentImportExport
            $HTML .= $LayoutObject->Redirect(
                OP => "Action=AdminGenericAgentImportExport;Subaction=Export",
            );
            return $HTML;
        }

        # convert the generic agent data hash to string
        my $GenericAgentDataYAML = $YAMLObject->Dump( Data => \%Data );

        # Get the current time formatted like '2016-01-31 14:05:45'.
        # Hoping that nobody has registered object params for Kernel::System::DateTime
        my $TimeStamp = $Kernel::OM->Create('Kernel::System::DateTime')->ToString();

        # send the result to the browser
        $HTML = $LayoutObject->Attachment(
            ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
            Content     => $GenericAgentDataYAML,
            Type        => 'attachment',
            Filename    => "Export_GenericAgents_$TimeStamp.yml",
            NoCache     => 1,
        );

        return $HTML;
    }

    # ------------------------------------------------------------ #
    # ------------------------------------------------------------ #
    else {

        # redirect to AdminGenericAgent
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminGenericAgent"
        );

        return $HTML;
    }

    return;
}

sub _Mask {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $GenericAgentObject = $Kernel::OM->Get('Kernel::System::GenericAgent');

    $LayoutObject->Block( Name => 'ActionOverview' );

    # call hint block
    $LayoutObject->Block(
        Name => $Param{Type} . 'Hint',
        Data => {
            %Param,
        },
    );

    if ( !$Param{Data} ) {

        $Param{Data}{GenericAgents} = {};

        # export
        my %GenericAgents = $GenericAgentObject->JobList();

        # get queue data
        for my $GenericAgentName ( keys %GenericAgents ) {
            my %GenericAgentData = $GenericAgentObject->JobGet(
                Name => $GenericAgentName,
            );

            $Param{Data}{GenericAgents}{ $GenericAgentData{Name} } = \%GenericAgentData;
        }
    }

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # print the list of queues
    $Self->_GenericAgentShow(
        %Param,
    );

    # output header
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminGenericAgentImportExport',
        Data         => {
            %Param,
        },
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GenericAgentShow {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');

    if ( IsHashRefWithData( $Param{Data}{GenericAgents} ) ) {

        my @GenericAgentsAlreadyUsed;

        GENERICAGENTNAME:
        for my $GenericAgentName ( keys $Param{Data}{GenericAgents}->%* ) {

            my $GenericAgentData = $Param{Data}{GenericAgents}{$GenericAgentName};

            push @GenericAgentsAlreadyUsed, $GenericAgentData->{Name};

            next GENERICAGENTNAME if !IsHashRefWithData($GenericAgentData);

            # convert ValidID to Validity string
            my $Valid = $GenericAgentData->{Valid} || $ValidObject->ValidLookup(
                ValidID => $GenericAgentData->{Valid},
            );

            my %GenericAgentData = (
                %{$GenericAgentData},
                Valid => $Valid,
            );

            for my $Blocks ( 'GenericAgentsRow', 'GenericAgentCheckbox', $Param{Type} ) {

                # print each queue row
                $LayoutObject->Block(
                    Name => $Blocks,
                    Data => {
                        %GenericAgentData,
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

sub _ExportGenericAgents {
    my ( $Self, %Param ) = @_;

    my %GenericAgentFilter;
    if ( IsArrayRefWithData( $Param{GenericAgents} ) ) {
        %GenericAgentFilter = map { $_ => 1 } $Param{GenericAgents}->@*;
    }

    my $GenericAgentObject = $Kernel::OM->Get('Kernel::System::GenericAgent');
    my $LockObject         = $Kernel::OM->Get('Kernel::System::Lock');
    my $PriorityObject     = $Kernel::OM->Get('Kernel::System::Priority');
    my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
    my $StateObject        = $Kernel::OM->Get('Kernel::System::State');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $ValidObject        = $Kernel::OM->Get('Kernel::System::Valid');

    my %GenericAgentList = $GenericAgentObject->JobList();

    my %ExportData;
    GENERICAGENTNAME:
    for my $GenericAgentName ( sort keys %GenericAgentList ) {

        my %GenericAgentData = $GenericAgentObject->JobGet(
            Name => $GenericAgentName,
        );

        if (%GenericAgentFilter) {
            next GENERICAGENTNAME unless $GenericAgentFilter{ $GenericAgentData{Name} };
        }

        # translate IDs into names or name-like identifiers
        ATTRIBUTE:
        for my $Attribute ( keys %GenericAgentData ) {

            if ( $Attribute eq 'Valid' ) {
                my $Valid = $ValidObject->ValidLookup(
                    ValidID => $GenericAgentData{Valid},
                );
                $GenericAgentData{Valid} = $Valid;
            }
            elsif ( $Attribute eq 'LockIDs' ) {
                if ( IsArrayRefWithData( $GenericAgentData{LockIDs} ) ) {
                    my @Locks;
                    for my $LockID ( $GenericAgentData{LockIDs}->@* ) {
                        push @Locks, $LockObject->LockLookup(
                            LockID => $LockID,
                        );
                    }
                    $GenericAgentData{Locks} = \@Locks;
                    delete $GenericAgentData{LockIDs};
                }
            }
            elsif ( $Attribute eq 'NewLockID' ) {
                if ( $GenericAgentData{NewLockID} ) {
                    $GenericAgentData{NewLock} = $LockObject->LockLookup(
                        LockID => $GenericAgentData{NewLockID},
                    );
                    delete $GenericAgentData{NewLockID};
                }
            }
            elsif ( $Attribute eq 'NewOwnerID' ) {
                if ( $GenericAgentData{NewOwnerID} ) {
                    $GenericAgentData{NewOwner} = $UserObject->UserLookup(
                        UserID => $GenericAgentData{NewOwnerID},
                    );
                    delete $GenericAgentData{NewOwnerID};
                }
            }
            elsif ( $Attribute eq 'NewPriorityID' ) {
                if ( $GenericAgentData{NewPriorityID} ) {
                    $GenericAgentData{NewPriority} = $PriorityObject->PriorityLookup(
                        PriorityID => $GenericAgentData{NewPriorityID},
                    );
                    delete $GenericAgentData{NewPriorityID};
                }
            }
            elsif ( $Attribute eq 'NewQueueID' ) {
                if ( $GenericAgentData{NewQueueID} ) {
                    $GenericAgentData{NewQueue} = $QueueObject->QueueLookup(
                        QueueID => $GenericAgentData{NewQueueID},
                    );
                    delete $GenericAgentData{NewQueueID};
                }
            }
            elsif ( $Attribute eq 'NewStateID' ) {
                if ( $GenericAgentData{NewStateID} ) {
                    $GenericAgentData{NewState} = $StateObject->StateLookup(
                        StateID => $GenericAgentData{NewStateID},
                    );
                    delete $GenericAgentData{NewStateID};
                }
            }
            elsif ( $Attribute eq 'OwnerIDs' ) {
                if ( IsArrayRefWithData( $GenericAgentData{OwnerIDs} ) ) {
                    my @Owners;
                    for my $OwnerID ( $GenericAgentData{OwnerIDs}->@* ) {
                        push @Owners, $UserObject->UserLookup(
                            UserID => $OwnerID,
                        );
                    }
                    $GenericAgentData{Owners} = \@Owners;
                    delete $GenericAgentData{OwnerIDs};
                }
            }
            elsif ( $Attribute eq 'PriorityIDs' ) {
                if ( IsArrayRefWithData( $GenericAgentData{PriorityIDs} ) ) {
                    my @Priorities;
                    for my $PriorityID ( $GenericAgentData{PriorityIDs}->@* ) {
                        push @Priorities, $PriorityObject->PriorityLookup(
                            PriorityID => $PriorityID,
                        );
                    }
                    $GenericAgentData{Priorities} = \@Priorities;
                    delete $GenericAgentData{PriorityIDs};
                }
            }
            elsif ( $Attribute eq 'QueueIDs' ) {
                if ( IsArrayRefWithData( $GenericAgentData{QueueIDs} ) ) {
                    my @Queues;
                    for my $QueueID ( $GenericAgentData{QueueIDs}->@* ) {
                        push @Queues, $QueueObject->QueueLookup(
                            QueueID => $QueueID,
                        );
                    }
                    $GenericAgentData{Queues} = \@Queues;
                    delete $GenericAgentData{QueueIDs};
                }
            }
            elsif ( $Attribute eq 'StateIDs' ) {
                if ( IsArrayRefWithData( $GenericAgentData{StateIDs} ) ) {
                    my @States;
                    for my $StateID ( $GenericAgentData{StateIDs}->@* ) {
                        push @States, $StateObject->StateLookup(
                            StateID => $StateID,
                        );
                    }
                    $GenericAgentData{States} = \@States;
                    delete $GenericAgentData{StateIDs};
                }
            }
        }

        $ExportData{ $GenericAgentData{Name} } = \%GenericAgentData;
    }

    return \%ExportData;
}

sub _ImportGenericAgents {
    my ( $Self, %Param ) = @_;

    my $GenericAgentObject = $Kernel::OM->Get('Kernel::System::GenericAgent');
    my $LockObject         = $Kernel::OM->Get('Kernel::System::Lock');
    my $PriorityObject     = $Kernel::OM->Get('Kernel::System::Priority');
    my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
    my $StateObject        = $Kernel::OM->Get('Kernel::System::State');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $ValidObject        = $Kernel::OM->Get('Kernel::System::Valid');
    my %GenericAgentList   = $GenericAgentObject->JobList();
    my %GenericAgentLookup = reverse %GenericAgentList;

    GENERICAGENTNAME:
    for my $GenericAgentName ( keys $Param{GenericAgents}->%* ) {
        my $GenericAgentData = $Param{GenericAgents}{$GenericAgentName};

        # TODO check what is exactly stored there and rename attribute accordingly
        my $GenericAgentID = $GenericAgentLookup{ $GenericAgentData->{Name} };

        # skip if generic agent with same name exists and overwrite is not set
        next GENERICAGENTNAME if ( !$Param{OverwriteExistingEntities} && $GenericAgentID );

        # translate named data back to IDs
        $GenericAgentData->{ValidID} = $ValidObject->ValidLookup(
            Valid => $GenericAgentData->{Valid},
        );
        if ( IsArrayRefWithData( $GenericAgentData->{Locks} ) ) {
            my @LockIDs;
            for my $Lock ( $GenericAgentData->{Locks}->@* ) {
                push @LockIDs, $LockObject->LockLookup(
                    Lock => $Lock,
                );
            }
            $GenericAgentData->{LockIDs} = \@LockIDs;
        }
        if ( $GenericAgentData->{NewLock} ) {
            $GenericAgentData->{NewLockID} = $LockObject->LockLookup(
                Lock => $GenericAgentData->{NewLock},
            );
        }
        if ( $GenericAgentData->{NewOwner} ) {
            $GenericAgentData->{NewOwnerID} = $UserObject->UserLookup(
                UserID => $GenericAgentData->{NewOwner},
            );
        }
        if ( $GenericAgentData->{NewPriority} ) {
            $GenericAgentData->{NewPriorityID} = $PriorityObject->PriorityLookup(
                Priority => $GenericAgentData->{NewPriority},
            );
        }
        if ( $GenericAgentData->{NewQueue} ) {
            $GenericAgentData->{NewQueueID} = $QueueObject->QueueLookup(
                Queue => $GenericAgentData->{NewQueue},
            );
        }
        if ( $GenericAgentData->{NewState} ) {
            $GenericAgentData->{NewStateID} = $StateObject->StateLookup(
                State => $GenericAgentData->{NewState},
            );
        }
        if ( IsArrayRefWithData( $GenericAgentData->{Owners} ) ) {
            my @OwnerIDs;
            for my $Owner ( $GenericAgentData->{Owners}->@* ) {
                push @OwnerIDs, $UserObject->UserLookup(
                    User => $Owner,
                );
            }
            $GenericAgentData->{OwnerIDs} = \@OwnerIDs;
        }
        if ( IsArrayRefWithData( $GenericAgentData->{Priorities} ) ) {
            my @PriorityIDs;
            for my $Priority ( $GenericAgentData->{Priorities}->@* ) {
                push @PriorityIDs, $PriorityObject->PriorityLookup(
                    Priority => $Priority,
                );
            }
            $GenericAgentData->{PriorityIDs} = \@PriorityIDs;
        }
        if ( IsArrayRefWithData( $GenericAgentData->{Queues} ) ) {
            my @QueueIDs;
            for my $Queue ( $GenericAgentData->{Queues}->@* ) {
                push @QueueIDs, $QueueObject->QueueLookup(
                    Queue => $Queue,
                );
            }
            $GenericAgentData->{QueueIDs} = \@QueueIDs;
        }
        if ( IsArrayRefWithData( $GenericAgentData->{States} ) ) {
            my @StateIDs;
            for my $State ( $GenericAgentData->{States}->@* ) {
                push @StateIDs, $StateObject->StateLookup(
                    State => $State,
                );
            }
            $GenericAgentData->{StateIDs} = \@StateIDs;
        }

        if ($GenericAgentID) {

            # remove/clean up old profile stuff
            $GenericAgentObject->JobDelete(
                Name   => $GenericAgentID,
                UserID => $Self->{UserID},
            );

            # insert new profile params
            my $Success = $GenericAgentObject->JobAdd(
                Name   => $GenericAgentID,
                Data   => $GenericAgentData,
                UserID => $Self->{UserID},
            );
            next GENERICAGENTNAME unless $Success;
        }
        else {
            my $GenericAgentID = $GenericAgentObject->JobAdd(
                Name   => $GenericAgentData->{Name},
                Data   => $GenericAgentData,
                UserID => $Self->{UserID},
            );
            next GENERICAGENTNAME unless $GenericAgentID;
        }
    }

    return;
}

1;
