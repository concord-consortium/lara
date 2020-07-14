ENV['SHUTTERBUG_URI']                    ||= "//snapshot.concord.org/shutterbug"
ENV['LOGGER_URI']                        ||= '//cc-log-manager.herokuapp.com/api/logs'
ENV['LOGGER_APPLICATION_NAME']           ||= 'LARA-log-poc'

ENV['LABBOOK_PROVIDER_URL']              ||= 'https://labbook.concord.org'

ENV['ACTIVITY_PLAYER_URL']               ||= 'https://activity-player.concord.org/branch/master'

# this specifies a | separated list of urls for interactives
# these special interactive URLs trigger LARA to conver their associated LabBook to
# upload LabBook
ENV['UPLOAD_ONLY_MODEL_URLS']            ||= ''
ENV['MODEL_JSON_LIST_URL']               ||= 'https://itsi.portal.concord.org/interactives/export_model_library'
