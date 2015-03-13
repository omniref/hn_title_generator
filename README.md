# HN Title Generator - a gem to generate post titles from Hacker News using Markov Chains.

This gem consists of 2 parts. A thin wrapper for the HackerNews API to download
all the post data: `HNTitleGenerator::Item` and a Markov Model that will be trained on
the downloaded data: `HNTitleGenerator::MarkovModel`.

Get your own copy of the hacker news database with:

```ruby
require 'hn_title_generator'
HNTitleGenerator::Item.sync
# Wait days for that to finish, or hit CTRL-C when you feel like you've got 
# enough data to make that interesting.
```

Then create a new markov model that can complete your sentence for the most probable
title on hacker news.

```ruby
require 'hn_title_generator'
model = HNTitleGenerator::MarkovModel.new
model.complete_sentence #=> "sergio ramos ruled out for the go gopher – the big bang bundle with $14,863 worth of side projects with new technologies by reflecting light in 15 years of" 
model.complete_sentence("Show HN:") #=> "show hn: shoot missiles at ruby devs" 
```
