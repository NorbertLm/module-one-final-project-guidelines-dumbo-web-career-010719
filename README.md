# My Movie List

## About
My Movie List is a command line cataloging application for movies.
Users are able to add or delete movies to their catalog, add a rating, write comments, view movie information and log if the movie has been watched.
Another feature allows the user to search for movies based on genres or popularity and add it to their catalog.

Data is stored with a Sqlite3 Database and accessed using ActiveRecord.
Movie information for search function is retrieved with an api from https://www.themoviedb.org/.
Api key and endpoint is accessed with the `dotenv` gem and loaded from a .env file located in the root directory. 

## Usage
`bundle install`

`rake db:migrate`

`ruby run.rb`
