require File.expand_path('../../config/environment', __FILE__)
require "uri"
require "rack"
require "json"

def document_store_to_cfm(url_string, use_cfm_master)
  url = URI(url_string)
  new_query = Rack::Utils.parse_nested_query(url.query)

  if use_cfm_master
    # Parse server query param and set it to use CFM master
    server_url = URI(new_query["server"])
    server_query_params =  Rack::Utils.parse_nested_query(server_url.query)
    if server_url.host.include?("sage")
      # SageModeler requires branch name and 3 separate URL params
      server_query_params["cfmBaseUrl"] = "master"
      server_query_params["sage:cfmBaseUrl"] = "master"
      server_query_params["codap:cfmBaseUrl"] = "master"
    elsif server_url.host.include?("codap")
      # CODAP requires full URL
      server_query_params["cfmBaseUrl"] = "https://cloud-file-manager.concord.org/branch/master/js"
    end

    # It looks strange, but the idea is to convert hash to query params string WITHOUT encoding. If we provide encoded
    # string here, it'll be encoded again a few lines below when the whole URL gets encoded.
    server_url.query = URI.decode_www_form_component(URI.encode_www_form(server_query_params))
    server_url.scheme = "https"

    new_query["server"] = server_url.to_s
  end

  # Parse document ID
  document_id_match_result = /documents\/(\d+)/.match(url.path)
  document_id = document_id_match_result && document_id_match_result[1]
  if document_id == nil
    raise "Document ID not found in the url #{url_string}!"
  end
  # Redirect URL. It should redirect https://models-resources.concord.org/legacy-document-store/123
  # to a new location: https://models-resources.concord.org/cfm-shared/<unique_id>/file.json
  new_query["documentId"] = "https://models-resources.concord.org/legacy-document-store/" + document_id

  url.query = URI.encode_www_form(new_query)
  url.scheme = "https"  # just in case
  url.host = "cloud-file-manager.concord.org"
  if use_cfm_master
    url.path = "/branch/master/autolaunch/autolaunch.html"
  else
    url.path = "/autolaunch/autolaunch.html"
  end

  url.to_s
end

def master_cfm_to_production_cfm(url_string)
  url = URI(url_string)
  new_query = Rack::Utils.parse_nested_query(url.query)

  # Parse server query param and remove CFM master branch query params
  server_url = URI(new_query["server"])
  server_query_params =  Rack::Utils.parse_nested_query(server_url.query)
  # SageModeler requires branch name and 3 separate URL params
  # CODAP requires just cfmBaseUrl
  # We can run the same code for both kinds of URL
  server_query_params.delete("cfmBaseUrl")
  server_query_params.delete("sage:cfmBaseUrl")
  server_query_params.delete("codap:cfmBaseUrl")

  # It looks strange, but the idea is to convert hash to query params string WITHOUT encoding. If we provide encoded
  # string here, it'll be encoded again a few lines below when the whole URL gets encoded.
  server_url.query = URI.decode_www_form_component(URI.encode_www_form(server_query_params))
  if server_url.query.length === 0
    # If query is an empty string, URI encoder will still add "?" at the end of the URL.
    server_url.query = nil
  end
  new_query["server"] = server_url.to_s

  url.query = URI.encode_www_form(new_query)
  url.path = "/autolaunch/autolaunch.html" # remove /branch/master
  url.to_s
end

# Little test embedded
def test
  codap_test_url = "https://document-store.concord.org/v2/documents/159578/autolaunch?server=https%3A%2F%2Fcodap.concord.org%2Freleases%2Flatest%2F&scaling"
  sage_test_url = "https://document-store.concord.org/v2/documents/159582/autolaunch?server=https%3A%2F%2Fsagemodeler.concord.org%2Fapp%2F&scaling"

  codap_master_cfm_url = "https://cloud-file-manager.concord.org/branch/master/autolaunch/autolaunch.html?server=https%3A%2F%2Fcodap.concord.org%2Freleases%2Flatest%2F%3FcfmBaseUrl%3Dhttps%3A%2F%2Fcloud-file-manager.concord.org%2Fbranch%2Fmaster%2Fjs&scaling&documentId=https%3A%2F%2Fmodels-resources.concord.org%2Flegacy-document-store%2F159578"
  sage_master_cfm_url = "https://cloud-file-manager.concord.org/branch/master/autolaunch/autolaunch.html?server=https%3A%2F%2Fsagemodeler.concord.org%2Fapp%2F%3FcfmBaseUrl%3Dmaster%26sage%3AcfmBaseUrl%3Dmaster%26codap%3AcfmBaseUrl%3Dmaster&scaling&documentId=https%3A%2F%2Fmodels-resources.concord.org%2Flegacy-document-store%2F159582"

  codap_production_cfm_url = "https://cloud-file-manager.concord.org/autolaunch/autolaunch.html?server=https%3A%2F%2Fcodap.concord.org%2Freleases%2Flatest%2F&scaling&documentId=https%3A%2F%2Fmodels-resources.concord.org%2Flegacy-document-store%2F159578"
  sage_production_cfm_url = "https://cloud-file-manager.concord.org/autolaunch/autolaunch.html?server=https%3A%2F%2Fsagemodeler.concord.org%2Fapp%2F&scaling&documentId=https%3A%2F%2Fmodels-resources.concord.org%2Flegacy-document-store%2F159582"

  if document_store_to_cfm(codap_test_url, true) != codap_master_cfm_url
    raise "CODAP DocStore -> CFM master transformation incorrect"
  end
  if document_store_to_cfm(sage_test_url, true) != sage_master_cfm_url
    raise "SageModeler DocStore -> CFM master URL transformation incorrect"
  end

  if document_store_to_cfm(codap_test_url, false) != codap_production_cfm_url
    raise "CODAP DocStore -> CFM production transformation incorrect"
  end
  if document_store_to_cfm(sage_test_url, false) != sage_production_cfm_url
    raise "SageModeler DocStore -> CFM production URL transformation incorrect"
  end

  if master_cfm_to_production_cfm(document_store_to_cfm(codap_test_url, true)) != codap_production_cfm_url
    raise "CODAP CFM master -> CFM production transformation incorrect"
  end
  if master_cfm_to_production_cfm(document_store_to_cfm(sage_test_url, true)) != sage_production_cfm_url
    raise "SageModeler CFM master -> CFM production URL transformation incorrect"
  end
end

def migrate_docstore_to_cfm_master
  interactives = MwInteractive.where("url like '%document-store.concord.org%autolaunch%'")
  puts "Found #{interactives.count} interactives that point to document-store.concord.org"

  result = []
  interactives.find_in_batches(batch_size: 20) do |group|
    group.each do |interactive|
      result.push({id: interactive.id, old_url: interactive.url, new_url: document_store_to_cfm(interactive.url, true)})
    end
  end

  File.write('docstore_to_cfm_master.json', JSON.pretty_generate(result))
end

def migrate_docstore_to_cfm_production
  interactives = MwInteractive.where("url like '%document-store.concord.org%autolaunch%'")
  puts "Found #{interactives.count} interactives that point to document-store.concord.org"

  result = []
  interactives.find_in_batches(batch_size: 20) do |group|
    group.each do |interactive|
      result.push({id: interactive.id, old_url: interactive.url, new_url: document_store_to_cfm(interactive.url, false)})
    end
  end

  File.write('docstore_to_cfm_production.json', JSON.pretty_generate(result))
end

def migrate_cfm_master_to_cfm_production
  interactives = MwInteractive.where("url like '%cloud-file-manager.concord.org/branch/master%'")
  puts "Found #{interactives.count} interactives that point to cloud-file-manager.concord.org/branch/master"

  result = []
  interactives.find_in_batches(batch_size: 20) do |group|
    group.each do |interactive|
      result.push({id: interactive.id, old_url: interactive.url, new_url: master_cfm_to_production_cfm(interactive.url)})
    end
  end

  File.write('cfm_master_to_cfm_production.json', JSON.pretty_generate(result))
end

def execute_migration(filename, revert)
  file = File.new(filename)
  data = JSON.load(file)
  puts "Processing #{data.length} interactives"
  count = 0
  data.each do |entry|
    result = MwInteractive.find(entry["id"]).update_column("url", revert ? entry["old_url"] : entry["new_url"])
    if result
      count += 1
    end
  end
  puts "#{count} successful updates"
end

def run
  action = ARGV[0]
  input_file = ARGV[1]
  revert = !!ARGV[2]

  if action === "docstore_to_cfm_master"
    migrate_docstore_to_cfm_master
  elsif action === "docstore_to_cfm_production"
    migrate_docstore_to_cfm_production
  elsif action === "cfm_master_to_cfm_production"
    migrate_cfm_master_to_cfm_production
  elsif action === "execute_migration"
    execute_migration(input_file, revert)
  else
    puts "No action specified. Provide action input_file revert arguments."
  end
end

# always run test first
test
# execute script only if tests pass
run
