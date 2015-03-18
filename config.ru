app = Rack::Builder.new do
  use Rack::Lint

  require 'json'

  require File.join __dir__, 'lib/hn_title_generator.rb'

  model = HNTitleGenerator::MarkovModel.new

  map "/" do
    run lambda { |env|
      req = Rack::Request.new(env)
      params = req.params
      sentence = params['sentence'].to_s
      limit = params['limit'] ? params['limit'].to_i : 10
      min_length = params['min_length'] ? params['min_length'].to_i : 10
      max_length = params['max_length'] ? params['max_length'].to_i : 30

      srand params['seed'].to_i
      sentences = (0..limit).map do
        model.complete_sentence(sentence, min_length: min_length, max_length: max_length)
      end

      [200,
        {'Content-Type'=>'application/json'},
        [sentences.to_json]
      ]
    }
  end
end

run app