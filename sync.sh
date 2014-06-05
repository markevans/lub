#!/bin/sh
ruby download_csv.rb
rails runner lib/tasks/import.rb statements/*.csv
