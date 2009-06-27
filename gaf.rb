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

    def attributes
      instance_variables.inject({}) do |hash, instance_variable|
        hash[instance_variable[1..-1]] = instance_variable_get(instance_variable)
        hash
      end
    end

    def to_json(*args)
      "{#{self.class.json_class_name}: #{attributes.to_json(*args )}}"
    end

    def self.json_class_name
      @json_class_name ||= name.demodulize.underscore.inspect
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
    NAME_QUERY = "#{URL_QUERY} strong"
    THREAD_COUNT_QUERY = "td:nth-of-type(3)"
    POST_COUNT_QUERY = "td:nth-of-type(4)"

    attr_accessor :id, :url, :name, :thread_count, :post_count

    def threads
      @threads ||= Thread.all(url)
    end

    def self.all(url = LIST_URL)
      forums = get(url).search(LIST_QUERY)
      forums.map do |forum|
        Forum.new(
          :id => forum.at(URL_QUERY)['href'].gsub(/^.*?f=(\d+)$/, '\1'),
          :url => BASE_URL + forum.at(URL_QUERY)['href'],
          :name => forum.at(NAME_QUERY).inner_html,
          :thread_count => forum.at(THREAD_COUNT_QUERY).inner_html.gsub(/[^0-9]/, ''),
          :post_count => forum.at(POST_COUNT_QUERY).inner_html.gsub(/[^0-9]/, '')
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
