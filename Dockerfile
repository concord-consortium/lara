FROM ruby:1.9.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# for phantomjs
# RUN apt-get install -y  build-essential g++ flex bison gperf ruby perl \
#   libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
#   libpng-dev libjpeg-dev python libx11-dev libxext-dev
#
#
# RUN git clone git://github.com/ariya/phantomjs.git &&\
#   cd phantomjs &&\
#   yes | ./build.sh

# for nokogiri
# RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
# RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs

# clean up ruby / gems / bundler
RUN gem update --system
RUN gem update bundler
RUN gem install debugger-ruby_core_source

ENV APP_HOME /myapp
RUN mkdir /myapp
WORKDIR /myapp

ADD Gemfile* $APP_HOME/

# --- Add this to your Dockerfile ---
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile

ADD . $APP_HOME
RUN bundle install
