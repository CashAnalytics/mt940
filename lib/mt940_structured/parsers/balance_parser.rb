module MT940Structured::Parsers
  module BalanceParser
    def parse_balance(line,offset=0)
      currency = line[12+offset..14+offset]
      balance_date = parse_date(line[6+offset..11+offset])
      type = line[5+offset] == 'D' ? -1 : 1
      last_statement_date = line[3]=='F' ? true : false
      amount = line[15+offset..-1].gsub(",", ".").to_f * type
      MT940::Balance.new(amount: amount, date: balance_date, currency: currency, last_statement_date: last_statement_date)
    end
  end
end
