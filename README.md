# digitransit-tools
Miscellaneous tools and scripts for digitransit maintenance tasks and operations

## Matomo tools

Can be found under [matomo directory](matomo/) and there also exists [more detailed documentation](matomo/README.md) for them.

## DEM tools

Tools for creating an optimized elevation model for OpenTripPlanner. Can be found under [dem-tools](dem-tools/) with more detailed [documentation](dem-tools/README.md).

## gtfsdb2pg

Query GTFS data with SQL. Writes GTFS data to Postgres Docker container. Can be found under [gtfsdb2pg](gtfsdb2pg/) [documentation](gtfsdb2pg/README.md)..

## fixvisuals.sh

Visual tests of digitransit-ui often fail because of minor changes in fonts. Your local computer finds a different version of the font as the travis CI environment.
Often the only way to make visual tests pass is to replace reference images with the versions generated by travis CI. fixvisuals.sh script helps to automate this process.
Fetch and extract the test package from dropbox (for example gemini-report-chrome.tar.gz) and place it into digitransit-ui folder together with the script.
Then run fixvisuals.sh and git commit the updated images.
