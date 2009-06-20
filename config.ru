require 'gaf'
require 'sinatra'

# http://localhost:4567/forums
get '/forums' do
  forums = Gaf::Forum.all
  forums.to_json
end

# http://localhost:4567/forums/2/threads
get '/forums/:forum_id/threads' do
  threads = Gaf::Thread.all("http://www.neogaf.com/forum/forumdisplay.php?f=#{params[:forum_id]}")
  threads.to_json
end

# http://localhost:4567/forums/:forum_id/threads/365226/posts
get '/forums/:forum_id/threads/:thread_id/posts' do
  posts = Gaf::Post.all("http://www.neogaf.com/forum/showthread.php?t=#{params[:thread_id]}")
  posts.to_json
end

run Sinatra::Application