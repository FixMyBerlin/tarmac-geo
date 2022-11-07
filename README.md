# tarmac-geo – custom vector tiles for bike infrastructure planning based on OpenStreetMap

# (!) This project is in alpha stage (!)

## About

This project will download, filter and process OpenStreetMap (OSM) data in a PostgreSQL/PostGIS Database and make them available as vector tiles with pg_tileserve.

The data we process is selected and optimize to make planning of bicycle infrastructure easier.

## Production

### Server

https://tiles.radverkehrsatlas.de/

### Data update

- Data is updated once a week, every monday ([cron job definition](https://github.com/FixMyBerlin/tarmac-geo/blob/main/.github/workflows/generate-tiles.yml#L3-L6))
- Data can manually updates [via Github Actions ("Run workflow > from Branch: main")](https://github.com/FixMyBerlin/tarmac-geo/actions/workflows/generate-tiles.yml).

### Deployment

1. https://github.com/FixMyBerlin/tarmac-geo/actions run
2. Then our Server IONOS builds the data. This take about 30 Min ATM.
3. Then https://tiles.radverkehrsatlas.de/ shows new data

## 1️⃣ Setup

First create a `.env` file. You can use the `.env.example` file as a template.

```sh
docker compose up
# or
docker compose up -d

# With osm processing, which runs the "app" docker image with `ruh.sh`
docker compose --profile osm_processing up -d
```

This will create the docker container and run all scripts. One this is finished, you can use the pg_tileserve-vector-tile-preview at http://localhost:7800/ to look at the data.

> **Note**
> We use a custom build for `postgis` in [db.Dockerfile] to support Apple ARM64

## 💪 Work

You can only rebuild and regenerate the whole system, for now. The workflow is…

1. Edit the files locally

2. Rebuild and restart everything

   ```sh
   SKIP_DOWNLOAD=true \
   SKIP_FILTER=true \
   docker compose --profile osm_processing build && docker compose --profile osm_processing up
   ```

3. Inspect the new results

**TODOs**

- [ ] Allow editing code direclty inside the docker container, so no rebuild is needed; change the re-generation-part
- [ ] Split of the downloading of new data

**Notes**

Hack into the bash

```sh
docker compose exec app bash
```

You can also run the script locally:

1. This requires a new user in postgres which is the same as your current user:
   ```sh
   sudo -u postgres createuser --superuser $USER; sudo -u postgres createdb $USER
   ```
2. Then copy the [configuration file](https://www.postgresql.org/docs/current/libpq-pgservice.html) `./config/pg_service.conf` to `~/.pg_service.conf` and adapt your username and remove the password.

**Build & Run only one container**
Build docker

```sh
docker build -f app.Dockerfile -t tarmac:latest .
```

Run it

```sh
docker run --name mypipeline -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d tarmac
```

Hack into the bash

```sh
docker exec -it mypipeline bash
```

## 💛 Thanks to

This repo is highly inspired by and is containing code from [gislars/osm-parking-processing](https://github.com/gislars/osm-parking-processing/tree/wip)
