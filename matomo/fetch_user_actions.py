import math
import os
import requests
import urllib.parse as urlparse
import matomo_sites

def get_time_in_fifteen_min_range(time_diff):
    time_diff_as_fifteen_mins = time_diff / 60 / 15
    return str(math.floor(time_diff_as_fifteen_mins) * 15) + ' - ' + str(math.ceil(time_diff_as_fifteen_mins) * 15)

cert = 'client.pem'
token = os.environ.get('TOKEN')
site_collections = os.environ.get('SITE_COLLECTIONS', 'all')
fetch_visitors_per_site = os.environ.get('VISITOR_COUNT', '10')

if site_collections == 'all':
    sites = matomo_sites.get_matomo_sites(token)
else:
    sites = matomo_sites.get_matomo_sites(token, site_collections)

time_range_hits = {}

for site_id, site_name in sites:
    params = {
        'module': 'API', 'method': 'Live.getLastVisitsDetails', 'countVisitorsToFetch': fetch_visitors_per_site,
        'period': 'day', 'date': 'today', 'idSite': site_id, 'format': 'json',
        'token_auth': token}
    r = requests.get('https://digiaiiris.com/web-analytics/', params=params, cert=cert)

    time_range_hits[site_name] = {'arriveBy': {}, 'departAt': {}}

    for entry in r.json():
        is_arriveBy = False
        time_diff = None
        for action in entry['actionDetails']:
            parsed_url = urlparse.urlparse(action['url'])
            path = parsed_url.path
            if len(path) > 0 and path.split('/')[1] == 'reitti':
                query = urlparse.parse_qs(parsed_url.query)
                if 'time' in query and len(query['time']) > 0:
                    time_diff = int(query['time'][0]) - action['timestamp']
                else:
                    time_diff = 0

                if 'arriveBy' in query and len(query['arriveBy']) > 0:
                    is_arriveBy = 'true' in query['arriveBy']
                else:
                    is_arriveBy = False

        if time_diff:
            time_range = get_time_in_fifteen_min_range(time_diff)
            if is_arriveBy:
                if time_range in time_range_hits[site_name]['arriveBy']:
                    time_range_hits[site_name]['arriveBy'][time_range] += 1
                else:
                    time_range_hits[site_name]['arriveBy'][time_range] = 1
            else:
                if time_range in time_range_hits[site_name]['departAt']:
                    time_range_hits[site_name]['departAt'][time_range] += 1
                else:
                    time_range_hits[site_name]['departAt'][time_range] = 1

    r.close()
print(time_range_hits)
