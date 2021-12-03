# digitransit-tools
Miscellaneous tools and scripts for digitransit maintenance tasks and operations

## Matomo tools

Can be found under [matomo directory](matomo/) and there also exists [more detailed documentation](matomo/README.md) for them.

## DEM tools

Tools for creating an optimized elevation model for OpenTripPlanner. Can be found under [dem-tools](dem-tools/) with more detailed [documentation](dem-tools/README.md).

## gtfsdb2pg

Query GTFS data with SQL. Writes GTFS data to Postgres Docker container. Can be found under [gtfsdb2pg](gtfsdb2pg/) [documentation](gtfsdb2pg/README.md)..

## dl.sh

Run OTP dataload after 5 minutes and reset the cronjob execution time after the dataload.

For example:

./dl.sh hsl-prod &

Note & at the end, to detach the bash from sleeping script.