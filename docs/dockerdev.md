## How to run a local development version of LARA in docker containers

For now the best source of information about how to setup a docker development environment can be found in the [Portal  docker documentation](https://github.com/concord-consortium/rigse/blob/master/docs/docker.md)

## Running LARA in a docker container

Run the command: `docker-compose up`

## Creating an admin account

- Go to [http://localhost:3000/users/sign_up](http://localhost:3000/users/sign_up) (or whatever port is assigned by docker).
- Run the command `docker-compose run --rm app bundle exec rake lightweight:admin_last_user`
- Then login with this account at [http://localhost:3000/users/sign_in](http://localhost:3000/users/sign_in)

Here are some notes that are specific to configuring `docker-compose` in LARA.

### ENV variables ###

To test C-RATER features it may be useful to set the environment variable:

      ENV['C_RATER_FAKE']                    ||= 'true'

The best palce to do this would be in a `.env` file at the root of this directory.


## Running tests in docker containers for developers:

To run all the (non phantom) spec tests:
`docker-compose run --rm app docker/dev/run-spec.sh`
