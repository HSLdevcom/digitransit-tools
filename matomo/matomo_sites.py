import requests

SITES = {
    'hsl': {
        '4': 'HSL Reittiopas',
    },
    'finland': {
        '6': 'Digitransit / Matka.fi'
    },
    'waltti': {
        '11': 'Digitransit Joensuu',
        '27': 'Digitransit Turku',
        '14': 'Digitransit Hameenlinna',
        '15': 'Digitransit Jyvaskyla',
        '16': 'Digitransit Kuopio',
        '17': 'Digitransit Lahti',
        '18': 'Digitransit Lappeenranta',
        '21': 'Digitransit Oulu',
        '29': 'Digitransit Kotka',
        # '31': 'Digitransit Mikkeli', Not enough users to fetch meaningful data
        '35': 'Digitransit Tampere',
        '43': 'Digitransit Kouvola',
        '49': 'Digitransit Rovaniemi',
    }
}

# returns sites from given collections (default all) which user has access to
def get_matomo_sites(token, collections=['hsl', 'finland', 'waltti']):
    cert = 'client.pem'

    params = {
        'module': 'API', 'method': 'SitesManager.getSitesWithAtLeastViewAccess',
        'format': 'json', 'token_auth': token}
    r = requests.get('https://digiaiiris.com/web-analytics/', params=params, cert=cert)

    available_sites = r.json()

    r.close()

    valid_sites = []
    for site in available_sites:
        site_id = site['idsite']
        for collection in collections:
            if site_id in SITES[collection]:
                valid_sites.append((site_id, SITES[collection][site_id]))

    return valid_sites
