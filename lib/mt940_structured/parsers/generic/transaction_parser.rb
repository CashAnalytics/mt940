module MT940Structured::Parsers::Generic
  class TransactionParser
    include MT940Structured::Parsers::DateParser
    include MT940Structured::Parsers::DefaultLine61Parser
    include MT940Structured::Parsers::IbanSupport

    def get_regex_for_line_61
      /^:61:(\d{6})(\d{4})?(C|D|DC|CD|RC|RD|CR|DR)(\d+),(\d{0,2})/
    end

    def parse_line_25(line)
      line.gsub!('.', '')
      @bank_statement.bank_account = line.gsub(/\D/, '').gsub(/^0+/, '')
    end

    def enrich_transaction(transaction, line_86)
    end

    def enrich_transaction(transaction, line_86)
      if line_86.match(/^:86:(.*)$/)
        transaction.description = [transaction.description, $1].join(" ").strip
      end
    end
  end
end
