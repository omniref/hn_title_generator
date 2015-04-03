module HNTitleGenerator
  class NaiveBayes
    ##
    # Creates a new Bayesian model from the corpus of HN stories to calculate
    # the probability of a "successful" post based on FEATURES
    #
    # @param Integer success_threshold the minimum score to consider successful
    def initialize(success_threshold: 10)
      successes = total = 0
      @feature_outcomes = Hash.new { |hash, key| hash[key] = [] }

      Item.each_story do |story|
        title = story.title.to_s
        success = success_threshold < story.score.to_i

        total += 1
        successes += 1 if success

        FEATURES.each do |feature|
          @feature_outcomes[feature] << (success ? 1 : 0) if send(feature, title)
        end
      end

      @probability_of_success = successes / total.to_f
      @probability_of_feature = {}
      @probability_of_feature_given_success = {}
      @feature_outcomes.each do |feature, outcomes|
        feature_successes = outcomes.inject(:+)
        feature_total = outcomes.length
        @probability_of_feature[feature] = feature_total / total.to_f
        @probability_of_feature_given_success[feature] = feature_successes / successes.to_f
      end
    end

    ##
    # Use Bayes Theorem to calculate the posterior probability of a story's
    # success on Hacker News given a particular title alone
    #
    # @param String title of the story
    # @return Float probability
    def probability_of_success_given(title)
      features = FEATURES.select { |feature| send(feature, title) }
      p_features = features.map { |feature| @probability_of_feature[feature] }.inject(1, :*)
      p_feature_given_successes = features.map { |feature| @probability_of_feature_given_success[feature] }.inject(1, :*)
      p_feature_given_successes * @probability_of_success / p_features
    end

    private
      FEATURES = %i(short? long? hype? currency? tech_co? show_hn? question?
        agency? space? politics? apple? location? education? browser? programming?
        security? list?
      )

      def short?(title)
        title.length < 20
      end

      def long?(title)
        title.length > 40
      end

      def hype?(title)
        title =~ /awesome|top|amazing|rock|star|awe|beautiful|breath.taking|impressive|magnificent/i
      end

      def currency?(title)
        title =~ /[₳฿₵¢₡₢$₫₯₠€ƒ₣₲₴₭₺ℳ₥₦₧₱₰£៛₽₹₨₪৳₸₮₩¥]/
      end

      def tech_co?(title)
        title =~ /samsung|apple|foxconn|hp|ibm|amazon|microsoft|sony|panasonic|google|dell|toshiba|lg|intel/i
      end

      def show_hn?(title)
        title =~ /show.hn:/i
      end

      def question?(title)
        title.include?('?')
      end

      def agency?(title)
        title =~ /CIA|FAA|FBI|FCC|FDA|NSA/i
      end

      def space?(title)
        title =~ /NASA|space|orbit|atlas|telescope|curiosity|rover|kepler|mars|hubble/i
      end

      def politics?(title)
        title =~ /left|right|democrat|republic|sociali|liber|conserv/i
      end

      def apple?(title)
        title =~ /apple|mac|ipad|ipod|iphone|ios|(objective.c)|swift/i
      end

      def location?(title)
        title =~ /silicon valley|wall st|new york|paris|london|berlin|tokyo/i
      end

      def education?(title)
        title =~ /yale|harvard|stanford|university|school|teach|learn|edu/i
      end

      def browser?(title)
        title =~ /chrome|firefox|safari|explorer|opera/i
      end

      def programming?(title)
        title =~ /\bc\b|python|ruby|java|perl|script/i
      end

      def security?(title)
        title =~ /hack|secur|bug|flaw|overflow|heart.?bleed|zero.?day/i
      end

      def list?(title)
        title =~ /\d+ (ways|things|steps|tips|tricks)/i
      end
  end
end