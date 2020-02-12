# Scripts for using docker hub API

## replace_tags.sh
This script can be used to push dummy minimal image to replace data build images between dates. [Deleting tags is too complicated](https://github.com/docker/distribution/pull/2169). Currently this script only works for opentripplanner-data-container and hsl-timetable-container images.

#### Configuration
It is possible to change the behaviour of the data builder by defining environment variables.

* "START" defines start date in `%Y-%m-%d` format.
* "END" defines last date in `%Y-%m-%d` format.
* "IMAGE" defines what image under an organization should be updated
* (Optional, default latest) "TAG" defines postfix for image tags. For example, in `2019-10-07-latest` latest is the tag.
* (Optional, default hsldevcom) "ORG" defines what organization images belong to in the remote container registry.
