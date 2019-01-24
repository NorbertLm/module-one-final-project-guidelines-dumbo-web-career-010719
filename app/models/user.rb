require 'pry'

class User < ActiveRecord::Base
  has_many :lists
  has_many :movies, through: :lists

  # Returns list from User
  def movie_list
    self.lists
  end

  # Takes in a movie name and/or info and creates new movie
  def new_movie(movie_name, info = nil)
    movie = Movie.find_or_create_by(name: movie_name, info: info)
    movie_list.find_or_create_by(user_id: self.id, movie_id: movie.id)
  end

  # Takes in movie name and gets Movie id
  def get_movie_id(movie_name)
    Movie.find_by(name: movie_name).id
  end

  # Takes in movie name and data to update movie attributes
  def update_movie_in_list(movie_name, opts)
    movie_list.where(movie_id: get_movie_id(movie_name)).update(opts)
  end

  # Detroys movie entry in list based on movie name passed in
  def delete_movie_in_list(movie_name)
    movie_list.destroy(movie_list.where(movie_id: get_movie_id(movie_name)))
  end

end
