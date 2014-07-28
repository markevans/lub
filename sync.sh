#!/bin/sh
ruby download_csv.rb
rails runner lib/tasks/import.rb statements/*.csv
rails runner lib/tasks/autotag.rb
