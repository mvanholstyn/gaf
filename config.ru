require 'gaf'
require 'sinatra'

# http://localhost:4567/forums
get '/forums.json' do
  forums = Gaf::Forum.all
  forums.to_json
end

# http://localhost:4567/forums/2/threads
get '/forums/:forum_id/threads.json' do
  threads = Gaf::Thread.all(params[:forum_id])
  threads.to_json
end

# http://localhost:4567/forums/:forum_id/threads/365226/posts
get '/forums/:forum_id/threads/:thread_id/posts.json' do
  posts = Gaf::Post.all("http://www.neogaf.com/forum/showthread.php?t=#{params[:thread_id]}")
  posts.to_json
end

run Sinatra::Application