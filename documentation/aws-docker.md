# Using AWS Container Services to deploy LARA Staging (the story so far).

The basic objective was to get the LARA staging server (authoring.staging.concord.org) running in containers in AWS.  This will ultimately mean easier, more reliable deployments, and the ability to upgrade infrastructure (such as ruby version).

Requirements for success:

* ✔ Rails server running in a container
* ✖ Background jobs running in another container
* ✖ Migrate data from the existing staging database
* ✖ Configure environment & access tokens to communicate with has.staging and learn.staging

I tried several approaches, and settled on the minimum requirement of getting a rails server booted on port 80 in a single-container elastic beanstalk as specified by `Dockerrun.aws.json`.  A docker image had to be built `knowuh/lara`.  I used the AWS command line tool `eb` to set up the beanstalk.

### Other approaches that I tried, along with the issues encountered:

- Creating a container cluster and tasks in ECS (Amazons container services).
    - This approach had too many options, and too much granularity of control.
    - ECS is supposed to work with normal `docker-compose.yml` files, but it didn't support several normal docker-compose commands.
    - ECS didn't allow developers to specify `Dockerfile`s in `docker-compose.yml`(each container had to specify a pre-built image, see above `knowuh/lara` comment)
    - It wasn't obvious how to connect with to the Amazon RDS servers.
    - Hard to setup autoscaling.
- Using command line `docker-machine create -d amazonec2 aws`
    - This technique **probably would** have worked.
    - Poor support for other AWS services (RDS in particular)
    - Questions about load-balancing and scaling
- EB Multicontainer
    - This is **probably the correct answer**  I kept getting an error that the `Dockerrun.aws.json` file specified an invalid version number (version 2).  I tried quotes and not in quotes. Later I found out that the issue was probably due to incorrectly initializing the elastic beanstalk stack `eb init` and specifying a single-container instance. Its not possible to change that after the fact, apparently:
        - [see this stack overflow article on the issue](http://stackoverflow.com/questions/30137895/version-error-in-aws-elastic-beanstalk-for-multicontainer-docker-configuration)
    -  *TODO:* Re-try the setup using `eb init` again (after moving .eleasticbeanstalk and .ebextensions folder)


### Other miscellaneous concerns and things to try:
   - Seed the Elastic Beanstalk RDS database from RDS snapshot. This is an option when first adding a database to elastic beanstalks from the AWS console.
   - Add collaborators [dockerhub](https://hub.docker.com/), to enable the building of the `knowuh/lara` docker image, so that they can contribute using these commands:
       - `docker build -t knowuh/lara`
       - `docker push knowuh/lara`
