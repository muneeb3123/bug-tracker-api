# spec/requests/bugs_spec.rb
require 'rails_helper'

RSpec.describe "Bugs", type: :request do
  fixtures :users

  let(:manager) { users(:manager) }
  let(:developer) { users(:developer) }
  let(:qa) { users(:qa) }

  describe "GET /index" do 
    it "returns http success" do 
      get "/bugs"  # Adjust this to the correct endpoint if necessary
      expect(response).to have_http_status(:success)
    end
  end
end
