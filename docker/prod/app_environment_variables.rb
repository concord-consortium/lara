ENV['LOGGER_URI']                        ||= 'https://logger.concord.org/logs'
ENV['LOGGER_APPLICATION_NAME']           ||= 'LARA-log-poc'

ENV['LABBOOK_PROVIDER_URL']              ||= 'https://labbook.concord.org'

# this specifies a | separated list of urls for interactives
# these special interactive URLs trigger LARA to conver their associated LabBook to
# upload LabBook
ENV['UPLOAD_ONLY_MODEL_URLS']            ||= ''
ENV['MODEL_JSON_LIST_URL']               ||= 'https://itsi.portal.concord.org/interactives/export_model_library'
