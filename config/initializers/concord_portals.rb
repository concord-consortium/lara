# TODO: RITES, etc - and maybe store this in YAML?
CONCORD_PORTALS = {
  :concord_portal     => ENV['CONCORD_PORTAL_URL'], # Supports old stuff
  :dev                => 'http://localhost:9000',
  :has_staging        => 'http://has.staging.concord.org',
  :has_production     => 'http://has.portal.concord.org',
  :nextgen_staging    => 'http://nextgen.staging.concord.org',
  :nextgen_production => 'http://nextgen.concord.org'
}
