module Autotagger
  class << self

    def tag(transactions)
      transactions.each do |transaction|
        tag_transaction(transaction)
      end
    end

    MATCHERS = {
      /\brent\b/i => 'rent',
      /^cash\b/i => 'atm',
      /^lul ticket machine/i => 'atm',
      /credit card/i => 'credit_card',
      /beyond ourselves|all souls fund|tearfund|london city missio|\bstewardship\b/i => 'charity',
      /waitrose|sainsbury|tesco|\basda\b/i => 'groceries',
      /\bbrgas|thames water|tv licence|hackney ctax|virgin mobile|virgin media|\brtb service\b|hackney bor|^aviva\b|service charge/i => 'bills',
      /\bsalary\b/i => 'salary',
      "MR P J EVANS MARK EVANS" => 'repay_loan',
      /poundland/i => 'household',
      /tx maxx/i => 'shopping',
      /holmes place/i => 'gym',
      /restaurant|\bpub\b/i => 'going_out',
      /first capital conn|^tfl |london overground/i => 'travel',
      /\bmortgage\b/i => 'mortgage'
    }

    def tag_transaction(transaction)
      MATCHERS.each do |pattern, tag_name|
        transaction.tag!(tag_name) if pattern === transaction.description
      end
    end
  end
end
