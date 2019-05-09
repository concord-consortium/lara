## How to run a local development version of LARA in docker containers

For now the best source of information about how to setup a docker development environment can be found in the [Portal  docker documentation](https://github.com/concord-consortium/rigse/blob/master/docs/docker.md)

### ENV variables ###

To test C-RATER features it may be useful to set the environment variable:

    C_RATER_FAKE=true

The best place to do this would be in a `.env` file at the root of this directory.
