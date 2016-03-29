## Open a rails console from the command line:

For simple stuff you can use the Rancher UI. It has an "Open Console" in the menu of containers.
Copy and paste is supported using the mouse. Keyboard copy and paste uses non standard keys.

For more complex console work you probably want a native console instead:

- `ssh -i [devops.pem location] rancher@[public hostname of a lara-docker server]`
- `docker ps` (to find the name of the containers)
- `docker exec -it r-lara-staging_app_1 bash` (note the name of app container might be different)
- `rails c`

With a little work it seems we could setup a tool that would make this easier. It could query AWS to automate the
steps above.  Or it could use the node library term.js-cli to connect to the rancher server console API.
Ideally a developer would just run something like `rancher lara-staging run rails console`.
That might be possible by combining rancher-compose with the rancher api and term.js-cli.
Or possibly by using rancher-compose, the rancher api, and ec2 api.
It would be worth discussing this with the rancher devs.

## Work with rancher server on commandline:

This is probably not needed often. I used it once to be able to run the mysql client
on the rancher server because that is a good place that has access to the mysql database.

- ssh into rancher-server instance (it is rancheros so user is rancher)
- run `docker ps` to find the name of the containers
- run `docker exec -it [rancher container name] bash`

If you do need to connect with mysql you'll need to look up the ENV variables that were used
when the rancher container was launched.

## New relic server monitoring

Currently this is setup inside of the lara stack in rancher. The server monitor is a system level service that mounts
several folders. However the drive mounting and the /proc mounting was not easy to setup at the time it was setup
so some metrics are not correct about the server. However by having it setup, it does at least let NR know we are using
docker which shows up in the UI as a server with multiple containers running on it.

## Logs Sent to AWS CloudWatch

The AWS instances used by Rancher to host LARA are started by a AWS LaunchConfiguration.  This LaunchConfiguration
has userdata set on which configures the AWS instances. One thing it configures is logging.
Currently this is done by changing the commandline for the docker daemon used by RancherOS.
And additionally there are a few AWS credentials configured in this userdata.

With this configuration, the names of the log streams in AWS cloudwatch are the docker id's of the containers.
The "Docker ID" can be found in rancher by looking at the container details page.

This could be improved if we had a utility service that listed all of the rancher managed containers and constructed
URLs to the log streams for each container. Or even better if the rancher UI let us add links to resources by
using link templates that were populated with properties from the resource.

## Thing still to improve

### Slow startup time of hosts

We want to experiment with making an ami from a machine in EC2 that is already setup.
And use that AMI to start things up. It should avoid the need for a few parts of the
startup. However the 100GB disk size will make it slow to start (since AWS doesn't know)
what is really needed on that disk.  So to make it start fast, we need to do something
like this:
http://cloudacademy.com/blog/amazon-ebs-shink-volume/
-or- we need to provision things on a smaller server manually (outside of the load balancer)
Also before snapshoting the clone we need to do this:
http://docs.rancher.com/rancher/faqs/troubleshooting/#using-a-cloned-vm
It is possible that just detaching the clone will do the same thing.

I suspect that something like docker swarm might also improve the startup time. Ideally
the swarm would share a image cache.

### Reaping host definitions from rancher

Currently when a host is shutdown in EC2 the host definition in rancher is not removed.
It is stuck in a 'reconnecting' state.

One approach to fix this is to have a reaping service running that looks for these stuck
hosts in rancher, and then checks if their machine exists in EC2. If not then it destroys
the host in rancher.

Another approach is to have a service on the machine, that catches the termination signal.
And then tells the rancher to remove the host definition. That would work this way:
- on startup a system-docker container could query rancher api for hosts
- still on startup it would then match itself based on hostname
- then on termination it sends the commands to rancher to shut the host down

This will not work if the host dies without sending the termination.
Keys that provide full access to rancher api will need to be given to this service.
They can be isolated to that service, however someone that got access to the host would
be able to access these keys. The other services and system level containers would not
have access to the keys.

Another approach (not sure if it is possible yet):
- setup the autoscaler to notify a SNS when the machine is terminated
- that SNS is configured with a webhook to a service running on the rancher-server
- (or the service is polling the SNS somehow)
- this service then has the access key to update rancher
A benefit of this approach is that only the rancher server has this key not all
of the hosts. And the hosts don't need any special configuration.

### Adding Version info to LARA webpages

Currently the docker app doesn't show any version info.

There are a couple of ways to go about this:
- get the git branch or tag into the image, and then have the web app render it for users
- get access to the image tag that the current container was created from, and show that to the user

Inorder to put the git branch or tag in the image it requires the system building the image to
provide this information to the process doing the building. DockerHub builds do not provide this info.
If the image is built and pushed from Travis then the information is provided. So using Travis seems
the best option for taking this approach.
One way to do this is for the Dockerfile to declare a build argument. And then in the docker build 
command run by Travis it would would pass the Git branch to this argument. The dockerfile can provide
it to the image as an environment variable. Or it could run a command to inject it into the version.yml
file that is already supported by LARA.

Inorder to get the image tag that the container was started from. This approach could be used:
- the lara app queries the meta-data service to get the container uuid.
- then it quieries the rancher API to get find the matching container and then get its imageUuid
- the imageUuid shows the image name and tag

It might be best to run this in an initializer at the startup of the app, however it could slow down the
loading of the app. Another approach is to only run this from a second info page in the UI. This second
page could even provide links into rancher UI for the stack and the service.

One danger with using the rancher API from the app container is that it opens a security hole. We can provide
readonly access to rancher API. But in the results rom the API are all of the secret keys for the app.
Providing access to those generally to the app doesn't seem like a good idea.

### Pull nginx out of lara container

A separate nginx container can be used that proxies all requests to LARA.  And it would be setup to 
agressively cache the assests from the LARA container. Benefits:
- we can drop Foreman.
- the logging would be more clear: standard out from nginx will go to one stream, and lara to another stream

## Other Annoying issues:

- during local testing, the virtualbox machine setup by docker-machine seems to loose its
internet connection sometimes. This is the same thing I've experience with Virtual Box. 
I'm sure not under what conditions it happens.

- the delayed job worker logs info each time it wakes up and looks for new jobs, so this makes the default log full of
mostly pointless messages.


