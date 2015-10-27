
## Run a development version of LARA in docker container using Vagrant

1. install [vagrant](vagrantup.com)
1. install docker-compose plugin `vagrant plugin install vagrant-docker-compose`
1. copy settings files:
		1. `cp ./config/databse.sample.yml ./config/databse.yml`
		2. `cp ./config/app_environment_variables.sample.rb ./config/app_environment_variables.rb`
		3. at a minimum you should edit the value for `SECRET_TOKEN` in  `app_environment_variables.rb`.
		It might be best to ask another dev for a copy of this file.
1.  From a shell in this directory enter these items on the command line:
	1. `vagrant up`  - Starts the virtualbox VM, installs docker, and provisions containers. Might take a while to complete.
	1. `vagrant ssh` – Open a shell on the virtualbox machine.
	1. `cd /lara` – Move to the working directory of shared project folders.
	1. `docker-compose up` - Starts the application server & database server.
	1. `docker-compose run app script/docker-test.sh` – runs guard

If vagrant isn't syncing files in a way that works with guard try this:

		vagrant rsync-auto

## Details

* Running `docker-compose <verb> <service> (args)` from the Vagrant virtualbox
box is the default way to spin up, build, or remove containers identified as
`service` in `docker-compose.yml`

* Running `docker-compose` by itself should show a list of verbs.

* Containers will be reused when possible.

##TODO
- Simplify the above instructions. `docker-compose up` should just work.
- Add database containers (for saving / transferring data)
- Run Javascript tests in the container.
	- requires that we build a base-image with phantomjs.
- Publish lara base image for faster installs
- Run background jobs in in different container.
