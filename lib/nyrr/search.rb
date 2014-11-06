require "httparty"

module NYRR
  ResponseError = Class.new(StandardError)
  Results = Struct.new(:racers, :last_result)

  Search = Struct.new(:race, :max, :start) do
    include HTTParty

    base_uri 'api.rtrt.me'
    format :json

    def racers
      results.racers
    end

    def next
      search = self.class.new(race, max, last_result + 1)
      search.racers
      search
    rescue ResponseError
      return nil
    end

    def last_result
      results.last_result.to_i
    end

    private

    def results(force = false)
      @results ||= begin
        response = make_request
        if response['list']
          Results.new(
            response['list'].collect do |row|
              racer = Racer.new
              racer.members.collect{|c| racer[c.to_s] = row[c.to_s] }
              racer
            end,
            response['info']['last'].to_i
          )
        elsif response['error']
          raise ResponseError, response['error']['msg']
        end
      end
    end

    def make_request
      self.class.get("/events/#{race.name}/profiles",
        query: {
          appid: NYRR.configuration.appid,
          token: NYRR.configuration.token,
          start: start || 1,
          max: max || 10
        }
      )
    end
  end
end
