require 'pry'
require 'rest-client'
require 'dotenv/load'

def movie_title_giver(num, page)
  response_string = RestClient.get(ENV['URL'].to_s + "#{page}&with_genres=#{num}")
  response_hash = JSON.parse(response_string)
  response_hash["results"].map{ |movieObj|
     {movieObj["title"] => movieObj["overview"]}
  }
end

def movie_finder(page)
  response_string = RestClient.get("#{ENV['URL']}#{page}")
  response_hash = JSON.parse(response_string)
  response_hash["results"].map{ |movieObj|
     {movieObj["title"] => movieObj["overview"]}
  }
end
