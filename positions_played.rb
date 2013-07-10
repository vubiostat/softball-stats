#!/usr/bin/env ruby

require 'optparse'

OPTS = {}

options = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options] [files]"

  opts.on('-n', '--player NAME', '--name NAME', 'Player name to search') do |n|
    OPTS[:player] = Regexp.new(n)
  end

  opts.on('-p', '--position POS', 'Position to search') do |p|
    OPTS[:position] = Regexp.new(p)
  end

  opts.on('-h', '--help') do
    puts opts
    exit
  end
end

options.parse!(ARGV)

DB = Hash.new { |h,k| h[k] = Hash.new(0) }

ARGV.each do |file|
  File.open(file).each_line do |line|
    if line =~ /^(?: [0-9]|1[0-9]) ([^ ]+ [^ ]+.*)/
      $1.split(' -> ').each do |sub_line|
        name, positions = sub_line.split(' ')
        positions.split('/').each do |position|
          if (OPTS[:player].nil? || name =~ OPTS[:player]) &&
            (OPTS[:position].nil? || position =~ OPTS[:position])
            DB[name][position] += 1
          end
        end
      end
    end
  end
end

if DB.length > 0
  size = DB.keys.max_by(&:length).length
  DB.sort_by {|k,v| k}.each do |n,v|
    v.each do |p,c|
      puts "#{n.ljust(size)}\t#{p}\t#{c}" #\t#{sprintf("%d %", 100.0*c/sub_total)}"
    end
  end
else
  puts "No matches found"
end
