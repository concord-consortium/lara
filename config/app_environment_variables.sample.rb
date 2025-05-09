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

ENV['LOGGER_URI']                        ||= 'https://logger.concord.org/logs'
ENV['LOGGER_APPLICATION_NAME']           ||= 'LARA-log-poc'
ENV['ROLLBARS_KEY']                      ||= 'XXXXXXX'
ENV['LABBOOK_PROVIDER_URL']              ||= 'https://labbook.concord.org'

# this specifies a | separated list of urls for interactives
# these special interactive URLs trigger LARA to convert their associated LabBook to
# upload LabBook
ENV['UPLOAD_ONLY_MODEL_URLS']            ||= "https://models-resources.concord.org/itsi/upload_photo/index.html"
ENV['MODEL_JSON_LIST_URL']               ||= 'https://itsi.portal.concord.org/interactives/export_model_library'

# Set the portal version displayed in the UI footer.
ENV['LARA_VERSION']                      ||= ''
