#!/usr/bin/env ruby

require 'optparse'

OPTS = {}

options = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options] [files]"

  opts.on('-n', '--player NAME', '--name NAME', 'Player name to search') do |n|
    OPTS[:player] = n
  end

  opts.on('-p', '--position POS', 'Position to search') do |p|
    OPTS[:position] = p
  end

  opts.on('-h', '--help') do
    puts opts
    exit
  end
end

options.parse!(ARGV)

if OPTS[:player].nil? && OPTS[:position].nil?
  puts options.inspect
  exit
elsif OPTS[:player].nil?
  PATTERN = Regexp.new("\\b(\\w+)\\b [^ ]*\\b(?:#{OPTS[:position]})\\b")
elsif OPTS[:position].nil?
  PATTERN = Regexp.new("\\b(?:#{OPTS[:player]})\\b \\b(\\w+)\\b")
else
  PATTERN = Regexp.new("\\b(#{OPTS[:player]})\\b [^ ]*\\b(#{OPTS[:position]})\\b")
end

# puts OPTS.inspect
# puts ARGV.inspect
# puts PATTERN.inspect

DB = Hash.new(0)

ARGV.each do |file|
  File.open(file).each_line do |line|
    line.split(' -> ').each do |sub_line|
      if sub_line =~ PATTERN
        DB[[$1,$2].join(':')] += 1
      end
    end
  end
end

if DB.length > 0
  size = DB.keys.max_by(&:length).length
  DB.sort_by {|k,v| k}.each do |k,v|
    puts "#{k.ljust(size)}\t#{v}"
  end
else
  puts "No matches found"
end
