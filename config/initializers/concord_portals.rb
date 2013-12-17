raw_portal_config = File.read("#{Rails.root}/config/portal_config.yml")
CONCORD_PORTALS = YAML.load(raw_portal_config)[Rails.env]
# TODO: add logo_image, client_id and client_secret to YAML
# TODO: Move current YAML to sample and configure real 'secrets' in Chef
