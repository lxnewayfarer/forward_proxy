# frozen_string_literal: true

# Class implementing forwarding requests to a certain host
class ForwardProxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)

    # use rack proxy for anything hitting our host app at /proxy
    proxy_path = '/proxy'
    if request.path =~ /^#{proxy_path}/
      backend = URI(ENV['SERVICE_URL'])
      # most backends required host set properly, but rack-proxy doesn't set this for you automatically
      # even when a backend host is passed in via the options
      env['HTTP_HOST'] = backend.host

      # This is the only path that needs to be set currently on Rails 5 & greater
      env['PATH_INFO'] = request.path.sub(proxy_path, '')

      # don't send your sites cookies to target service, unless it is a trusted internal service able to parce cookies
      env['HTTP_COOKIE'] = ''
      super(env)
    else
      @app.call(env)
    end
  end

  def rewrite_response(triplet)
    _status, headers, _body = triplet

    # if you rewrite env, it appears that content-length isn't calculated correctly
    # resulting in only partial responses being sent to users
    # you can remove it or recalculate it here
    headers['content-length'] = nil

    triplet
  end
end
