# Gets article-level self-archiving permission for the accepted version of manuscript
# by querying ShareYourPaper's permissions API (https://shareyourpaper.org/permissions/about#api)
# Focuses on the authoritative permission

import pandas as pd
import requests
import requests_cache
from ratelimit import limits, sleep_and_retry
import json
import time
import configparser
import datetime
import os


# Load paths from the config file
cfg = configparser.ConfigParser()
cfg.read("config.ini")

# Get date to add to output file names
today = datetime.datetime.today()
now = today.strftime("%Y-%m-%d")

# Define data folder
data_folder = cfg["paths"]["data"]

# Define path to file with the data
data_file = os.path.join(data_folder, "2021-02-16_berlin-2018-oa.csv")

# Read input dataset containing DOIs and OA status
data = pd.read_csv(data_file)

# Filter for UMC and closed articles
closed = data[(data['color'] == 'closed')]
print("Number of closed publications: ", closed.shape[0])

# Base URL
url = "https://permissions.shareyourpaper.org/doi/"

dois = closed['doi'].values.tolist()

requests_cache.install_cache('permissions_cache')


# Set the rate limit to 1 call per 2 seconds
@sleep_and_retry
@limits(calls=1, period=2)
def call_api_server(url, doi):
    now = time.ctime(int(time.time()))
    response = requests.get(url + doi)
    print("Time: {0} / Used Cache: {1}".format(now, response.from_cache))

    if response.status_code != 200:
        raise Exception('API response: {}'.format(response.status_code))
    return response.json()


def call_api(url, doi):
    req = requests.Request('GET', url + doi)

    cache = requests_cache.get_cache()

    prepped = requests.Session().prepare_request(req)
    cache_key = cache.create_key(prepped)

    try:
        response, _ = cache.get_response_and_time(cache_key)
    except (ImportError, TypeError):
        response = None

    if response:
        return response.json()

    return call_api_server(url, doi)


def get_parameters(output_formatted):

    # Skip DOIs which do not have an authoritative permission
    if not output_formatted["authoritative_permission"]:
        return None
    # Can you self-archive the manuscript in any way?
    can_archive = output_formatted["authoritative_permission"]["application"]["can_archive"]

    # Where can the version named be archived?
    archiving_locations = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "archiving_locations_allowed"]
    inst_repository = True if 'institutional repository' in archiving_locations else False

    # What versions can be archived?
    version = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "versions_archivable"]
    preprint = True if 'preprint' in version else False
    postprint = True if 'postprint' in version else False
    publisher_pdf = True if 'publisher pdf' in version else False

    # License required to be applied to the article
    licenses_required = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "licenses_required"]

    # The institution the author must be affiliated with in order for this policy to apply
    author_afil_requir = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "author_affiliation_requirement"]

    # The role an author must have in order for this policy to apply
    author_afil_role_requir = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "author_affiliation_role_requirement"]

    # Permission only applies when the work is funded by this group
    author_funding_requir = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "author_funding_requirement"]

    # What percentage of the output must be funded for this to apply?
    author_funding_prop_requir = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "author_funding_proportion_requirement"]

    # What institution is issuing this permission?
    permission_issuer = output_formatted["authoritative_permission"]["issuer"]["permission_type"]

    # When does the embargo end?
    elapsed_embargo = output_formatted["authoritative_permission"]["application"]["can_archive_conditions"][
        "postprint_embargo_end_calculated"]

    # If there is an embargo, convert it to date type and compare to query (current) date
    if elapsed_embargo is None:
        embargo_na_or_elapsed = True
    else:
        elapsed_embargo = datetime.datetime.strptime(elapsed_embargo, '%Y-%m-%d')
        embargo_na_or_elapsed = elapsed_embargo < today

    # Define a final permission that depends on several conditions being met
    permission_postprint = True if (can_archive is True & postprint is True &
                                    embargo_na_or_elapsed is True & inst_repository is True) else False
    permission_publisher_pdf = True if (can_archive is True & publisher_pdf is True &
                                    embargo_na_or_elapsed is True & inst_repository is True) else False

    return can_archive, archiving_locations, inst_repository, version, preprint, postprint, publisher_pdf,\
           licenses_required, author_afil_requir, author_afil_role_requir, author_funding_requir,\
           author_funding_prop_requir, permission_issuer, elapsed_embargo, embargo_na_or_elapsed, permission_postprint,\
           permission_publisher_pdf


def jprint(obj):
    # create a formatted string of the Python JSON object
    text = json.dumps(obj, sort_keys=True, indent=4)
    print(text)


unresolved_dois = []
no_auth_perm_dois = []
result = []

# make the API request
for doi in dois:
    print(doi)
    try:
        output = call_api(url, doi)
    except Exception as e:
        print("Exception raised with DOI:", doi, e)
        unresolved_dois.append(doi)
        continue

    tmp = get_parameters(output)
    if not tmp:
        print(f"SKIPPED: {doi}")
        no_auth_perm_dois.append(doi)
        continue

    result.append((doi, ) + tmp)

# Create a dataframe to store the results
df = pd.DataFrame(result, columns=['doi', 'can_archive', 'archiving_locations', 'inst_repository', 'version', 'preprint',
                                   'postprint', 'publisher_pdf', 'licenses_required', 'author_afil_requir',
                                   'author_afil_role_requir', 'author_funding_requir', 'author_funding_prop_requir',
                                   'permissions_issuer', 'elapsed_embargo', 'embargo_na_or_elapsed',
                                   'permission_postprint', 'permission_publisher_pdf'])

merged_result = closed.merge(df, on='doi', how='left', indicator=True)
merged_result.to_csv(os.path.join(data_folder, (now + "_berlin-2018-oa-permissions.csv")), index=False)

unresolved = pd.DataFrame(unresolved_dois, columns=['doi'])
no_auth_perm = pd.DataFrame(no_auth_perm_dois, columns=['doi'])

unresolved.to_csv(os.path.join(data_folder, (now + "_berlin-2018-oa-unresolved.csv")), index=False)
no_auth_perm.to_csv(os.path.join(data_folder, (now + "_berlin-2018-oa-no-auth-perm.csv")), index=False)

print("Number of unresolved DOIs: ", len(unresolved_dois))
print("Number of DOIs without an authoritative permission: ", len(no_auth_perm_dois))
