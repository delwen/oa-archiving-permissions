# Example case: Leveraging open tools to realize the potential of self-archiving: A cohort study in clinical trials

## Overview

The code described in this repository was used to assess the potential of
self-archiving to increase the discoverability of clinical trial publications.
This example use case is described in more detail in this preprint:
*[coming soon]*. The code associated with this example use case can be found in
this branch. The data generated in this project is openly available in [Zenodo](https://doi.org/10.5281/zenodo.7154254).

## Description

This example use case builds on a cohort of clinical trials and associated
publications, referred to as the **IntoValue dataset**. The IntoValue dataset is
actively maintained in this [repository](https://github.com/maia-sh/intovalue-data).
It consists of interventional clinical trials registered in ClinicalTrials.gov
or the German Clinical Trials Register (DRKS), conducted at a German university
medical center, and reported as complete on the registry between 2009 – 2017. The
earliest results publications associated with these trials were found through
manual searches.

This example use case addresses the following questions in this cohort:
- How many clinical trial results publications are openly accessible?*
- For articles behind a paywall, what is the potential of self-archiving to
increase access?

**The following definition of Open Access (OA) was used: articles that are*
*free-to-read online in a journal or OA repository.*

## Workflow

All the relevant scripts to reproduce the results can be found in the `scripts`
folder:

1) `get-oa-status.R`: download the IntoValue dataset and apply the inclusion and
exclusion criteria. Then, query Unpaywall via its API to get the OA status of
publications in the cohort. To account for multiple OA locations, the following
hierarchy is used: gold > hybrid > bronze > green > closed.
2) `get-oa-permissions.py`: query Shareyourpaper via its API to get the 'best
permission' of the publications in the cohort. The script also defines whether
a permission was found based on pre-determined criteria.
3) `merge-data.R`: merge the results from Unpaywall and Shareyourpaper API
queries.

The `analysis` folder contains the scripts to generate the trial screening
flowchart and the publication screening flowchart.