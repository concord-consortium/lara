
## How to run a local development version of LARA in docker containers

1. install dash:

		bash <(curl -fsSL https://raw.githubusercontent.com/IFTTT/dash/master/bin/bootstrap)


1. open a new shell, so that your dash environment will work.
1. Spin up the docker containers using `dev up` - This is a wrapper around docker-compose up.
1. check to see if your web servers have started `open http://web.dev` - This will display a simple hello world container.
2. run `dev log` to watch the logs of all the containers.
3. run tests with `dev run test`
4. then try `open http://app.dev` - This should display an empty LARA portal.

## The docker-compose.yml file

Main things to notice about docker-compose.yml:

1. TBD: Uses DNS entries for linking service (not a recommended practice, but is used in the dash examples, touted as a feature).
2. Uses a volume container for cached gem files. Created by example from [Make bundler fast again in Docker Compose](http://bradgessler.com/articles/docker-bundler/) and [How to cache bundle install with Docker](https://medium.com/@fbzga/how-to-cache-bundle-install-with-docker-7bed453a5800#.dft6jtbva)
3. Tasks which require gems have to check that the gems are up to date first. See startup scripts:
	- [../scripts/docker_app.sh](../scripts/docker_app.sh)
	- [../scripts/docker_test.sh](../scripts/docker_test.sh)

## Tools used

- [Dash](https://github.com/IFTTT/dash/)
	   - Shell script which add [ansible](http://www.ansible.com/)
       - Adds [`bootsync.sh`](https://github.com/IFTTT/dash/blob/master/docker/bootsync.sh) to the virtual machine running the docker server. This configures DNS and NSF for that virtual machine.
       - Adds two running containers to the docker server, for handling:
	       -  [dnsmasq](https://github.com/andyshinn/docker-dnsmasq)
	       - [nginx-proxy](https://github.com/jwilder/nginx-proxy)
       - Adds containerized DNS server to the local host machine's `/etc/resolver/dev`
       - Wraps several docker commands with a `dev` command.
       - Expects to use a docker-machine named 'dev'.
- [Docker Machine](https://docs.docker.com/machine/).
       - Manages virtual machines to run docker server on.
       - Default virtual machine is called 'default' that Kitematic expects.
       - Can be setup to use machines on Amazon, other services.
- [DockerCompose](https://docs.docker.com/compose/)
       - Orchestrate an app using several docker containers.
       - Maps ports & services between the containers

## Tools not used

Because Dash does so many useful things for us, it means we don't need to (or cant) use these other tools for the moment.

- [Kitematic](https://kitematic.com/)
       - a nice GUI for inspecting / installing / running containers on a docker-machine.
       - Is also a wrapper for docker-machine and other commands. (like dash)
       - Expects to use the docker-machine named 'default'
- [Docker Toolbox](https://www.docker.com/docker-toolbox) One click installer for:
	- virtual box
	- docker
	- docker-machine
	- docker-compose

##TODO
- Run Javascript tests in the container.
	- requires that we build a base-image with phantomjs.
- Run Guard in Container.
- Publish lara base image for faster installs
- Add database containers (for saving / transferring data)
- Setup a Portal server dep (snapshot of portal container?)
- Forman for background jobs(?)
- Run background jobs in in different container.

> Written with [StackEdit](https://stackedit.io/).
