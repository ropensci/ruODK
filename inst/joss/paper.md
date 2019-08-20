---
title: 'ruODK: An R Client for the ODK Central API'
authors:
- affiliation: 1
  name: Florian W Mayer
  orcid: 0000-0003-4269-4242
date: "25 July 2019"
output: pdf_document
bibliography: paper.bib
tags:
- database
- open-data
- opendatakit
- odk
- api
- data
- dataset
affiliations:
- index: 1
  name: Department of Biodiversity, Conservation and Attraction, Western Australia
---
![ruODK logo](../../man/figures/ruODK.png)

# Summary
ruODK [@ruodk] is an R Client for the ODK Central API.


# Background

Open Data Kit (ODK, [@odk], [@hartung]) is a suite of open source tools that 
help organizations collect and manage data.


The core ODK tools are [@odkdocs]:

* ODK Collect, an Android app that replaces paper-based forms.
* ODK Aggregate, a proven server for data storage and analysis tool.
* ODK Central, a modern server with a RESTful API.
* ODK Build, a drag-and-drop form designer.
* ODK XLSForm, an Excel-based form designer.
* ODK Briefcase, a desktop tool that pulls and exports data from Aggregate and Collect.


The core workflow of ODK is:

* A form for digital data capture is designed, either by hand, or using form 
  builders like ODK Build.
* A data clearinghouse like ODK Aggregate or ODK Central disseminates these
  form templates to authorised data collection devices (Android devices running
  ODK Collect).
* Once data has been collected, ODK Collect submits the data back to the data
  clearinghouse, e.g. ODK Central.
* From there, it is the responsibility of the maintainers to export and further
  process and use the data.

At the time of writing, [ODK Central](https://docs.opendatakit.org/central-intro/)
is being introduced as a replacement for ODK Aggregate.

While the use of ODK Aggregate is well established, the use of ODK Central is new
to most users. As ODK Central provides all of its content through a well-documented
API [@odkapi], there is an opportunity to create API wrappers to assist with the
data retrieval from ODK Central.

ruODK [@ruodk], currently available from GitHub [@github], is the first dedicated
R Client for the ODK Central API.

# Scope

`ruODK` aims:

* To wrap all ODK Central API endpoints with a focus on **data access**. 
  While this is mostly not a hard task, there is still a small barrier to novice
  R users, and some duplication of code.
* To provide working examples of interacting with the ODK Central API.
* To provide convenience helpers for the day to day tasks when working with 
  ODK Central data in R: transforming the ODK Central API output into tidy 
  R formats.
  
## Out of scope

* To wrap "management" API endpoints. The ODK Central GUI already provides a 
  highly capable interface for the management of users, roles, permissions, 
  projects, and forms.
  ODK Central is a [VueJS application](https://github.com/opendatakit/central-frontend/) 
  working on the "management" API endpoints of the ODK Central backend.
* To provide extensive data visualisation capability. 
  We show only minimal examples of data visualisation and presentation, mainly 
  to illustrate the example data.
  
# Typical use cases

## Smaller projects
Smaller projects, such as ephemeral research projects or proof of concept studies, 
may generate a manageable number of form submissions over a limited amount of time.

Here, it may be sufficient to export the entire set of submissions, analyse
and visualise it, and generate some products such as a CSV export of the data,
vector or raster figures and maps for publications, and a rendered report.

The vignettes "odata" and "api" show examples of this use case. They differ in
that the vignette "odata" uses the OData API, while the vignette "api" uses the
RESTful API.

## Larger projects
Long-term projects, such as environmental monitoring programs, may generate many
thousand submissions over a long, ongoing period of time.

Such projects typically store their data in dedicated databases. There, the data
can be value-added through QA/QC/review, through integration with other data
sources, and through further data processing. This requires the data to be
regularly and incrementally exported from ODK Central, tranformed into the target
data formats (which may differ from ODK Central's output), and loaded into the 
target database.

In this case, ruODK assists with the retrieval of data, inspection of new vs. 
existing submissions, and export into an intermediary format, such as CSV 
snapshots.  

# References