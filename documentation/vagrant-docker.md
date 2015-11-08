



# Setting up developers to work on LARA in docker containers.

Developing in docker containers will give us a more robust, consistent, and easy to setup development environment.  We should anticipate using docker for deployment soon too. There will be some growing pains, and an adjustment period, but we should start this effort now.

There are (at least) two ways to setup docker on mac OSX.  The simplest method is to install the latest version [docker toolbox for mac](https://www.docker.com/docker-toolbox). This installer includes docker-machine, a tool which boots up a [virtualbox](https://www.virtualbox.org/) VM behind the scenes which is our docker server. While this is the most simple method, it doesn't easily allow us to configure the VM or the file sharing preferences required to get automatic continuous testing working as we are used to with Guard. We can also use [vagrant]() to configure, build, and control a [virtualbox](https://www.virtualbox.org/) vm. This means we have to jump through a few more hoops, but it gives us a way to configure VM shares and other features for windows and mac developers.

## Using Vagrant

1. install [virtualbox](https://www.virtualbox.org/)
2. install [vagrant](vagrantup.com)
1. install docker-compose plugin:  `vagrant plugin install vagrant-docker-compose`
1. install the hostmanager plugin: `vagrant plugin install vagrant-hostmanager`
1. copy settings files:
		1. `cp ./config/database.sample.yml ./config/database.yml`
		2. `cp ./config/app_environment_variables.sample.rb ./config/app_environment_variables.rb`
		3. at a minimum you should edit the value for `SECRET_TOKEN` in  `app_environment_variables.rb`.
		It might be best to ask another dev for a copy of this file.
1.  From a shell in this directory enter these items on the command line:
	1. `vagrant up`  - Starts the virtualbox VM, installs docker, and provisions containers. Might take a while to complete.
	1. `vagrant hostmanager` – will ask you for admin password on your machine.  Will add entries to /etc/hosts
	1. `vagrant ssh -c "cd /lara && docker-compose up"` - Starts the application server & database server.
	1. You should now be able to see your app server running at `http://app.lara`
	1. You should also have a web server running at `http://hello.lara`
	1. `vagrant rsync-auto` – Starts auto rsync  (mac only)
	1. `vagrant ssh -c "cd /lara && docker-compose run app script/docker-test.sh"` – runs guard

### Details

* If you want to poke around the rails server by hand to run the console or whatever, you can open a shell in the app container by running `vagrant ssh -c "cd /lara && docker-compose run bash`
* Running `docker-compose <verb> <service> (args)` from the Vagrant virtualbox box is the default way to spin up, build, or remove containers identified as `service` in `docker-compose.yml`
* Running `docker-compose` by itself should show a list of verbs.
* There is a script `script/vdoc.rb` which can reduce some of the boilerplate typing.  eg `script/vdoc.rb test` will start guard.


### Loading your old data:

If you have some Authoring data you would like to import into your container,
you can do so with this command, run from the vagrant virtual machine:

`docker-compose run mysql -uroot -p$MYSQL_ROOT_PASSWORD lara_production < lara.sql`

## Using docker-machine:

You can run `docker-machine` locally, and then issue `docker-compose`
without using a vagrant VM.  But inn that case, file shares may be very slow. For a more elaborate setup, complete with dynamic DNS is available by using [dash](https://github.com/IFTTT/dash). Read more about it in this [blog post](http://engineering.ifttt.com/oss/2015/10/06/developing-with-docker/).

#TODO
- Simplify the above instructions. `docker-compose up` or similar should just work.
- Run Javascript tests in the container.
	- requires that we build a base-image with phantomjs.
- Run background jobs in in different container.
