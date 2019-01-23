require_relative '../config/environment'
require 'active_record'
require 'tty-prompt'
require 'tty-table'
require 'pry'

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
    puts "Here is #{input}"
    puts curr_user.get_movie(input)
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
        {"Add movie to most list" => -> do add_new_movie(curr_user) end},
        {"View movie info" => -> do view_movie_info(check_user) end},
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