# OTP tools

This directory contains tools to help with OTP routing service operation.

## Quick example - build OTP configuration for unpreferred lines

```sh
./fetch-gtfs.sh hsl 2 dev
./match-routes.sh gtfs/hsl-v3-dev-gtfs.zip | ./build-array.sh HSL
```

## `fetch-gtfs.sh`

Fetch GTFS data packages from digitransit routing data server.

**Usage:**

Fetch HSL OTP2 development data:

```sh
./fetch-gtfs.sh hsl 2 dev
```

## `match-routes.sh`

A tool which reads a GTFS file (.zip) as input and outputs all route ids which
match to optional regular expressions.

**Usage:**

List matching route ids:

```sh
./match-routes.sh GTFS_FILE [REGEXP]
```

Build feed scoped JSON array:

```sh
./match-routes.sh GTFS_FILE | ./build-feed HSL
```

Default value for `REGEXP` is `^(21(4[3-9]|5[0-9]|6[0-5])(A|[B-Z]A).*|2321)$`.
This expression matches to Espoo bus lines which should be avoided if reasonable
alternate itinerary with subway exists.
