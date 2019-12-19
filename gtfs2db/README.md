# gtfsdb2pg

Query GTFS data with SQL.

Write GTFS data to Postgres(PostGIS) database running in [Docker](https://www.docker.com/) container using [gtfsdb](https://github.com/OpenTransitTools/gtfsdb).


# Install

Build a Docker image after cloning the repo:

`docker build -t gtfsdb2pg .`

# Run
Start a container running in localhost:5432. Replace MY-GTFS-ZIP-URL with your GTFS data.

`docker run -it -p 5432:5432 --name gtfsdb2pg -e MY-GTFS-ZIP-URL gtfsdb2pg`

Access the data in localhost:5432 with you're favorite DB tool. Or you can view it with `psql`:

`docker exec -it gtfsdb2pg pqsql postgres postgres`

# Example query

```
-- get first stop time of each trip for route_id 1
select * from trips t, stop_times st where t.route_id = '1' and t.trip_id = st.trip_id and st.stop_sequence = 1
```

```
-- get agency name and number of routes
select a.agency_name, a.agency_id, count(r.route_id) from routes r, agency a where r.agency_id = a.agency_id group by a.agency_id, a.agency_name order by 3 desc
```
