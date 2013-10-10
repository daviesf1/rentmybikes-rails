namespace :subledger do
  desc "Subledger Utils"

  # rake subledger:create["example@test.com","Test Account","Test Org","Test Book"]
  task :create, [:email, :identity_desc, :org_desc, :book_desc] => :environment do |t, args|
    email         = args[:email]
    identity_desc = args[:identity_desc]
    org_desc      = args[:org_desc]
    book_desc     = args[:book_desc]
     
    # create blank subledger instance
    subledger = Subledger.new
     
    puts "* Creating identity:"
    puts "  Email: #{email}"
    puts "  Description: #{identity_desc}"
     
    identity, key = subledger.identities.create email:       email,
                                                description: identity_desc
     
    # recreate subledger instance using key and secret
    subledger = Subledger.new key_id: key.id,
                              secret: key.secret
     
    puts ""
    puts "* Creating Org:"
    puts "  key_id: #{key.id}"
    puts "  secret: #{key.secret}"
    puts "  description: #{org_desc}"
     
    org = subledger.orgs.create description: org_desc
     
    puts ""
    puts "* Creating Book"
    puts "  org_id: #{org.id}"
    puts "  description: #{book_desc}"
     
    book = subledger.books.create org:         org,
                                  description: book_desc

    puts ""
    puts "* You are all set"
    puts "* Just add/set the the following on .env and config/creds:"
    puts "SUBLEDGER_KEY_ID='#{key.id}'"
    puts "SUBLEDGER_SECRET='#{key.secret}'"
    puts "SUBLEDGER_ORG_ID='#{org.id}'"
    puts "SUBLEDGER_BOOK_ID='#{book.id}'"
  end

  task :book, [:book_desc] => :environment do |t, args|
    book_desc = args[:book_desc]

    # create my subledger instance
    my_subledger = MySubledger.new

    # get org id
    org = ENV['SUBLEDGER_ORG_ID']

    puts ""
    puts "* Creating Book"
    puts "  org_id: #{org}"
    puts "  description: #{book_desc}"

    book = my_subledger.books.create org:         org,
                                     description: book_desc

    puts ""
    puts "* Book created"
    puts "SUBLEDGER_BOOK_ID='#{book.id}'"
  end

  # run after running subledger:create, and making the setup it indicates
  # normal_balance: "d" or "c"
  #
  # rake subledger:escrow["Example Escrow","http://yoursite.com","0"]
  task :escrow, [:description, :reference, :normal_balance] => :environment do |t, args|
    description    = args[:description]
    reference      = args[:reference]
    normal_balance = args[:normal_balance]

    # create my subledger instance
    my_subledger = MySubledger.new

    puts "* Creating Escrow Account:"
    puts "  Description: #{description}"
    puts "  Reference: #{reference}"
    puts "  Normal Balance: #{normal_balance}"

    balance = nil
    if normal_balance == "d"
      balance = my_subledger.debit
    else
      balance = my_subledger.credit
    end

    escrow = my_subledger.account.create description:    description,
                                         reference:      reference,
                                         normal_balance: balance

    puts ""
    puts "* Escrow Account created"
    puts "* Just add/set the following to .env and config/creds:"
    puts "SUBLEDGER_ESCROW_ID='#{escrow.id}'"
  end
end
