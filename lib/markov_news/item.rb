module MarkovNews
  class Item
    require 'open-uri'
    require 'fileutils'
    require 'json'
    require 'yaml'

    DATA_PATH = 'data'
    ITEMS_PATH = File.join DATA_PATH, 'item'
    TITLES_PATH = File.join DATA_PATH, 'titles.yaml'
    API_URL = "https://hacker-news.firebaseio.com/v0"
    FileUtils.mkdir_p ITEMS_PATH


    attr_accessor :id, :json


    ############################################################################
    # Item Cache                                                               # 
    ############################################################################
    def self.max_id
      @max_id ||= open("#{API_URL}/maxitem.json").read.to_i
    end
      
    def self.sync(thread_count = 1, item_count = nil)
      item_count = max_id if item_count.nil?
      threads = []

      trap("INT") do
        threads.each { |t| t.kill }
      end

      thread_count.times do |i|
        threads << Thread.new do
          id = max_id
          while id > 0 && item_count > 0
            if id % thread_count == i
              Item.new(id).save
              item_count -= 1
            end
            id -= 1
          end
        end
      end
      threads.each { |t| t.join }
    end

    def self.items
      Dir[File.join(ITEMS_PATH, '/*')].map { |path| Item.new(path[/\d+\z/]) }
    end

    def self.stories
      items.select { |i| i.json && i.json['type'] == 'story' }
    end
    
    def self.titles(cache = true)
      if File.exist?(TITLES_PATH) && cache
        YAML.load(File.read(TITLES_PATH))
      else
        titles = stories.map { |story| story.title }
        File.write(TITLES_PATH, YAML::dump(titles))
        titles
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
    def save
      puts "#{Thread.current.object_id}: saving #{json.to_s}"
      File.write(path, json.to_json)
      self
    end

    def load(download = false)
      if File.exist?(path) && !download
        @json = JSON.load(File.read(path))
      else
        @json = JSON.load(open(api_url).read)
      end
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

    %w(by id score time title text type url).each do |attr|
      class_eval("def #{attr}; return json['#{attr}']; end;")
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
