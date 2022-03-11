require "httparty"
require "json"
module Services
  class Session
    include HTTParty

    def initialize
      self.class.base_uri("https://opentdb.com/api.php?amount=")
    end

    def trivia_qa(cant)
      response = self.class.get(cant.to_s)
      handling_response(response: response)
    end

    def handling_response(response:)
      t_response = { code: response.code }
      raise HTTParty::ResponseError, response unless response.success?
    rescue HTTParty::ResponseError => e
      if e.message.empty?
        t_response.merge!({ content: { errors: ["Element can't be found"] } })
      else
        t_response.merge!({ content: JSON.parse(e.message, symbolize_names: true) })
      end
    else
      case response.code
      when 204
        t_response.merge!({ content: { message: "Operation completed" } })
      else
        t_response.merge!({ content: JSON.parse(response.body, symbolize_names: true) })
      end
    ensure
      t_response
    end
  end
end
