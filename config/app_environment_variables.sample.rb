# First portal listed is the "Default Authentication Portal"
ENV['CONCORD_CONFIGURED_PORTALS']        ||= 'LOCALHOST HAS_STAGING'
ENV['CONCORD_LOCALHOST_URL']             ||= 'http://localhost:9000/'
ENV['CONCORD_LOCALHOST_CLIENT_ID']       ||= 'localhost'
ENV['CONCORD_LOCALHOST_CLIENT_SECRET']   ||= 'XXXXXX'
ENV['CONCORD_HAS_STAGING_URL']           ||= 'http://has.staging.concord.org/'
ENV['CONCORD_HAS_STAGING_CLIENT_ID']     ||= 'localhost'
ENV['CONCORD_HAS_STAGING_CLIENT_SECRET'] ||= 'XXXXXX'
ENV['CONCORD_HAS_STAGING_DISPLAY_NAME']  ||= 'Has Staging Portal'  # Optional param

ENV['SECRET_TOKEN']                      ||= 'use `rake secret` to generate'
ENV['S3_KEY']                            ||= 'xxxxxxxxxxxxx'
ENV['S3_SECRET']                         ||= 'xxxxxxxxxxxxx'
ENV['S3_BIN']                            ||= 'ccshutterbug'
