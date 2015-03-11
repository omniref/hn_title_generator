module MarkovNews
  class Brain
    ##
    # Creates the ultimate buzzword brain using markov chains trained on the
    # titles found in MarkovNews::Item.titles.
    def initialize
      @markov_model = Hash.new { |hash, key| hash[key] = [] }

      MarkovNews::Item.titles.each do |title|
        tokens = tokenize(title)
        tokens.length.times do
          token = tokens.pop
          markov_state = [tokens[-2], tokens[-1]]
          @markov_model[markov_state] << token
        end
      end
    end

    # Completes a sentence using the Markov Model trained on news titles.
    #
    # @param [String] sentence to be completed, empty string is acceptable
    # @param [Integer] min_length specifies the lower bound on random sentence length. The sentence may be shorter than this if a punctuation character is encountered.
    # @param [Integer] max_length specifies the upper bound on random sentence length
    # @return [String] a complete sentence according to the markov model
    def complete_sentence(sentence: '', min_length: 15, max_length: 30)
      tokens = tokenize(sentence)
      word_count = min_length + rand(min_length - max_length) - tokens.length
      word_count.times do
        markov_state = [tokens[-2], tokens[-1]]
        tokens << @markov_model[markov_state].sample
        break if tokens[-1].nil? || tokens[-1] =~ /[!?\.]\z/
      end
      tokens.join(' ').strip
    end

    # Breaks the sentence into words using spaces. Punctuation is retained as
    # parts of words so that conjunctions and sentence endings retain data.
    #
    # @param [String] sentence to tokenize
    # @return [Array<Symbol>] the tokens in the sentence
    def tokenize(sentence)
      return [] if sentence.nil? || sentence.length == 0

      sentence.split(' ').map { |word| word.downcase.to_sym }
    end
  end
end
