# oa-archiving-permissions

Get article-level self-archiving permissions
of publications based on the
[ShareYourPaper API](https://openaccessbutton.org/api)
([OA.Works](https://oa.works)).

### Overview
This script can be used to query the ShareYourPaper
API to obtain self-archiving permissions of
publications. The script takes as input a list of
DOIs and returns several variables of interest
based on the "best permission" in the ShareYourPaper
permissions database
(see more information [here](https://shareyourpaper.org/permissions#learnmore)).

### Data dictionary
Running the script generates the following variables:

|name|type|description|
|---|---|---|
|syp_response|string|Response flag; either 'unresolved' (DOI not resolved), 'no_best_permission' (no best permission in API response), 'no_embargo' (no embargo in API response), or 'response' (DOI resolved and best permission found)|
|can_archive|boolean|Can the publication be archived in any way? Derived from `can_archive` in API response (best permission)|
|archiving_locations|string|Where can the publication be archived? Derived from `locations` in API response (best permission)|
|inst_repository|boolean|Can the publication be archived in an institutional repository? True if 'institutional repository' in `locations` in API response (best permission)|
|versions|string|What version of the publication can be archived? Derived from `versions` in API response (best permission)|
|submitted_version|boolean|Can the submitted version of the publication be self-archived? True if 'submittedVersion' in `versions` (best permission)|
|accepted_version|boolean|Can the accepted version of the publication be self-archived? True if 'acceptedVersion' in `versions` (best permission)|
|published_version|boolean|Can the published version of the publication be self-archived? True if 'publishedVersion' in `versions` (best permission)|
|licenses_required|string|License required to be applied to the publication. Derived from `licences` in API response (best permission)|
|permission_issuer|string|Institution issuing the permission. Derived from `issuer` in API response (best permission) |
|embargo|float|Embargo applied to best permission. Derived from `embargo_months` in API response (best permission)|
|date_embargo_elapsed|string|Date at which the embargo elapses. Derived from `embargo_end` in API response (best permission)|
|is_embargo_elapsed|boolean|Has the embargo elapsed by the query date? Calculated by comparing `date_embargo_elapsed` and query date|
|permission_accepted|boolean|Can the accepted version of the publication be self-archived in an institutional repository? True if `can_archive`, `inst_repository`, `is_embargo_elapsed`, and `accepted_version` are True|
|permission_published|boolean|Can the published version of the publication be self-archived in an institutional repository? True if `can_archive`, `inst_repository`, `is_embargo_elapsed`, and `published_version` are True|

### Requirements
The requirements for this project are listed in
the `requirements.txt` file (tested with versions
found in `requirements_vers.txt`).

### Run script
To run on a sample dataset, execute the following command:
```
$ python3 scripts/get-oa-permissions.py --config config-sample.ini
```
This will run the script on a sample dataset. This
dataset contains 20 DOIs and additional data from
Unpaywall:
```
sample-data/oa-unpaywall.csv
```
The output of running the script on this
dataset can be found in
```
sample-data/oa-syp-permissions.csv
```

## Example use case
This code was used to assess the potential of self-archiving to increase the
discoverability of a cohort of clinical trial publications. This example use
case is available as a preprint: [coming soon]. The code associated with this
project can be found in the `oa-trials-paper` branch of this repository. The
data generated in this project can be found in [Zenodo](https://doi.org/10.5281/zenodo.7154254).