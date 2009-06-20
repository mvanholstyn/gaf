require 'rubygems'
require 'activesupport'
require 'open-uri'
require 'hpricot'

module Gaf
  class Base
    BASE_URL = "http://www.neogaf.com/forum/"

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send "#{attribute}=", value
      end
    end

  private
    def self.get(url)
      Hpricot(open(url).read)
    end
  end

  class Forum < Base
    LIST_URL = BASE_URL
    LIST_QUERY = "#collapseobj_forumbit_1 tr"
    URL_QUERY = "td.alt1Active div a[@href^=forumdisplay]"
    TITLE_QUERY = "#{URL_QUERY} strong"
    THREADS_COUNT_QUERY = "td:nth-of-type(3)"
    POSTS_COUNT_QUERY = "td:nth-of-type(4)"

    attr_accessor :url, :title, :threads_count, :posts_count

    def threads
      @threads ||= Thread.all(url)
    end

    def self.all(url = LIST_URL)
      forums = get(url).search(LIST_QUERY)
      forums.map do |forum|
        Forum.new(
          :url => BASE_URL + forum.at(URL_QUERY)['href'],
          :title => forum.at(TITLE_QUERY).inner_html,
          :threads_count => forum.at(THREADS_COUNT_QUERY).inner_html.gsub(/[^0-9]/, ''),
          :posts_count => forum.at(POSTS_COUNT_QUERY).inner_html.gsub(/[^0-9]/, '')
        )
      end
    end
  end

  class Thread < Base
    LIST_QUERY = "#threadslist tr"
    URL_QUERY = "td[@id^=td_title] div a[@href^=showthread]"
    TITLE_QUERY = URL_QUERY
    FIRST_POSTER_QUERY = "td:nth-of-type(2) a[@href^=member]"
    LAST_POSTER_QUERY = "td:nth-of-type(3) a[@href^=member]"

    attr_accessor :url, :title, :first_poster, :last_poster

    def posts
      @posts ||= Post.all(url)
    end

    def self.all(url)
      threads = get(url).search(LIST_QUERY)
      threads.map do |thread|
        next unless thread.at(URL_QUERY)

        Thread.new(
          :url => BASE_URL + thread.at(URL_QUERY)['href'],
          :title => thread.at(TITLE_QUERY).inner_html,
          :first_poster => thread.at(FIRST_POSTER_QUERY).inner_html,
          :last_poster => thread.at(LAST_POSTER_QUERY).inner_html
        )
      end.compact
    end
  end

  class Post < Base
    LIST_QUERY = "#posts > div"
    POSTER_QUERY = [".bigusername span", ".bigusername"]
    TAG_QUERY = ["td:nth-of-type(0) .smallfont:nth-of-type(0) a", ".smallfont:nth-of-type(0)"]
    AVATAR_QUERY = ".smallfont a img"
    DATE_QUERY = ".smallfont:nth-of-type(1)"
    CONTENT_QUERY = "[@id^=post_message]"

    attr_accessor :poster, :tags, :avatar, :date, :content

    def self.all(url)
      posts = get(url).search(LIST_QUERY)
      posts.map do |post|
        next unless post.at(POSTER_QUERY.last)

        Post.new(
          :poster => (post.at(POSTER_QUERY.first) || post.at(POSTER_QUERY.last)).inner_html,
          :tag => (post.at(TAG_QUERY.first) || post.at(TAG_QUERY.last)).inner_html,
          :avatar => post.at(AVATAR_QUERY) ? post.at(AVATAR_QUERY)['src'] : nil,
          :date => post.at(DATE_QUERY).inner_html.gsub(/\s+/, ' ').gsub(/^\(|\)$/, ''),
          :content => post.at(CONTENT_QUERY).inner_html
        )
      end.compact
    end
  end
end

if $0 == __FILE__
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
end
