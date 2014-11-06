require 'spec_helper'

describe NYRR::Race do
  before do
    NYRR.configure do |c|
      c.appid = '1234'
      c.token = '4567'
    end
  end

  context 'when it is initialized' do
    it 'requires a race name' do
      expect {
        NYRR::Race.new
      }.to raise_error(NYRR::AttributeRequired, 'Missing attribute name')
    end

    it 'sets the race name' do
      race = NYRR::Race.new('NYRR')
      expect(race.name).to eq 'NYRR'
    end
  end

  context 'searching for race results' do
    let(:race) { NYRR::Race.new('NYRR-2013') }

    def api_request(list = [], total = 0)
      stub_request(:get, "http://api.rtrt.me/events/NYRR-2013/profiles?appid=1234&max=100&start=1&token=4567")
        .to_return(
          status: 200,
          body: {
            list: list,
            info: {
              first: "1",
              last: "4"
            }
          }.to_json,
          headers: {}
        )
    end

    it 'returns a search object' do
      search = race.search
      expect(search).to be_a(NYRR::Search)
    end

    it 'retuns a result of racers and assigns fields' do
      api_request([{'name' => 'Bob Smith'}])
      results = race.search.racers
      expect(results.size).to be > 0
      expect(results).to all(be_a(NYRR::Racer))
      expect(results.first.name).to eq 'Bob Smith'
    end
  end
end
