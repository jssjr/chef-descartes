#!/usr/bin/env rake

require 'foodcritic'

task :default => [:foodcritic]

FoodCritic::Rake::LintTask.new do |t|
  t.options = {
    :tags => %w( ~readme ),
  }
end

