if defined?(IRB)
  Hirb.enable

  def t
    Transaction.select([:date, :description, :amount, :balance]).by_latest
  end

  def s(*args)
    t.search(*args)
  end

  def summary
    t.group_by {|tr|
      tr.date.strftime('%Y-%m')
    }.map {|month, transactions|
      puts "#{month} | #{transactions.sum(&:amount)}"
    }
    nil
  end

  puts "\n" * 3
  puts "t:\n  Show transactions\n\n"
  puts "s 'sainsburys':\n  Search for sainsbury's transactions\n\n"
  puts "summary: show summary by month\n\n"
  puts "Scopes:"
  puts
  %w(by_latest for_month(12,2012) pos neg).each do |scope|
   puts "  #{scope}"
  end
  puts "\n" * 3
end

