# MarkovNews - a gem to generate post titiles from Hacker News using Markov Chains.

This gem consists of 2 parts. A thin wrapper for the HackerNews API to download
all the post data: `MarkovNews::Item` and a Markov Model that will be trained on
the downloaded data: `MarkovNews::Brain`.

Get your own copy of the hacker news database with:

```ruby
require 'markov_news'
MarkovNews::Item.sync
# Wait days for that to finish, or hit CTRL-C when you feel like you've got 
# enough data to make that interesting.
```

Then create a new brain that can complete your sentence for the most probable
title on hacker news.

```ruby
require 'markov_news'
brain = MarkovNews::Brain.new
brain.complete_sentence #=> "sergio ramos ruled out for the go gopher – the big bang bundle with $14,863 worth of side projects with new technologies by reflecting light in 15 years of" 
brain.complete_sentence("Show HN:") #=> "show hn: shoot missiles at ruby devs" 
```
