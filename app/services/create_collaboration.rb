class CreateCollaboration
  # Output, these variables are initialized after successful call.
  attr_reader :collaboration_run, :owners_run, :owners_sequence_run

  def initialize(collaborators_data_url, user, material)
    @collaborators_data_url = collaborators_data_url
    # URI.parse(url).host returns nil when scheme is not provided.
    uri = URI(collaborators_data_url)
    fail 'Scheme is required for collaborators_data_url' if uri.scheme.nil?
    @portal_url = "#{uri.scheme}://#{uri.host}"
    @portal_url = "#{@portal_url}:#{uri.port}" if (uri.port != 80) && (uri.port != 443)
    @owner = user
    @activity = material.is_a?(LightweightActivity) ? material : nil
    @sequence = material.is_a?(Sequence) ? material : nil
    # Output.
    @collaboration_run = nil
    @owners_run = nil
    @owners_sequence_run = nil
  end

  # Setups collaboration and returns run or sequence run (depending on provided material type).
  def call
    ApplicationRecord.transaction do
      @collaboration_run = CollaborationRun.create!(
        user: @owner,
        collaborators_data_url: @collaborators_data_url
      )
      collaborators = get_collaborators_data
      process_collaborators_data(collaborators)
    end
    # Return run or sequence run that belongs to the collaboration owner.
    @owners_sequence_run || @owners_run
  end

  private

  def get_collaborators_data
    response = HTTParty.get(
      @collaborators_data_url, {
        :headers => {
          "Authorization" => Concord::AuthPortal.auth_token_for_url(@portal_url),
          "Content-Type" => 'application/json'
        }
      }
    )
    fail 'Collaboration data cannot be obtained' if response.response.code != "200"
    JSON.parse(response.body)
  end

  def process_collaborators_data(collaborators)
    collaborators.each do |c|
      unless User.exists?(email: c['email'])
        user = User.create!(
          email:    c['email'],
          password: User.get_random_password
        )
      else
        user = User.find_by_email(c['email'])
      end
      # Well, RemotePortal is a single endpoint in fact. Naming isn't consistent at all.
      portal_endpoint = RemotePortal.new(
        returnUrl: c['endpoint_url'],
        externalId: c['learner_id'],
        # Platform info
        platform_id: c['platform_id'],
        platform_user_id: c['platform_user_id'],
        resource_link_id: c['resource_link_id'],
        context_id: c['context_id'],
        class_info_url: c['class_info_url']
      )
      add_activity_run(user, portal_endpoint) if @activity
      add_sequence_runs(user, portal_endpoint) if @sequence
    end
  end

  def add_activity_run(user, portal_endpoint)
    # for_user_and_portal is in fact lookup_or_create
    run = Run.for_user_and_portal(user, @activity, portal_endpoint)
    @collaboration_run.runs.push(run)
    # Save run that belongs to the collaboration owner.
    @owners_run = run if user == @owner
  end

  def add_sequence_runs(user, portal_endpoint)
    sequence_run = SequenceRun.lookup_or_create(@sequence, user, portal_endpoint)
    @collaboration_run.runs.push(*sequence_run.runs)
    # Save sequence run that belongs to the collaboration owner.
    @owners_sequence_run = sequence_run if user == @owner
  end

end
