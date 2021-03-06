require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @request.env['simpler.params'] = @request.params.merge!(id: record)
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_headers( { 'Content-Type' => 'text/html' } )
      send(action)
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_headers(headers)
      headers.each { |key, value| @response[key] = value }
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def record
      @request.path_info.gsub(/[^\d]/, '')
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

  end
end
