module MT940Structured::Parsers::Generic
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser
    include MT940Structured::Parsers::IbanSupport
    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(DD|CD|RC|RD|CR|DR|C|D)[A-Z]?(\d+),(\d{0,2})(.{4})([\p{L}\d\s\d_,;.+\s?]{1,16})(\/?\/?[\p{L}\d\s_,;().+?]{1,40})?/
    end

    # def parse_transaction(line_61)
    #   if line_61.match(get_regex_for_line_61)


    #     type = $3 == 'D' ? -1 : ($3 == 'RC' ? -1 : 1)
    #     transaction = MT940::Transaction.new(amount: type * ($4 + '.' + $5).to_f)
    #     transaction.type = $3
    #     transaction.date = parse_date($1)
    #     if $7.strip.start_with?("NONREF")
    #       transaction.customer_reference = "NONREF"
    #       bank_ref = $8.nil? ? '' : $8
    #       transaction.bank_reference = ($7+bank_ref).gsub('NONREF','').strip
    #     else
    #       transaction.customer_reference = $7.strip
    #       transaction.bank_reference = $8
    #     end
    #     puts "New"
    #     puts $1
    #     puts $2
    #     puts $3
    #     puts $4
    #     transaction.date_accounting = date_accounting(transaction.date, $2)
    #     transaction
    #   end
    # end

    # def parse_line_25(line)
    #   puts "25-----> " + line
    #   line.gsub!('.', '')
    #   @bank_statement.bank_account = line.gsub(/\D/, '').gsub(/^0+/, '')
    # end

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:(.*)$/)
        transaction.description = [transaction.description, $1].join(" ").strip
      end
    end

  end
end
