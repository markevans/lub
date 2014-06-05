if ARGV.length == 0
  puts "Usage: import <filename(s)>"
  exit
end

require 'csv'

def dot(char)
  print char
  $stdout.flush
end

ARGV.each do |arg|
  path = File.expand_path(arg)
  puts "Importing from #{path}"
  CSV.foreach(path, :headers => true) do |row|
    transaction = Transaction.new(
      :date => row["Date"],
      :description => row["Description"],
      :amount => (row["Amount"].to_f * 100).round,
      :balance => (row["Balance"].to_f * 100).round
    )
    if transaction.save
      dot('.')
    else
      dot('-')
    end
  end
  puts "done"
end