require_relative 'spec_helper'

describe MT940Structured::Parser do
  let(:full_file_name) { File.dirname(__FILE__) + "/fixtures/invalid_files/#{file_name}" }
  let(:bank_statements) { MT940Structured::Parser.parse_mt940(full_file_name)[bank_account_number] }
  let(:transactions) { bank_statements.flat_map(&:transactions) }
  let(:transaction) { transactions.first }

  context 'revolut' do
    let(:file_name) { 'revolut.txt' }

    it 'fails with InvalidFileContentError' do
      expect { transaction }.to raise_error(MT940Structured::InvalidFileContentError)
    end
  end
end