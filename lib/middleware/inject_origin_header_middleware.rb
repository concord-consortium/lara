# See: https://github.com/cyu/rack-cors/issues/24#issuecomment-92228324
# This is slightly modified version that sets origin to "*", so the response reuses it as
# Access-Control-Allow-Origin value: `Access-Control-Allow-Origin: *`
class InjectOriginHeaderMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Force rack-cors to always return Access-Control-Allow-Origin
    # by always setting the "Origin:" header in the request
    env['HTTP_ORIGIN'] ||= "*"
    @app.call(env)
  end
end
