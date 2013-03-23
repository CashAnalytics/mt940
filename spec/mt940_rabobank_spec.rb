require_relative 'spec_helper'

describe "Rabobank" do
  let(:file_name) { File.dirname(__FILE__) + '/fixtures/rabobank.txt' }

  context "parse whole file" do
    let(:bank_statements) { MT940::Base.parse_mt940(file_name) }

    it "should have the correct number of bank account's" do
      bank_statements.keys.size.should == 1
    end

    it "should have the correct number of bank statements per bank account" do
      bank_statements["212121211"].size.should == 23
    end

    context MT940::BankStatement do
      let(:bank_statements_for_account) { bank_statements["212121211"] }

      it "should have the correct number of transactions per bank statement" do
        bank_statements_for_account[0].transactions.size.should == 1
        bank_statements_for_account[1].transactions.size.should == 0
        bank_statements_for_account[10].transactions.size.should == 2
      end

      context "single bank statement" do
        let(:bank_statement) { bank_statements_for_account[0] }

        it "should have a correct previous balance per statement" do
          balance = bank_statement.previous_balance
          balance.amount.should == 17431.67
          balance.date.should == Date.new(2012, 9, 28)
          balance.currency.should == "EUR"
        end

        it "should have a correct next balance per statement" do
          balance = bank_statement.new_balance
          balance.amount.should == 17381.67
          balance.date.should == Date.new(2012, 10, 1)
          balance.currency.should == "EUR"
        end

        context "debit transaction" do

          let(:transaction) { bank_statement.transactions.first }

          it "should have the correct amount" do
            transaction.amount.should == -50
          end

          it "should have a description" do
            transaction.description.should == "Incasso deposit Savings Account"
          end

          it "should have an account number" do
            transaction.bank_account.should == "212121211"
          end

          it "should have a contra account number" do
            transaction.contra_account.should == "1313131319"
          end

          it "should have a contra account owner" do
            transaction.contra_account_owner.should == "J. DOE"
          end

          it "should have a bank" do
            transaction.bank.should == "Rabobank"
          end

          it "should have a currency" do
            transaction.currency.should == "EUR"
          end

          it "should have a date" do
            transaction.date.should == Date.new(2012, 10, 1)
          end

          it "should have a type" do
            transaction.type.should == "Machtiging Rabobank"
          end

        end

      end

      context "credit transaction" do
        let(:transaction) { bank_statements_for_account[12].transactions[1] }

        it "should have the correct amount" do
          transaction.amount.should == 12100.00
        end

        it "should have the correct type" do
          transaction.type.should == "Bijschrijving betaalopdracht"
        end

        it "should have the correct contra account" do
          transaction.contra_account.should == "987654321"
        end

        it "should have the correct contra account owner" do
          transaction.contra_account_owner.should == "COMPANY B.V."
        end

      end

      context "transaction with a GIRO number" do
        let(:transaction) { bank_statements_for_account[18].transactions.first }

        it "should have the correct contra account" do
          transaction.contra_account.should == "2445588"
        end

        it "should have the correct contra account owner" do
          transaction.contra_account_owner.should == "Belastingdienst"
        end
      end

      context "with a unknown contra account" do
        let(:transaction) { bank_statements_for_account[3].transactions.first }

        it "should have a NONREF as contra account" do
          transaction.contra_account.should == "NONREF"
        end

        it "should have a contra account owner" do
          transaction.contra_account_owner.should == "Kosten"
        end

        it "should have a type" do
          transaction.type.should == "Afschrijving rente provisie kosten"
        end
      end

      context "multi line description" do
        let(:transaction) { bank_statements_for_account[5].transactions.first }

        it "should have the correct description" do
          transaction.description.should == "BETALINGSKENM.  490022201282 ARBEIDS ONG. VERZ. 00333333333 PERIODE 06.10.2012 - 06.11.2012"
        end

        it "should have a type" do
          transaction.type.should == "Doorlopende machtiging algemeen"
        end
      end
    end

  end

  it "should be able to handle a debet current balance" do
    debet_file_name = File.dirname(__FILE__) + '/fixtures/rabobank_with_debet_previous_balance.txt'
    bank_statement = MT940::Base.parse_mt940(debet_file_name)["129199348"].first

    bank_statement.previous_balance.amount.should == -12
    bank_statement.previous_balance.currency.should == "EUR"
    bank_statement.previous_balance.date.should == Date.new(2012, 10, 4)

    bank_statement.new_balance.amount.should == -12
    bank_statement.new_balance.currency.should == "EUR"
    bank_statement.new_balance.date.should == Date.new(2012, 10, 5)
  end

end