#!/bin/sh

# Clone multiple repositories.

echo "=== CLONENATOR ==="

array=( "https://github.com/rspec/rspec-core.git"
        "https://github.com/halostatue/diff-lcs/"  
        "https://github.com/rspec/rspec-expectations.git"  
        "https://github.com/rspec/rspec-mocks.git"  
        "https://github.com/rspec/rspec.git"  
        "https://github.com/rspec/rspec-support.git"  
        "https://github.com/erikhuda/thor.git"  
        "https://github.com/tzinfo/tzinfo.git"  
        "https://github.com/rtomayko/tilt.git"  
        "https://github.com/ruby-concurrency/thread_safe.git"  
        "https://github.com/rack-test/rack-test.git"  
        "https://github.com/seattlerb/minitest.git"  
        "https://github.com/sparklemotion/nokogiri.git"  
        "https://github.com/mikel/mail.git"  
        "https://github.com/ffi/ffi.git"  
        "https://github.com/lostisland/faraday.git" 
        "https://github.com/lautis/uglifier.git"
        "https://github.com/rest-client/rest-client.git"
        "https://github.com/pry/pry.git"
        "https://github.com/eventmachine/eventmachine.git"
        "https://github.com/redis/redis-rb.git"
        "https://github.com/sinatra/sinatra.git"
        "https://github.com/rails/jbuilder.git"
        "https://github.com/ruby/rdoc.git"
        "https://github.com/sparklemotion/http-cookie.git"
        "https://github.com/mileszs/wicked_pdf.git"
        "https://github.com/kjvarga/sitemap_generator.git"
        "https://github.com/oivoodoo/devise_masquerade.git"
        "https://github.com/norman/friendly_id.git"
        "https://github.com/alexreisner/geocoder.git"
        "https://github.com/RubyMoney/money-rails.git"
        "https://github.com/ryanb/letter_opener.git"
        "https://github.com/varvet/pundit.git"
        "https://github.com/plataformatec/devise.git"
        "https://github.com/thoughtbot/factory_bot.git"
        "https://github.com/teamcapybara/capybara.git"
        "https://github.com/paper-trail-gem/paper_trail.git"
        "https://github.com/aasm/aasm.git"
        "https://github.com/rubysherpas/paranoia.git"
        "https://github.com/rubocop-hq/rubocop.git"
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        ""
        )

cd ~/gem_src

for element in ${array[@]}
do
    echo "clonning $element"
    git clone $element 
done

echo "=== DONE ==="