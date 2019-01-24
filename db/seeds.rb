require 'pry'
require 'rest-client'


def movie_title_giver(num, page)
  response_string = RestClient.get("https://api.themoviedb.org/3/discover/movie?api_key=76db750eb3336d0586fbb851da62db37&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=#{page}&with_genres=#{num}")
  response_hash = JSON.parse(response_string)
  response_hash["results"].map{ |movieObj|
     {movieObj["title"] => movieObj["overview"]}
  }
end

def movie_finder(page)
  response_string = RestClient.get("https://api.themoviedb.org/3/discover/movie?api_key=76db750eb3336d0586fbb851da62db37&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=#{page}")
  response_hash = JSON.parse(response_string)
  response_hash["results"].map{ |movieObj|
     {movieObj["title"] => movieObj["overview"]}
  }
end
