module HNTitleGenerator
  class Item
    require 'open-uri'
    require 'timeout'    
    require 'fileutils'
    require 'json'

    include Enumerable
    include Comparable
    

    DATA_PATH = 'data'
    ITEMS_PATH = File.join DATA_PATH, 'item'
    TITLES_PATH = File.join DATA_PATH, 'titles.txt'
    API_URL = "https://hacker-news.firebaseio.com/v0"
    FileUtils.mkdir_p ITEMS_PATH


    attr_accessor :id, :json


    ############################################################################
    # Item Cache                                                               #
    ############################################################################
    def self.max_id(reload = false)
      if @max_id.nil? || reload
        @max_id = open("#{API_URL}/maxitem.json").read.to_i
      end
      @max_id
    end

    def self.sync(thread_count = 1)
      threads = []

      trap("INT") do
        threads.each { |t| t.kill }
      end

      thread_count.times do |i|
        threads << Thread.new do
          id = max_id
          while id > 0
            if id % thread_count == i
              Item.new(id).save(false) rescue nil
            end
            id -= 1
          end
        end
      end
      threads.each { |t| t.join }
    end

    def self.each
      Dir.foreach(ITEMS_PATH) do |id|
        next unless id =~ /\A\d+\z/
        yield Item.new(id)
      end
    end

    def self.each_story
      each do |item|
        yield item if item.type == 'story'
      end
    end
    
    def self.each_title(cached = true)
      if File.exist?(TITLES_PATH) && cached
        IO.foreach(TITLES_PATH) { |line| yield line }
      else
        titles = File.open(TITLES_PATH, 'w')
        each_story do |story|
          yield story.title
          titles.write(story.title.to_s + $/)
        end
        titles.close
      end
    end

    ############################################################################
    # Constructor                                                              #
    ############################################################################
    def initialize(id)
      @id = id.to_i
      @json = nil
    end

    ############################################################################
    # Persistence                                                              #
    ############################################################################
    def save(overwrite = true)
      File.write(path, json.to_json) if !File.exist?(path) || overwrite
      self
    end

    def load(download = false)
      if File.exist?(path) && !download
        @json = JSON.load(File.read(path))
      else
        Timeout.timeout(10) do
          @json = JSON.load(open(api_url).read) 
        end
      end
      @json = {} if @json.nil?
      self
    end

    ############################################################################
    # Attributes                                                               #
    ############################################################################
    def json(reload = false)
      load(reload) if @json.nil? || reload
      @json
    end

    def parent
      return nil unless json.has_key?('parent')
      Item.new(json['parent'])
    end

    def kids
      return [] unless json.has_key?('kids')
      json['kids'].map { |id| Item.new(id) }
    end

    def parts
      return [] unless json.has_key?('parts')
      json['parts'].map { |id| Item.new(id) }
    end

    %w(by score time title text type url).each do |attr|
      class_eval("def #{attr}; json['#{attr}']; end", __FILE__, __LINE__)
    end


    # Comparable
    def <=>(other)
      id <=> other.id
    end
    
    ############################################################################
    # Private                                                                  #
    ############################################################################
    private
      def api_url
        "#{API_URL}/item/#{@id.to_i}.json"
      end

      def path
        File.join(ITEMS_PATH, @id.to_s)
      end
  end
end
