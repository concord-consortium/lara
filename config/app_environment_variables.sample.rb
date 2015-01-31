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

# Decides whether SVG Edit ('svg-edit' or undefined) or CC Drawing Tool ('drawing-tool') should be used.
ENV['CONCORD_DRAWING_TOOL']              ||= 'drawing-tool'
ENV['SHUTTERBUG_URI']                    ||= "//snapshot.concord.org/shutterbug"
ENV['LOGGER_URI']                        ||= '//cc-log-manager.herokuapp.com/api/logs'
ENV['LOGGER_APPLICATION_NAME']           ||= 'LARA-log-poc'

