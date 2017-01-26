# TorPool

[![DOI](https://zenodo.org/badge/18922/JusteRaimbault/TorPool.svg)](https://zenodo.org/badge/latestdoi/18922/JusteRaimbault/TorPool)

## Description

java application managing a pool of `tor` instances in parallel, allowing to switch IP rapidly on demand from an external app (api not designed to use a large number of tor ip at the same time, even if it can be done).


## Usage

Run the pool in background : `java -jar torpool.jar Nthreads` [note : tor data is stored in `.tor_tmp` folder where the pool is launched]
`tor` command is assumed installed ; you can specify an alternative tor command by putting it in `conf/torcommand` file.

The java API class that you can embed in your app provides a `setupTorPoolConnexion()` method to establish connexion with the pool (and sets up localhost proxy with first tor task port) ; the `switchPort()` method allows then to change tor port (and thus current IP) on demand (e.g. to be triggered when IP is blocked by a crawled victim).

No api for other languages ; can eventually be done depending on special needs.

