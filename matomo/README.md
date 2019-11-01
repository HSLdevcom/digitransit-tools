## Matomo scripts

These scripts are used to fetch and process data from Matomo API. Configured to work with python 3.

### Requirements

If API is behind shibboleth authentication, you need a client certificate and copy it to this directory as client.pem.

You also need a API token which can be fetched from https://digiaiiris.com/web-analytics/index.php?module=UsersManager&action=userSettings or similar path depending on Matomo deployment.

### Available sites

In Matomo, access rights to data from different sites can be limited. matomo_sites.py has a hardcoded list of sites and their siteids. It also checks if you have access to these sites and returns a list of siteids and names.

### Fetching time ranges for routing

With fetch_query_time_ranges.py you can fetch user actions. From those actions, we find the latest reitti page visit user has done in a session and parse from query string the time parameter used in routing. Then we subtract the timestamp when the matomo event was registered from the time parameter. These values are then grouped custom length time ranges and written into two csv files in results directory. One for arriveBy queries and for normal routing queries.

The behaviour of the script can be configured with the following env variables:

* "TOKEN" authentication token for Matomo API.
* (Optional, default all) "SITE_COLLECTIONS" has 4 options, 'all', 'hsl', 'finland' and 'waltti'. All fetches data from all sites and rest from just one specific collection of sites found in matomo_sites.py.
* (Optional, default 1) "DAYS" defines from how many days the data is fetched from, starting from today.
* (Optional, default 10) "VISITOR_COUNT" defines from many visitor sessions are fetched from per each day per each site
* (Optional, default 15) "TIME_RANGE" defines the time intervals in minutes for grouping time differences

example usage (depending on environment you might have to replace python3 with python)
`TOKEN=<your token> VISITOR_COUNT=20 DAYS=5 python3 fetch_user_actions.py`
