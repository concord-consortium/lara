## General Setup

We are using Rancher to manage our docker hosts and containers on AWS.
Rancher has a web UI to inspect and configure the setup.
The docker hosts are running RancherOS, which can be configured using a cloud-init structure
passed through the userdata when AWS EC2 starts up an instance.

LARA is autoscaled using AWS EC2 autoscaling. When the autoscaller launches a new host, the new
host contacts rancher and rancher then adds all of the configured docker containers to the host.

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

## AWS Autoscaling setup

Currently the autoscaller is using a 'pre-provisioned' ami.
The ami was created by:
- launching an instance with the rancheros-0.4.2 ami
- using the same userdata as below
- waiting for it to show up in the rancher UI and finish initializing
- it was removed from the rancher UI (this seems to stop all of the rancher managed containers)
- the rancher state was removed based on these instructions:
    http://docs.rancher.com/rancher/faqs/agents/#using-a-cloned-vm
- the existing containers were stopped and removed, otherwise they can conflict with the containers rancher
  sets up.  This is done with `docker rm -v $(docker ps -a -q)` (you might need to kill the containers first)
- the cloud-init system containers were removed which seems to be necessary to clear out any userdata from the previous launch:
`sudo system-docker rm -v cloud-init-pre; sudo system-docker rm -v cloud-init`. The cloud-init container seemes to save the
the configuration that is passed in through the EC2 userdata, so on restart this configuration is loaded. Which means the 
instance will join the rancher environment used to create the AMI.
- the instance was shutdown from using `shutdown -h now`, and then imaged in the AWS console

Without this preprovisioned ami, starting a host up can take over 12 minutes. Alternatively it might be just as fast
if we ran our own docker caching repository. Even with the preprovisioned ami I still sometimes see 11 minute start up times
so it isn't clear if the pre-provisioned approach is actually worth it.

Here is the current userdata with senstive info removed:

```
#cloud-config
write_files:
  - path: /root/.aws/credentials
    permissions: "0600"
    owner: root
    content: |
      [default]
      aws_access_key_id = [iam account with cloudwatch access]
      aws_secret_access_key = [iam account with cloudwatch access]
rancher:
  docker:
    args: [daemon, --log-driver, awslogs, --log-opt, awslogs-region=us-east-1, --log-opt, awslogs-group=lara-docker-staging, -s, overlay, -G, docker, -H, 'unix:///var/run/docker.sock', --userland-proxy=false]
  services:
    rancher-agent1:
      image: rancher/agent:v0.10.0
      command: [rancher url specific for environment]
      privileged: true
      volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      environment:
        CATTLE_HOST_LABELS: application=lara-staging
    update_filesystem_size:
      image: slamper/disk_resizer
      privileged: true
```

The rancher-agent parts of this cloud-config were based on the information provided here:
http://docs.rancher.com/os/running-rancher-on-rancheros/

#### Autoscaling Issues:

During an upgrade of a service, the health check will fail, and if it fails twice the autoscaller will
shut down the instance. Ideally what we want is for the instance to be removed from the load balancer
but not terminated by the autoscaller. It is possible to tell the autoscaller to not shutdown hosts that fail
healthchecks. So that will need to be work around for now when doing upgrades.

Originally we also had a rancher based loadbalancer on each host. That approach also should have prevented the problem above.
However these loadbalancers actually sent requests to each of the hosts not just the host it was running on. That approach
complicated things, because the now a health check by the ELB was not really reporting the health of the host but of a random
host in the grouping.

### Notes about issues with hostname in rancher

When RancherOS 0.4.3 is started, the 'name' for a host displayed in rancher is just
'rancher'. Originally this was not a problem. It seemed that the 0.4.3 upgrade caused the problem, but going back to 0.4.2
didn't solve it.

I tried adding a label to the rancher-agent config in the userdata to make sure it started after
cloud-init set the host name but that didn't help. `io.rancher.os.after: cloud-init`

It seemed the rancheros 0.4.3 ami had a problem with configuring the hostname. However it seems 0.4.2 also has a problem with the hostname after it has been imaged, see below for more details. So we should be able to switch to RancherOS 0.4.3.

When using the pre-built ami described above, the hostname is that of the of the cloned server.  However
when I upgraded rancher, it restarted the agents and that updated the host name. cloud-init is supposed to connect to ec2 and get the correct hostname, but it doesn't seem to do this. Another clue is that when using `system-docker inspect` on any of the stopped or running containers they all also list this wrong hostname. So the problem might be that the containers get this hostname when they were are initialy launched. Now when the AMI is made their config is saved on disk and when the AMI is booted again this hostname is used instead of cloud-init fetching a new one.

In the AMI creation steps above the cloud-init container is removed before making the AMI. The hope was this would fix the problem. It did not. The rancher os startup.yml file is what initially launches all of these services so perhaps there is someway to tweak
it that will fix the problem.

- when launching the AMI that was created with the process above it seems to join the rancher host even though all of the containers were removed. This implies that the process above of cleaning the instance isn't good enough. Like the userdata from the original image is still located somewhere on the disk.

To solve both of these problems I tried removing the cloud-init containers with:
sudo system-docker rm -v cloud-init-pre
sudo system-docker rm -v cloud-init

this approach above did not help with the hostname problem. But it did prevent the host from being added to rancher.
This will have to do. If I explore this more I'd start with the basic rancher OS AMI launch it, image it and launch it again to see what happens with the hostname.  My suspicion is that cloud-init stores some cache info about the EC2 information on a shared volume. And it doesn't refetch the data.

## Thing still to improve

### Reaping host definitions from rancher

Currently when a host is shutdown in EC2 the host definition in rancher is not removed.
It is stuck in a 'reconnecting' state. It seems sometimes this can prevent new hosts from
getting the services configured on them.

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
- starting or upgrading a new server might be faster because the lara container wouldn't need to contain nginx
too.

## Other Annoying issues:

- One thing that is difficult is that the file system of system-docker (/var/lib/system-docker) is not mounted in the console container. So it is not possibly to inspect the layers created by cloud-init and others. It looks like they might have changed this in the next release of RancherOS.

- during local testing, the virtualbox machine setup by docker-machine seems to loose its
internet connection sometimes. This is the same thing I've experience with Virtual Box.
I'm sure not under what conditions it happens.

- the delayed job worker logs info each time it wakes up and looks for new jobs, so this makes the default log full of
mostly pointless messages.

