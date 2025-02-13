class Api::V1::AuthoredContentsController < Api::ApiController
  skip_before_action :verify_authenticity_token, only: :update

  def show
    authored_content = AuthoredContent.find(params[:id])
    render_result(authored_content)
  end

  def update
    authored_content = AuthoredContent.find(params[:id])
    authorize! :update, authored_content

    begin
      s3_config = get_s3_config()

      key = get_s3_key(s3_config, authored_content)
      s3_put(s3_config, key, request.raw_post)

      authored_content.url = get_s3_url(s3_config, key)
      authored_content.save!
    rescue => e
      raise Api::ApiError, e.message
    else
      render_result(authored_content)
    end
  end

  # this is public so it can be stubbed in tests
  def get_s3_config()
    {
      access_key_id: get_env_var("AUTHORED_CONTENT_S3_ACCESS_KEY_ID"),
      secret_access_key: get_env_var("AUTHORED_CONTENT_S3_SECRET_ACCESS_KEY"),
      # not an environment variable - we use the source in the key to split production, staging, and development content
      bucket_name: "cc-project-resources",
      # production and staging can set the source, in development we don't set it and fall back to the (probably Docker) hostname
      source: ENV["AUTHORED_CONTENT_SOURCE"] || "hostname_#{Socket.gethostname()}"
    }
  end

  def s3_put(s3_config, key, contents)
    s3 = Aws::S3::Resource.new(access_key_id: s3_config[:access_key_id], secret_access_key: s3_config[:secret_access_key], region:'us-east-1')
    s3.bucket(s3_config[:bucket_name]).object(key).put(body: contents)
  end

  private

  def get_s3_key(s3_config, authored_content)
    # this key structure allows for multiple authored content items per container
    "lara-authored-content/#{s3_config[:source]}/#{authored_content.container.class.table_name}/#{authored_content.container.id}/#{authored_content.id}"
  end

  def get_s3_url(s3_config, key)
    "https://#{s3_config[:bucket_name]}.s3.amazonaws.com/#{key}"
  end

  def get_env_var(name)
    raise "Missing required #{name} environment variable" if ENV[name].blank?
    ENV[name]
  end

  def render_result(authored_content)
    render json: authored_content, only: [:id, :content_type, :url]
  end
end
