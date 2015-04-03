app = Rack::Builder.new do
  use Rack::Lint

  require 'json'

  require File.join __dir__, 'lib/hn_title_generator.rb'

  markov_model = HNTitleGenerator::MarkovModel.new
  bayes_model = HNTitleGenerator::NaiveBayes.new

  sentences_from_env = lambda { |env|
    req = Rack::Request.new(env)
    params = req.params
    sentence = params['sentence'].to_s
    limit = params['limit'] ? params['limit'].to_i : 10
    min_length = params['min_length'] ? params['min_length'].to_i : 10
    max_length = params['max_length'] ? params['max_length'].to_i : 30

    srand params['seed'].to_i
    (0..limit).map do
      markov_model.complete_sentence(sentence, min_length: min_length, max_length: max_length)
    end
  }

  map "/" do
    run lambda { |env|
      sentences = sentences_from_env.call(env)

      [200,
        {'Content-Type' => 'application/json; charset=utf-8'},
        [sentences.to_json]
      ]
    }
  end

  map "/predictions" do
    run lambda { |env|
      sentences = sentences_from_env.call(env)

      sentence_probabilities = []
      sentences.each do |sentence|
        sentence_probabilities << [
          sentence, bayes_model.probability_of_success_given(sentence)
        ]
      end

      [200,
        {'Content-Type' => 'application/json; charset=utf-8'},
        [sentence_probabilities.to_json]
      ]
    }
  end
end

run app