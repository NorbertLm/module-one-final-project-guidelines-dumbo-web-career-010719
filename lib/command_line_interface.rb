require_relative '../config/environment'
require 'active_record'
require 'tty-prompt'

def command_line
    prompts(welcome)
end

def welcome 
    system "clear"
    puts "Hello Welcome to My Movie List"
    puts "What is your name?"
    name = gets.chomp
    puts "Hello #{name}"
    return name
end

def prompts(name)
    curr_user = check_user(name)
    
    while true do
        if main_prompt_screen(curr_user) == false
            break
        end
    end
end

def exit_line
    puts "C ya"
    return false
end

def check_user(user_name)
    User.find_or_create_by(name: user_name)
end

# Get movie list for user
def get_movie_list(curr_user)
    puts curr_user.movie_list.inspect
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
    input = TTY::Prompt.new.ask("Enter a movie title ")
    puts "Here is #{input}"
    puts curr_user.get_movie(input)
end

# Update entry in movie list
def update_movie_list_entry(curr_user)
    input = TTY::Prompt.new.ask("Enter a movie title to update")
    
    while true do
        if update_movie_prompt(curr_user, input) == false
            break
        end
    end
end

# Delete entry in movie list
def delete_movie_from_movie_list(curr_user)
    input = TTY::Prompt.new.ask("Enter a movie title to delete ")
    curr_user.delete_movie_in_list(input)
    puts "Deleted #{input} from your list"
end


def main_prompt_screen(curr_user)
    prompt = TTY::Prompt.new
    screen = [
        {"Show all movies" => -> do get_movie_list(curr_user) end},
        {"Add movie to most list" => -> do add_new_movie(curr_user) end},
        {"View movie info" => -> do view_movie_info(check_user) end},
        {"Update movie list entry" => -> do update_movie_list_entry(curr_user) end},
        {"Delete movie from movie list" => -> do delete_movie_list_entry(check_user) end},
        {"Exit" => -> do exit_line end}
    ]
    prompt.select("", screen)
end

def update_movie_prompt(curr_user, movie_name)
    prompt = TTY::Prompt.new
    screen = [
        {"Update rating" => -> do update_movie_rating(curr_user, movie_name) end},
        {"Update progress" => -> do update_movie_progress(curr_user, movie_name) end},
        {"Update feedback" => -> do update_movie_feedback(curr_user, movie_name) end},
        {"Exit" => -> do update_exit end}
    ]
    prompt.select("", screen)
end

def update_movie_rating(curr_user, movie_name)
    prompt = TTY::Prompt.new
    rating = prompt.ask("Whats your new rating? ")
    curr_user.update_movie_in_list(movie_name, {rating: rating})
end

def update_movie_progress(curr_user, movie_name)
    prompt = TTY::Prompt.new
    progress = prompt.ask("Whats your progress? ")
    puts progress
    
    if progress == "true"
        curr_user.update_movie_in_list(movie_name, {watched: true})
    else
        curr_user.update_movie_in_list(movie_name, {watched: false})
    end
end

def update_movie_feedback(curr_user, movie_name)
    prompt = TTY::Prompt.new
    feedback = prompt.ask("Whats your feedback? ")
    curr_user.update_movie_in_list(movie_name, {feedback: feedback})
end

def update_exit
    return false
end
