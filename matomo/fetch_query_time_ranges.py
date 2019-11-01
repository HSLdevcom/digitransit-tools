from datetime import datetime, date, timedelta
import math
import os
import requests
import time
import urllib.parse as urlparse
import unicodecsv

import matomo_sites

def get_time_in_n_min_range(time_diff, n):
    time_diff_as_fifteen_mins = time_diff / 60 / n
    lower_bound = math.floor(time_diff_as_fifteen_mins) * n
    return str(lower_bound) + ' - ' + str(lower_bound + n)

cert = 'client.pem'
token = os.environ.get('TOKEN')
site_collections = os.environ.get('SITE_COLLECTIONS', 'all')
fetch_days = int(os.environ.get('DAYS', '1'))
fetch_visitors_per_site = os.environ.get('VISITOR_COUNT', '10')
time_range_length = int(os.environ.get('TIME_RANGE', '15'))

if site_collections == 'all':
    sites = matomo_sites.get_matomo_sites(token)
else:
    sites = matomo_sites.get_matomo_sites(token, site_collections)

time_range_hits = {'arriveBy': {'n': 0}, 'departAt': {'n': 0}}

today = date.today()

days = []

for i in range(fetch_days):
    new_day = today - timedelta(days=i)
    days.append(new_day.strftime("%Y-%m-%d"))

for day in days:
    for site_id, site_name in sites:
        params = {
            'module': 'API', 'method': 'Live.getLastVisitsDetails', 'countVisitorsToFetch': fetch_visitors_per_site,
            'period': 'day', 'date': day, 'idSite': site_id, 'format': 'json',
            'token_auth': token}
        r = requests.get('https://digiaiiris.com/web-analytics/', params=params, cert=cert)

        for entry in r.json():
            is_arriveBy = False
            time_diff = None
            for action in entry['actionDetails']:
                parsed_url = urlparse.urlparse(action['url'])
                path = parsed_url.path
                if len(path) > 0 and path.split('/')[1] == 'reitti':
                    query = urlparse.parse_qs(parsed_url.query)
                    if 'time' in query and len(query['time']) > 0:
                        # timestamp is not in utc seconds but in local time seconds, convert it to utc
                        timestamp_utc = int(time.mktime(datetime.utcfromtimestamp(action['timestamp']).timetuple()))
                        # query time is sometimes float for some reason
                        time_diff = math.floor(float(query['time'][0])) - timestamp_utc
                    else:
                        time_diff = 0

                    if 'arriveBy' in query and len(query['arriveBy']) > 0:
                        is_arriveBy = 'true' in query['arriveBy']
                    else:
                        is_arriveBy = False

            if time_diff:
                time_range = get_time_in_n_min_range(time_diff, time_range_length)
                if is_arriveBy:
                    time_range_hits['arriveBy']['n'] += 1
                    if time_range in time_range_hits['arriveBy']:
                        time_range_hits['arriveBy'][time_range] += 1
                    else:
                        time_range_hits['arriveBy'][time_range] = 1
                else:
                    time_range_hits['departAt']['n'] += 1
                    if time_range in time_range_hits['departAt']:
                        time_range_hits['departAt'][time_range] += 1
                    else:
                        time_range_hits['departAt'][time_range] = 1

        r.close()

overall_timeranges = {}
for search_type, time_ranges in time_range_hits.items():
    file_path = 'results/%s.csv' % (search_type)
    directory = os.path.dirname(file_path)
    try:
        os.stat(directory)
    except:
        os.mkdir(directory)
    f = open(file_path, 'wb')
    w = unicodecsv.writer(f, encoding='utf-8')
    w.writerow(('range', 'hits', 'percentage'))
    total_hits = time_ranges['n']
    del time_ranges['n']
    sorted_timeranges_list = sorted(time_ranges.items(), key=lambda kv: int(kv[0].split(' ')[0]))
    for time_range_hit_tuple in sorted_timeranges_list:
        w.writerow((time_range_hit_tuple[0], time_range_hit_tuple[1], (time_range_hit_tuple[1] / total_hits) * 100))
    f.close()