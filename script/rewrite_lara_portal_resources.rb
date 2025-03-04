PORTAL_COLUMNS_TO_SEARCH_ALL = {
  'ExternalActivity' => %w[url author_url print_url teacher_guide_url],
  'Admin::AuthoringSite' => ['url'],
  'Client' => ['site_url'],
  'LearnerProcessingEvent' =>  ['url']
}.freeze

PORTAL_COLUMNS_TO_SEARCH_NO_LEARNERS = {
  'ExternalActivity' => %w[url author_url print_url teacher_guide_url],
  'Admin::AuthoringSite' => ['url'],
  'Client' => ['site_url']
}.freeze

PORTAL_COLUMNS_TO_SEARCH_INTERNAL_REFS = {
  'ExternalActivity' => %w[teacher_resources_url]
}.freeze

LARA_COLUMNS_TO_SEARCH = {
  'CollaborationRun' => ['collaborators_data_url'],
  'InteractiveRunState' => ['learner_url'],
  'PortalPublication' => ['portal_url'],
  'Run' => %w[remote_endpoint class_info_url],
  'SequenceRun' =>  %w[remote_endpoint class_info_url]
}.freeze

def execute(sql)
  puts sql
  ApplicationRecord.connection.execute(sql)
end

# Only use this when setting up a QA environment.
def delete_unused_portal_publications(good_portal)
  sql = "DELETE FROM portal_publications WHERE portal_url NOT LIKE '%#{good_portal}%'"
  execute(sql)
end

def replace_server_in_table_column(clazz, column, old_name, new_name)
  table = clazz.table_name
  sql = "UPDATE #{table} SET #{column} = REPLACE(#{column}, '#{old_name}','#{new_name}')"
  execute(sql)
end

def print_values_in_table(clazz, column)
  puts clazz.pluck(column)
end

def update_server_name(column_hash, old_name, new_name)
  column_hash.each_key do |clazz_name|
    columns = column_hash[clazz_name]
    clazz = clazz_name.classify.constantize
    columns.each do |column|
      replace_server_in_table_column(clazz, column, old_name, new_name)
    end
  end
end

# In the Portal: Update references to LARA
# Must be run in the Portal
def update_portal_lara_refs(old_url='authoring.concord.org', new_url='my-lara.concordqa.org', skip_learner_data=false)
  portal_columns = skip_learner_data ? PORTAL_COLUMNS_TO_SEARCH_NO_LEARNERS : PORTAL_COLUMNS_TO_SEARCH_ALL
  update_server_name(portal_columns, old_url, new_url)
end

# In the Portal: Update references to Portal
# Must be run in the Portal
def update_portal_portal_refs(old_url='learn.concord.org', new_url='my-portal.concordqa.org')
  update_server_name(PORTAL_COLUMNS_TO_SEARCH_INTERNAL_REFS, old_url, new_url)
end

# In LARA: Update references to Portal
# Must be run in LARA
def update_lara_portal_refs(old_url='learn.concord.org', new_url="my-portal.concordqa.org")
  update_server_name(LARA_COLUMNS_TO_SEARCH, old_url, new_url)
  # Danger: remove all publications that aren't to the new portal.
  # delete_unused_portal_publications(new_url)
end

# To use: Copy and paste the above code into a rails console (Portal or lara)
# Then do something like:
# update_lara_portal_refs('learn.concord.org','my-portal-test.concordqa.org')
