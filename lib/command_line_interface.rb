require_relative '../config/environment'
require_relative 'genres.rb'
require_relative '../db/seeds.rb'
require 'active_record'
require 'tty-prompt'
require 'tty-table'
require 'pry'
require 'rest-client'

ActiveRecord::Base.logger = nil
ActiveSupport::Deprecation.silenced = true

def command_line
    prompts(welcome)
end

 # Welcome message and beggining of program
def welcome
    system "clear"
    puts "Hello Welcome to My Movie List"
    puts "What is your name?"
    name = gets.chomp
    puts "Hello #{name}"
    return name
end

 # Start of prompt menus for user
def prompts(name)
    curr_user = check_user(name)

    while true do
        if main_prompt_options(curr_user) == false
            break
        end
    end
end

# Exit program
def exit_line
    puts "We exit"
    return false
end

 # Check for user based on name given, else create new user
def check_user(user_name)
    User.find_or_create_by(name: user_name)
end

# Get movie list for user
def get_movie_list(curr_user)
    curr_user =  check_user(curr_user.name)
    movie_list = curr_user.movie_list
    #binding.pry
    puts display_table(parse_movie_list(movie_list))
end

# Add movie to movie list for user
# Create new movie and add it to movie list
def add_new_movie(curr_user)
    input = TTY::Prompt.new.ask("Enter a movie title ")
    puts curr_user.new_movie(input)
    puts "Added #{input} to your list"
end

# View specific movie info
def view_movie_info(curr_user)
    input = select_movie(curr_user)
    movie = Movie.find_by(name: input)
    puts "Here is '#{input}'s overview: "
    puts movie.info
end

# Update entry in movie list
def update_movie_list_entry(curr_user)
    input = select_movie(curr_user)

    while true do
        if update_movie_prompt(curr_user, input) == false
            break
        end
    end
end

# Delete entry in movie list
def delete_movie_list_entry(curr_user)
    input = select_movie(curr_user)
    curr_user.delete_movie_in_list(input)
    puts "Deleted #{input} from your list"
end

 # Display a prompt for our main menu
def main_prompt_options(curr_user)
    prompt = TTY::Prompt.new
    options = [
        {"Show all movies" => -> do get_movie_list(curr_user) end},
        # What Mo is working on ###################################
        {"Find Movies" => -> do find_movie_api(curr_user) end},
        ###########################################################
        {"Add movie to most list" => -> do add_new_movie(curr_user) end},
        {"View movie info" => -> do view_movie_info(curr_user) end},
        {"Update movie list entry" => -> do update_movie_list_entry(curr_user) end},
        {"Delete movie from movie list" => -> do delete_movie_list_entry(curr_user) end},
        {"Exit" => -> do exit_line end}
    ]
    prompt.select("", options)
end

 # ---------------------- Update operations ---------------------- #
def update_movie_prompt(user, movie_name)
    prompt = TTY::Prompt.new
    curr_user = user
    options = [
        {"Update rating" => -> do update_movie_rating(curr_user, movie_name) end},
        {"Update progress" => -> do update_movie_progress(curr_user, movie_name) end},
        {"Update feedback" => -> do update_movie_feedback(curr_user, movie_name) end},
        {"Exit" => -> do update_exit end}
    ]
    curr_user =  check_user(curr_user.name)
    prompt.select("", options)
end

def update_movie_rating(curr_user, movie_name)
    prompt = TTY::Prompt.new
    rating = prompt.ask("Whats your new rating? ")
    curr_user.update_movie_in_list(movie_name, {rating: rating})
    get_movie_list(curr_user)
end

def update_movie_progress(curr_user, movie_name)
    prompt = TTY::Prompt.new
    progress = prompt.ask("Whats your progress? ")

    if progress == "true"
        curr_user.update_movie_in_list(movie_name, {watched: true})
    else
        curr_user.update_movie_in_list(movie_name, {watched: false})
    end
    get_movie_list(curr_user)
end

def update_movie_feedback(curr_user, movie_name)
    prompt = TTY::Prompt.new
    feedback = prompt.ask("Whats your feedback? ")
    curr_user.update_movie_in_list(movie_name, {feedback: feedback})
    get_movie_list(curr_user)
end

def update_exit
    return false
end
# ---------------------- End of update operations  ---------------------- #

 # Parse movie list and return an array of structured arrays for tty-table
def parse_movie_list(movie_list)
    #binding.pry
    movie_id = movie_list.map { |item| item.movie_id}
    movies = movie_id.map { |id| Movie.find(id)}
    movie_names = movies.map { |movie| movie.name}
    output = []

    for i in 0...movie_names.size
        output << ["    #{movie_names[i]}   ", "  #{movie_list[i].rating}  ", movie_list[i].feedback, movie_list[i].watched]
    end

    output
end

 # Use tty-table to render a table for our movie_list data
def display_table(data)
    table = TTY::Table.new(['Title', 'Rating', 'Feedback', 'Watched'], data)
    multi_renderer = TTY::Table::Renderer::ASCII.new(table, multiline: true)
    multi_renderer.render
end

def movie_list_names(movie_list)
    movie_id = movie_list.map { |item| item.movie_id}
    movies = movie_id.map { |id| Movie.find(id)}
    movie_names = movies.map { |movie| movie.name}
end

def movie_list_prompt(data)
    prompt = TTY::Prompt.new
    prompt.select("Select a movie", data)
end

def select_movie(curr_user)
    movie_list_prompt(movie_list_names(curr_user.movie_list))
end

#----------------------- API Methods---------------------------#
#                                                              #
#                                                              #
# ________DEPENDENT ON SEEDS.RB WHICH IS IN GIT-IGNORE_________#
#                                                              #
#                                                              #
#----------------------- API Methods---------------------------#
def find_movie_api(user)
  prompt = TTY::Prompt.new
  #prompt.ask "Do you want to find by genre or popularity?"
  options = [
      {"Genre" => -> do find_genre(user) end},
      {"Popularity" => -> do find_popularity(user) end}
  ]
  prompt.select("Do you want to find by genre or popularity?", options)
end

def find_genre(user)
  prompt = TTY::Prompt.new
  options = [
    {"Action" => -> do api_genre_selecter("Action", user) end},
    {"Adventure" => -> do api_genre_selecter("Adventure", user) end},
    {"Animation" => -> do api_genre_selecter("Animation", user) end},
    {"Comedy"=> -> do api_genre_selecter("Comedy", user) end},
    {"Crime" => -> do api_genre_selecter("Crime", user) end},
    {"Documentary" => -> do api_genre_selecter("Documentary", user) end},
    {"Drama" => -> do api_genre_selecter("Drama", user) end},
    {"Family" => -> do api_genre_selecter("Family", user) end},
    {"Fantasy" => -> do api_genre_selecter("Fantasy", user) end},
    {"History" => -> do api_genre_selecter("History", user) end},
    {"Horror" => -> do api_genre_selecter("Horror", user) end},
    {"Music" => -> do api_genre_selecter("Music", user) end},
    {"Mystery" => -> do api_genre_selecter("Mystery", user) end},
    {"Romance" => -> do api_genre_selecter("Romance", user) end},
    {"Science Fiction" => -> do api_genre_selecter("Fiction", user) end},
    {"TV Movie" => -> do api_genre_selecter("TV Movie", user) end},
    {"Thriller" => -> do api_genre_selecter("Thriller", user) end},
    {"War" => -> do api_genre_selecter("War", user) end},
    {"Western" => -> do api_genre_selecter("Western", user) end}
  ]
  prompt.select("Pick a genre?", options)
end

def api_genre_selecter(gen, user)
  # I deleted the database and redid the movies migration to include the info table.
  # to run this on your computer, you will need to delete your database and schema and redo the migration
  # I added a parameter in your User.new_movie method to include info
  prompt = TTY::Prompt.new
  puts Genre.genre[gen]
  page = 1
  while true
    genre_movies = movie_title_giver(Genre.genre[gen], page) # An array with key value pair elements [{Title: Overview}, {Title: Overview}]
    genre_movies_title = genre_movies.map{ |elem| elem.map { |k, v| k } }.flatten # An flatten Array with just titles
    genre_movies_title.push("NEXT PAGE")
    if page > 1
      genre_movies_title.push("BACK")
    end
    genre_movies_title.push("EXIT")
    input = prompt.select("Choose a movie", genre_movies_title)
    if input == "NEXT PAGE"
      page += 1
    elsif input == "EXIT"
      break
    elsif input == "BACK"
      page -= 1
    else
      movie_info = genre_movies.find{ |elem| input == elem.keys[0]} # returns a hash {title: Overview}
      user.new_movie(input, movie_info[input])
    end
  end
end

def find_popularity(user)
  prompt = TTY::Prompt.new
  page = 1
  while true
    movies = movie_finder(page) # An array with key value pair elements [{Title: Overview}, {Title: Overview}]
    movies_title = movies.map{ |elem| elem.map { |k, v| k } }.flatten # An flatten Array with just titles
    movies_title.push("NEXT PAGE")
    if page > 1
      movies_title.push("BACK")
    end
    movies_title.push("EXIT")
    input = prompt.select("Choose a movie", movies_title)
    if input == "NEXT PAGE"
      page += 1
    elsif input == "EXIT"
      break
    elsif input == "BACK"
      page -= 1
    else
      movie_info = movies.find{ |elem| input == elem.keys[0]} # returns a hash {title: Overview}
      user.new_movie(input, movie_info[input])
    end
  end
end
