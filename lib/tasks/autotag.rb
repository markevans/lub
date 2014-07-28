transactions = Transaction.not_tagged
puts "Auto-tagging #{transactions.count} transactions"
Autotagger.tag(transactions)
puts "done"
