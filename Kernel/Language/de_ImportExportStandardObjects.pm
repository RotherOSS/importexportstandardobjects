# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2026 Rother OSS GmbH, https://otobo.io/
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

package Kernel::Language::de_ImportExportStandardObjects;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminGenericAgentImportExport
    $Self->{Translation}->{'GenericAgents'} = '';
    $Self->{Translation}->{'Here you can export a configuration file of generic agents to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Generic Agents exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';
    $Self->{Translation}->{'GenericAgents List'} = '';

    # Template: AdminGroupImportExport
    $Self->{Translation}->{'Here you can export a configuration file of groups to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Gruppen exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';
    $Self->{Translation}->{'Groups List'} = '';

    # Template: AdminQueueImportExport
    $Self->{Translation}->{'Here you can export a configuration file of queues to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Queues exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';
    $Self->{Translation}->{'Queues List'} = '';

    # Template: AdminQueueTemplatesImportExport
    $Self->{Translation}->{'Queue Template Relations'} = '';
    $Self->{Translation}->{'Here you can export a configuration file of queue-template relations to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Queue-Vorlagen-Beziehungen exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';

    # Template: AdminRoleGroupImportExport
    $Self->{Translation}->{'Role-Group Relations'} = '';
    $Self->{Translation}->{'Here you can export a configuration file of role-group relations to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Rollen-Gruppen-Beziehungen exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';
    $Self->{Translation}->{'Role-Group relations List'} = '';

    # Template: AdminRoleImportExport
    $Self->{Translation}->{'Here you can export a configuration file of roles to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Rollen exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';
    $Self->{Translation}->{'Roles List'} = '';

    # Template: AdminTemplateImportExport
    $Self->{Translation}->{'Here you can export a configuration file of templates to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Vorlagen exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';
    $Self->{Translation}->{'Templates List'} = '';

    # Template: AdminTypeImportExport
    $Self->{Translation}->{'Here you can export a configuration file of types to import these on another system. The configuration file is exported in yml format.'} =
        'Hier können Sie eine Konfigurationsdatei von Typen exportieren, um diese auf einem anderen System zu importieren. Die Konfigurationsdatei wird im yml Format exportiert.';
    $Self->{Translation}->{'Types List'} = '';

    # Template: AdminGenericAgent
    $Self->{Translation}->{'Here you can upload a configuration file to import generic agents to your system. The file needs to be in .yml format as exported by the generic agent management module.'} =
        '';
    $Self->{Translation}->{'Generic Agents Import'} = 'Generic Agent Import';
    $Self->{Translation}->{'Generic Agents Export'} = 'Generic Agent Export';

    # Template: AdminGroup
    $Self->{Translation}->{'Here you can upload a configuration file to import groups to your system. The file needs to be in .yml format as exported by the group management module.'} =
        '';
    $Self->{Translation}->{'Groups Import'} = 'Gruppen-Import';
    $Self->{Translation}->{'Groups Export'} = 'Gruppen-Export';

    # Template: AdminQueue
    $Self->{Translation}->{'Here you can upload a configuration file to import queues to your system. The file needs to be in .yml format as exported by the queue management module.'} =
        '';
    $Self->{Translation}->{'Queues Import'} = 'Queue-Import';
    $Self->{Translation}->{'Queues Export'} = 'Queue-Export';
    $Self->{Translation}->{'Is defined in Admin > System addresses.'} = '';
    $Self->{Translation}->{'Only relevant if Postmaster Mail Account set to Dispatching by To: field.'} =
        '';
    $Self->{Translation}->{'The business calendar for Unlock Time and the Escalation Times. No selection means the Default calendard'} =
        '';
    $Self->{Translation}->{'Is defined in Admin > SystemConfiguration > Core > Time (Default Calendar = no selection) or in Calendars 1 through 9.'} =
        '';

    # Template: AdminQueueTemplates
    $Self->{Translation}->{'Here you can upload a configuration file to import queue-template relations to your system. The file needs to be in .yml format as exported by the queue-template management module.'} =
        '';
    $Self->{Translation}->{'Queue-Templates Import'} = 'Queue-Vorlagen-Import';
    $Self->{Translation}->{'Queue-Templates Export'} = 'Queue-Vorlagen-Export';

    # Template: AdminRole
    $Self->{Translation}->{'Here you can upload a configuration file to import roles to your system. The file needs to be in .yml format as exported by the role management module.'} =
        '';
    $Self->{Translation}->{'Roles Import'} = 'Rollen-Import';
    $Self->{Translation}->{'Roles Export'} = 'Rollen-Export';

    # Template: AdminRoleGroup
    $Self->{Translation}->{'Here you can upload a configuration file to import role-group relations to your system. The file needs to be in .yml format as exported by the role-group management module.'} =
        '';
    $Self->{Translation}->{'Role-Group Import'} = 'Rollen-Gruppen-Import';
    $Self->{Translation}->{'Role-Group Export'} = 'Rollen-Gruppen-Export';

    # Template: AdminTemplate
    $Self->{Translation}->{'Here you can upload a configuration file to import templates to your system. The file needs to be in .yml format as exported by the template management module.'} =
        '';
    $Self->{Translation}->{'Templates Import'} = 'Vorlagen-Import';
    $Self->{Translation}->{'Templates Export'} = 'Vorlagen-Export';

    # Template: AdminType
    $Self->{Translation}->{'Here you can upload a configuration file to import types to your system. The file needs to be in .yml format as exported by the type management module.'} =
        '';
    $Self->{Translation}->{'Types Import'} = 'Typen-Import';
    $Self->{Translation}->{'Types Export'} = 'Typen-Export';

    # SysConfig
    $Self->{Translation}->{'Autoload configuration for GenericAgent import and export functions.'} =
        '';
    $Self->{Translation}->{'Autoload configuration for Group import and export functions.'} =
        '';
    $Self->{Translation}->{'Autoload configuration for Queue import and export functions.'} =
        '';
    $Self->{Translation}->{'Autoload configuration for Queue-Template relations import and export functions.'} =
        '';
    $Self->{Translation}->{'Autoload configuration for Role import and export functions.'} =
        '';
    $Self->{Translation}->{'Autoload configuration for Role-Group relations import and export functions.'} =
        '';
    $Self->{Translation}->{'Autoload configuration for Template import and export functions.'} =
        '';
    $Self->{Translation}->{'Autoload configuration for Type import and export functions.'} =
        '';


    push @{ $Self->{JavaScriptStrings} // [] }, (
    );

}

1;
