FROM ghcr.io/concord-consortium/docker-rails-base-private:ruby-2.3.7-rails-3.2.22.25

RUN echo 'deb http://archive.debian.org/debian/ stretch main' > /etc/apt/sources.list
RUN apt-get update

# install nginx
RUN apt-get install -qq -y nginx

# install foreman
RUN gem install foreman

# if this is changed it also needs to be changed in nginx-sites.conf and unicorn.rb
ENV APP_HOME /lara

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile

# need to copy the Gemfile.lock created during build so it isn't overriden by the following add
RUN bundle install --without development test && \
    cp Gemfile.lock Gemfile.lock-docker
ADD . $APP_HOME

# get files into the right place
RUN mv -f Gemfile.lock-docker Gemfile.lock && \
    cp config/database.sample.yml config/database.yml && \
    cp docker/prod/app_environment_variables.rb config/

## Configured nginx (after bundler so we don't have to wait for bundler to change config)
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

# Add default nginx config
ADD docker/prod/nginx-sites.conf /etc/nginx/sites-enabled/default

# forward nginx request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# set production
ENV RAILS_ENV=production


# We need to fake an ENV Var for the precompile: https://github.com/rails/rails/issues/32947
# Run precompile rake task in order to at least generate the manifest file
RUN SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# pass in a version while building with --build-arg LARA_VERSION=x.y.z
ARG LARA_VERSION
ENV LARA_IMAGE_VERSION=$LARA_VERSION

EXPOSE 80

CMD ./docker/prod/run.sh
