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
	prompts(get_user)
end

 # Welcome message and beggining of program
def welcome
	clear_text
	puts "Hello Welcome to My Movie List"
	puts "What is your name?"
		
end

#Get user name
def get_user
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
		
	if movie_list.size == 0
			clear_text
			puts "It's empty!"
	else
			clear_text
			puts display_table(parse_movie_list(movie_list))
	end
end

# Add movie to movie list for user
# Create new movie and add it to movie list
def add_new_movie(curr_user)
	clear_text
	input = TTY::Prompt.new.ask("Enter a movie title ")
	curr_user.new_movie(input)
	puts "Added #{input} to your list"
end

# View specific movie info
def view_movie_info(curr_user)
	clear_text
	input = select_movie(curr_user)
	
	if input != 0
		movie = Movie.find_by(name: input)
		puts "Here is '#{input}'s overview: "
		puts movie.info
	else
		nothing_to_show
	end
end

# Update entry in movie list
def update_movie_list_entry(curr_user)
	input = select_movie(curr_user)
	
	if input != 0
		while true do
				if update_movie_prompt(curr_user, input) == false
						break
				end
		end
	else
		nothing_to_show
	end
end

# Delete entry in movie list
def delete_movie_list_entry(curr_user)
	clear_text
	input = select_movie(curr_user)
	
	if input != 0
		curr_user.delete_movie_in_list(input)
		puts "Deleted #{input} from your list"
	else 
		nothing_to_show
	end
end

 # Display a prompt for our main menu
def main_prompt_options(curr_user)
	prompt = TTY::Prompt.new
	options = [
			{"Show all movies" => -> do get_movie_list(curr_user) end},
			{"Find Movies" => -> do find_movie_api(curr_user) end},
			{"Add movie to movie list" => -> do add_new_movie(curr_user) end},
			{"View movie info" => -> do view_movie_info(curr_user) end},
			{"Update movie list entry" => -> do update_movie_list_entry(curr_user) end},
			{"Delete movie from movie list" => -> do delete_movie_list_entry(curr_user) end},
			{"Exit" => -> do exit_line end}
	]
	prompt.select("", options, per_page: 10)
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

 # Get all movie names from movie list entries
def get_movie_names(movie_list)
  movie_id = movie_list.map { |item| item.movie_id}
	movies = movie_id.map { |id| Movie.find(id)}
  movie_names = movies.map { |movie| movie.name}
end

# ---------------------- End of update operations  ---------------------- #

 # Parse movie list and return an array of structured arrays for tty-table
def parse_movie_list(movie_list)
	movie_names = get_movie_names(movie_list)
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

 # Returns a list of movie names from movie_list 
def movie_list_names(movie_list)
	movie_id = movie_list.map { |item| item.movie_id}
	movies = movie_id.map { |id| Movie.find(id)}
	movie_names = movies.map { |movie| movie.name}
end

 # Create prompt for movie list
def movie_list_prompt(data)
	prompt = TTY::Prompt.new
	prompt.select("Select a movie", data, per_page: 10)
end

 # Select and return movie
def select_movie(curr_user)
	if curr_user.movie_list.size == 0
		return 0
	else
		movie_list_prompt(movie_list_names(curr_user.movie_list))
	end
end

def clear_text
	system "clear"
end

def nothing_to_show
  puts "Nothing in your movie list."
end

#----------------------- API Methods---------------------------#
#                                                              #
#                                                              #
# ________DEPENDENT ON SEEDS.RB WHICH IS IN GIT-IGNORE_________#
#                                                              #
#                                                              #
#----------------------- API Methods---------------------------#
def find_movie_api(user)
  clear_text
	prompt = TTY::Prompt.new
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
	prompt.select("Pick a genre?", options, per_page: 10)
end

def api_genre_selecter(gen, user)
	prompt = TTY::Prompt.new
	page = 1
	while true
		genre_movies = movie_title_giver(Genre.genre[gen], page) # An array with key value pair elements [{Title: Overview}, {Title: Overview}]
		genre_movies_title = genre_movies.map{ |elem| elem.map { |k, v| k } }.flatten # An flatten Array with just titles
		genre_movies_title.push("NEXT PAGE")
		if page > 1
			genre_movies_title.push("BACK")
		end
		genre_movies_title.push("EXIT")
		input = prompt.select("Choose a movie", genre_movies_title, per_page: 10)
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
		input = prompt.select("Choose a movie", movies_title, per_page: 10)
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
