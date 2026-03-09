.. toctree::
    :maxdepth: 2
    :caption: Contents

Sacrifice to Sphinx
===================

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

The admin screens for the object types listed below are enhanced by a new widget. The widget allows importing and exporting data for the respective object type.

Generic Agent
-------------

 .. figure:: images/AdminGenericAgent.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the generic agent overview screen in the admin interface.

   The screenshot shows the generic agent overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminGenericAgentExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the generic agent export screen in the admin interface.

   The screenshot shows the generic agent export screen in the admin interface.

Group
-----

 .. figure:: images/AdminGroup.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the group overview screen in the admin interface.

   The screenshot shows the group overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminGroupExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the group export screen in the admin interface.

   The screenshot shows the group export screen in the admin interface.

Queue
-----

 .. figure:: images/AdminQueue.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the queue overview screen in the admin interface.

   The screenshot shows the queue overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminQueueExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the queue export screen in the admin interface.

   The screenshot shows the queue export screen in the admin interface.

Queue Template Relations
------------------------

 .. figure:: images/AdminQueueTemplate.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the queue template relations overview screen in the admin interface.

   The screenshot shows the queue template relations overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminQueueTemplateExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the queue template relations export screen in the admin interface.

   The screenshot shows the queue template relations export screen in the admin interface.

Role
----

 .. figure:: images/AdminRole.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the role overview screen in the admin interface.

   The screenshot shows the role overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminRoleExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the role export screen in the admin interface.

   The screenshot shows the role export screen in the admin interface.

Role Group Relations
--------------------

 .. figure:: images/AdminRoleGroup.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the role group relations overview screen in the admin interface.

   The screenshot shows the role group relations overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminRoleGroupExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the role group relations export screen in the admin interface.

   The screenshot shows the role group relations export screen in the admin interface.

Template
--------

 .. figure:: images/AdminTemplate.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the template overview screen in the admin interface.

   The screenshot shows the template overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminTemplateExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the template export screen in the admin interface.

   The screenshot shows the template export screen in the admin interface.

Type
----

 .. figure:: images/AdminType.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the type overview screen in the admin interface.

   The screenshot shows the type overview screen in the admin interface.

The export screen looks as follows:

 .. figure:: images/AdminTypeExport.png
   :align: center
   :scale: 35%
   :alt: The screenshot shows the type export screen in the admin interface.

   The screenshot shows the type export screen in the admin interface.

Setup
-----

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
