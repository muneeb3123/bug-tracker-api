require "rails_helper"

RSpec.describe "User", type: :request do
  describe "POST /users" do
    context "When creating a user" do

      def create_user_and_expect_success(user_params)
        post "/signup", params: { user: user_params }
        expect(response).to have_http_status(:success)
        JSON.parse(response.body)
      end

      it "should create a manager" do
        user_params = FactoryBot.attributes_for(:user, user_type: "manager")
        response_json = create_user_and_expect_success(user_params)
        expect(response_json["message"]).to eq("User created successfully")
      end

      it "should create a developer" do
        user_params = FactoryBot.attributes_for(:user, user_type: "developer")
        response_json = create_user_and_expect_success(user_params)
        expect(response_json["message"]).to eq("User created successfully")
      end

      it "should create a qa" do
        user_params = FactoryBot.attributes_for(:user, user_type: "qa")
        response_json = create_user_and_expect_success(user_params)
        expect(response_json["message"]).to eq("User created successfully")
      end
    end

    context "when login" do
      fixtures :users

      it "should login successfully" do
        user = users(:manager)
        post "/login", params: { user: { email: user.email, password: "123456" } }
        expect(response).to have_http_status(:success)
        response_json = JSON.parse(response.body)
        expect(response_json["message"]).to eq("you are successfully logged in")
      end
    end

    context "when fetch current user" do
      fixtures :users

      it "should fetch current user" do
        @user = users(:manager)
        get "/current_user", headers: auth_headers(@user)
        expect(response).to have_http_status(:success)
        response_json = JSON.parse(response.body)
        expect(response_json["user"]["email"]).to eq(@user.email)
      end
    end
  end
end
