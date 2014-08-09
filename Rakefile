require 'rubygems'
require 'rake'
require 'rake/clean'

DATA_DIR="data"

CLEAN.include ["#{DATA_DIR}/*.csv"]

task :bins_to_csv do
  sh %{ruby bin/bins-to-csv.rb}
end

task :download => [:bins_to_csv]