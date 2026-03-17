.. toctree::
    :maxdepth: 2
    :caption: Contents

Sacrifice to Sphinx
====================

Description
===========
This package provides import and export of some standard objects via admin interface and import via console command.

System requirements
===================

Framework
---------
OTOBO 11.0.x

Packages
--------
\-

Third-party software
--------------------
\-

Usage
=====

The admin screens for a number of object types are enhanced by a new widget. The widget allows importing and exporting data for the respective object type. Shown below are the group and the role group relations as examples.

For importing data, select the respective file in the file picker and click on the import button. Then an overview screen over the data to be imported is shown. The user can exclude data from import there.

Likewise, the export shows an overview screen on which data to export. The data can be selected as well.

Group
-----

 .. figure:: images/AdminGroup.png
   :align: center
   :scale: 30%
   :alt: The screenshot shows the group overview screen in the admin interface.

   The screenshot shows the group overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminGroupExport.png
   :align: center
   :scale: 30%
   :alt: The screenshot shows the group export screen in the admin interface.

   The screenshot shows the group export screen in the admin interface.

Role Group Relations
--------------------

 .. figure:: images/AdminRoleGroup.png
   :align: center
   :scale: 30%
   :alt: The screenshot shows the role group relations overview screen in the admin interface.

   The screenshot shows the role group relations overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminRoleGroupExport.png
   :align: center
   :scale: 30%
   :alt: The screenshot shows the role group relations export screen in the admin interface.

   The screenshot shows the role group relations export screen in the admin interface.

Advanced Usage
--------------

For the more advanced use case, there are four new console commands:

- ``Admin::ImportExport::ImportACL``
- ``Admin::ImportExport::ImportDynamicField``
- ``Admin::ImportExport::ImportProcess``
- ``Admin::ImportExport::ImportStandardObject``

The commands take a file path as argument and import the data found in this file. ``Admin::ImportExport::ImportStandardObject`` relies on the export structure of the objects listed in the help text and determines which object type is imported.

Configuration Reference
-----------------------

Core::Autoload
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

AutoloadPerlPackages###003-TemplateImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for Template import and export functions.

AutoloadPerlPackages###003-TypeImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for Type import and export functions.

AutoloadPerlPackages###003-QueueImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for Queue import and export functions.

AutoloadPerlPackages###003-GroupImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for Group import and export functions.

AutoloadPerlPackages###003-QueueTemplatesImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for Queue-Template relations import and export functions.

AutoloadPerlPackages###003-RoleImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for Role import and export functions.

AutoloadPerlPackages###003-GenericAgentImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for GenericAgent import and export functions.

AutoloadPerlPackages###003-RoleGroupImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Autoload configuration for Role-Group relations import and export functions.

Frontend::Admin::ModuleRegistration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Frontend::Module###AdminTypeImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Module###AdminGenericAgentImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Module###AdminQueueImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Module###AdminRoleImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Module###AdminGroupImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Module###AdminQueueTemplatesImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Module###AdminRoleGroupImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Module###AdminTemplateImportExport
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Frontend module registration for the admin interface.

Frontend::Admin::ModuleRegistration::Loader
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Loader::Module::AdminTypeImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Loader::Module::AdminGenericAgentImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Loader::Module::AdminQueueTemplatesImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Loader::Module::AdminQueueImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Loader::Module::AdminRoleImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Loader::Module::AdminGroupImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Loader::Module::AdminRoleGroupImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

Loader::Module::AdminTemplateImportExport###003-ImportExportStandardObjects
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Loader module registration for the agent interface.

About
=======

Contact
-------
| Rother OSS GmbH
| Email: hello@otobo.io
| Web: https://otobo.io

Version
-------
Author: |doc-vendor| / Version: |doc-version| / Date of release: |doc-datestamp|
