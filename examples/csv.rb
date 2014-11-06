require 'nyrr'
require 'csv'
require 'pry'

require 'dotenv'
Dotenv.load

NYRR.configure do |c|
  c.appid = ENV['NYRR_APPID']
  c.token = ENV['NYRR_TOKEN']
end

race = NYRR::Race.new('NYRR-TEAMCHAMPIONSHIPS-2014')

CSV.open('registered_runners.csv', 'w') do |csv|
  csv << NYRR::Racer.new.members

  search = race.search

  begin
    puts "Last Result: #{search.last_result}"
    search.racers.each do |racer|
      csv << racer.members.collect{|v| racer[v] }
    end
  end while search = search.next
end
