def require_env_var(name)
  has_var = !ENV[name].nil?
  if !has_var
    puts "The #{name} environment variable is missing, aborting!"
  end
  has_var
end

def safe_parse(url)
  # encode first to avoid URI::InvalidURIError on bad urls
  begin
    URI.parse(URI.encode(URI.decode(url)))
  rescue
    nil
  end
end

namespace :docstore_v2 do
  desc "Migrate the interactive run states that use the v1 docstore api to v2."
  task migrate_run_states: :environment do

    # make sure we have the required environment variables
    abort unless require_env_var('DOCSTORE_URL')
    abort unless require_env_var('DOCSTORE_API_SECRET')

    # get the docstore params
    InteractiveRunState.includes(:interactive).where(interactive_type: 'MwInteractive').where("raw_data like '%\"lara_options\":%'").find_in_batches(batch_size: 100) do |batch|
      docs = []
      server_urls = {}
      interactive_urls = {}
      stats = {
        total_states: 0,
        v1_states: 0,
        has_reporting_url: 0,
        has_interactive: 0,
        uses_prod_docstore: 0,
        has_v2_interactive_url: 0,
        has_recordid_and_server: 0,
        uses_codap_concord_org: 0,
        found_document: 0,
        updated: 0}

      batch.each do |irs|
        stats[:total_states] = stats[:total_states] + 1

        # skip v2 run states
        next if irs[:raw_data]["docStore"]
        stats[:v1_states] = stats[:v1_states] + 1

        # skip runstates without existing reporting urls
        lara_options = JSON.parse(irs[:raw_data])["lara_options"]
        next if lara_options.nil? || lara_options["reporting_url"].nil?
        stats[:has_reporting_url] = stats[:has_reporting_url] + 1

        # skip runstates without an interactive (this should not happen, but just in case)
        next if !irs.interactive
        stats[:has_interactive] = stats[:has_interactive] + 1

        # skip interactives not hosted on production doc store
        interactive_url = safe_parse(irs.interactive.url) # encode first to avoid URI::InvalidURIError on bad urls
        next if interactive_url.nil? || !(['document-store.herokuapp.com', 'document-store.concord.org'].include? interactive_url.host)
        stats[:uses_prod_docstore] = stats[:uses_prod_docstore] + 1

        # make sure the interactive has the needed parameters
        interactive_params = CGI.parse(interactive_url.query || "")
        interactive_params.each {|key,value| interactive_params[key] = value[0]}  # CGI.parse returns ?foo=bar as {"foo":["bar"]}

        if interactive_url.path.include? '/v2/documents/' then
          # this is a v2 style interactive, this can happen if the interactives have been partially converted
          v1_interactive_url = false
          stats[:has_v2_interactive_url] = stats[:has_v2_interactive_url] + 1
          # make sure it has a server param
          next if !interactive_params.has_key?("server")
        else
          # this is a v1 style interactive
          v1_interactive_url = true
          next if !interactive_params.has_key?("recordid") || !interactive_params.has_key?("server")
          stats[:has_recordid_and_server] = stats[:has_recordid_and_server] + 1
        end

        # make sure only production codap server interactives are changed
        server_urls[irs.id] = interactive_params["server"]
        server_url = safe_parse(interactive_params["server"])
        next if server_url.nil? || server_url.host != 'codap.concord.org'
        stats[:uses_codap_concord_org] = stats[:uses_codap_concord_org] + 1

        puts interactive_params
        # generate the v2 launch url and save the interactive id to update
        if v1_interactive_url then
          new_interactive_url = URI("#{interactive_url.scheme}://#{interactive_url.host}:#{interactive_url.port}/v2/documents/#{interactive_params['recordid']}/launch")
          interactive_params.delete("recordid")
          new_interactive_url.query = interactive_params.to_query
          interactive_urls[irs.interactive_id] = new_interactive_url.to_s
        end

        # parse and select the parameters to query on the docstore
        params = CGI.parse(safe_parse(lara_options["reporting_url"]).query || "")
        params.each {|key,value| params[key] = value[0]}  # CGI.parse returns ?foo=bar as {"foo":["bar"]}
        params["irs_id"] = irs.id
        docs.push params.symbolize_keys.slice(:irs_id, :doc, :recordname, :owner, :runKey, :reportUser)
      end

      # generate the access keys on the docstore
      result = HTTParty.post("#{ENV['DOCSTORE_URL']}/v2/documents/create_keys",
        body: { docs: docs,
                  api_secret: ENV['DOCSTORE_API_SECRET']}.to_json,
        headers: { 'Content-Type' => 'application/json' } )

      # update the raw_data and the MwInteractive
      if result && result["valid"]
        result["docs"].each do |doc|
          irs_id = doc["irs_id"]
          document = doc["document"]
          stats[:found_document] = stats[:found_document] + 1 if document
          if document && server_urls[irs_id]
            reporting_url = safe_parse(server_urls[irs_id])
            reporting_params = CGI.parse(reporting_url.query || "")
            reporting_params["launchFromLara"] = Base64.strict_encode64({recordid: document["id"], accessKeys: {readOnly: document["readAccessKey"]}}.to_json)
            reporting_url.query = reporting_params.to_query

            irs = InteractiveRunState.find(irs_id)
            irs.raw_data = {docStore: {recordid: document["id"], accessKeys: {readOnly: document["readAccessKey"], readWrite: document["readWriteAccessKey"]}}, lara_options: {reporting_url: reporting_url.to_s}}.to_json
            irs.learner_url = nil
            irs.save


            stats[:updated] = stats[:updated] + 1
          end
        end

        interactive_urls.each do |key, value|
          interactive = MwInteractive.find(key)
          interactive.update_attribute(:url, value)
        end
      end
      puts "--- Batch Stats ---"
      puts stats.to_json
    end
  end
end
