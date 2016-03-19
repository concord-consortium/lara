FROM ruby:1.9.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# for a JS runtime
RUN apt-get install -qq -y nodejs

# install software-properties-common for add-apt-repository
RUN apt-get install -qq -y software-properties-common

# install nginx
RUN apt-get install -qq -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

# Add default nginx config
ADD docker/prod/nginx-sites.conf /etc/nginx/sites-enabled/default

# forward nginx request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# install foreman
RUN gem install foreman

# clean up ruby / gems / bundler
RUN gem update --system
RUN gem update bundler
# get rid of old bundler version
RUN gem cleanup bundler
RUN gem install debugger-ruby_core_source

# if this is changed it also needs to be changed in nginx-sites.conf and unicorn.rb
ENV APP_HOME /lara

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

# Add default unicorn config
ADD docker/prod/unicorn.rb $APP_HOME/config/unicorn.rb

# Add default foreman config
ADD docker/prod/Procfile $APP_HOME/Procfile

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile
RUN bundle install --without development test
ADD . $APP_HOME

# set production
ENV RAILS_ENV=production

# compile the assets - NOTE: config.assets.initialize_on_precompile MUST be set to false in application.rb for this to work
# otherwise somewhere in the initializers it tries to connect to the database which will fail
RUN bundle exec rake assets:precompile

EXPOSE 80

CMD ./docker/prod/run.sh
