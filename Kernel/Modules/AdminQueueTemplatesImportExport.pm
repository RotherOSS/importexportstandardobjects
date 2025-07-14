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

package Kernel::Modules::AdminQueueTemplatesImportExport;

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
    'Kernel::System::Queue',
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
    my $QueueObject  = $Kernel::OM->Get('Kernel::System::Queue');
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
            Type  => 'AdminQueueTemplatesImportExport',
            Key   => 'AdminQueueTemplatesImportExport::' . $Self->{UserID},
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
            Type => 'AdminQueueTemplatesImportExport',
            Key  => 'AdminQueueTemplatesImportExport::' . $Self->{UserID},
        );

        if ( !IsHashRefWithData($ImportData) ) {

            # redirect to AdminQueueTemplates
            my $HTML = $LayoutObject->Redirect(
                OP => "Action=AdminQueueTemplates"
            );

            return $HTML;
        }

        # check required parameters
        my @QueuesSelected            = $ParamObject->GetArray( Param => 'Queues' );
        my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || 0;

        $CacheObject->Delete(
            Type => 'AdminQueueTemplatesImportExport',
            Key  => 'AdminQueueTemplatesImportExport::' . $Self->{UserID},
        );

        # ------------------------------------------------------------ #
        # Import Queue-Templates
        # ------------------------------------------------------------ #
        if ( IsHashRefWithData( $ImportData->{QueueTemplates} ) ) {

            my %QueuesImport;
            QUEUENAME:
            for my $QueueName ( keys $ImportData->{QueueTemplates}->%* ) {

                my $Selected = grep { $QueueName eq $_ } @QueuesSelected;
                next QUEUENAME if !$Selected;

                next QUEUENAME if !IsArrayRefWithData( $ImportData->{QueueTemplates}{$QueueName} );

                $QueuesImport{$QueueName} = $ImportData->{QueueTemplates}{$QueueName};
            }

            $QueueObject->ImportQueueTemplates(
                QueueTemplates            => \%QueuesImport,
                OverwriteExistingEntities => $OverwriteExistingEntities,
                UserID                    => $Self->{UserID},
            );
        }

        # redirect to AdminQueue
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminQueueTemplates"
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

            $Data{QueueTemplates} = $QueueObject->ExportQueueTemplates(
                Queues => \@Queues,
            );
        }

        if ( !%Data ) {

            # redirect to AdminQueueTemplatesImportExport
            $HTML .= $LayoutObject->Redirect(
                OP => "Action=AdminQueueTemplatesImportExport;Subaction=Export",
            );
            return $HTML;
        }

        # convert the queue data hash to string
        my $QueueTemplatesDataYAML = $YAMLObject->Dump( Data => \%Data );

        # Get the current time formatted like '2016-01-31 14:05:45'.
        # Hoping that nobody has registered object params for Kernel::System::DateTime
        my $TimeStamp = $Kernel::OM->Create('Kernel::System::DateTime')->ToString();

        # send the result to the browser
        $HTML = $LayoutObject->Attachment(
            ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
            Content     => $QueueTemplatesDataYAML,
            Type        => 'attachment',
            Filename    => "Export_QueueTemplates_$TimeStamp.yml",
            NoCache     => 1,
        );

        return $HTML;

    }

    # ------------------------------------------------------------ #
    # ------------------------------------------------------------ #
    else {

        # redirect to AdminQueueTemplates
        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminQueueTemplates"
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

        $Param{Data}{QueueTemplates} = {};

        # export
        my %Queues = $QueueObject->QueueList(
            Valid => 0,
        );

        $Param{Data}{QueueTemplates} = { map { $_ => {} } values %Queues };
    }

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # print the list of queues
    $Self->_QueueShow(
        %Param,
    );

    # output header
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminQueueTemplatesImportExport',
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

    # check if at least 1 dynamic field is registered in the system
    if ( IsHashRefWithData( $Param{Data}{QueueTemplates} ) ) {

        my @QueuesAlreadyUsed;

        QUEUENAME:
        for my $QueueName ( keys $Param{Data}{QueueTemplates}->%* ) {

            push @QueuesAlreadyUsed, $QueueName;

            for my $Blocks ( 'QueuesRow', 'QueueCheckbox', $Param{Type} ) {

                # print each queue row
                $LayoutObject->Block(
                    Name => $Blocks,
                    Data => {
                        Name => $QueueName,
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

1;
