# spec/requests/bugs_spec.rb
require 'rails_helper'

RSpec.describe "Bugs", type: :request do
  fixtures :users
  fixtures :projects
  fixtures :user_projects
  fixtures :bugs

  describe "GET /bugs" do 
    context "When no bugs are present" do
      it "should give error when no bugs found" do
        user = users(:admin)
        get "/bugs", headers: auth_headers(user)
        expect(response).to have_http_status(422)
        response_json = JSON.parse(response.body)
        expect(response_json["error"]).to include("No bugs found for the current user")
      end
    end

    context "When bugs are present" do
      it "should return all the bugs" do
        user = users(:manager)
        get "/bugs", headers: auth_headers(user)
        expect(response).to have_http_status(200)
        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq(3)
        expect(response_json[0]["title"]).to eq("Bug in Project1")
      end
    end
end

describe "Get /bugs/:id" do
  context "When bug is not present" do
    it "should give error when bug not found" do
      user = users(:admin)
      bug = bugs(:bug_one)
      get "/bugs/#{bug.id}", headers: auth_headers(user)
      expect(response).to have_http_status(404)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to include("Bug not found")
    end
  end

  context "When bug is present" do
    it "should return the bug" do
      user = users(:manager)
      bug = bugs(:bug_one)
      get "/bugs/#{bug.id}", headers: auth_headers(user)
      expect(response).to have_http_status(200)
      response_json = JSON.parse(response.body)
      expect(response_json["title"]).to eq("Bug in Project1")
    end
  end
end

describe "POST /bugs" do
  context "When ticket is created successfully" do
    it "should create a bug" do
      user = users(:qa)
      project = projects(:one)
      post "/bugs", params: { bug: FactoryBot.attributes_for(:bug, creator_id: user.id, project_id: project.id) }, headers: auth_headers(user)
      expect(response).to have_http_status(201)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to include("Bug created successfully")
    end
  end
context "When ticket is not created successfully" do
  it "should give error when creator is not qa" do
    user = users(:developer)
    project = projects(:one)
    post "/bugs", params: { bug: FactoryBot.attributes_for(:bug, creator_id: user.id, project_id: project.id) }, headers: auth_headers(user)
    expect(response).to have_http_status(403)
  end
  
  it "should give error when project is not present" do
    user = users(:qa)
    post "/bugs", params: { bug: FactoryBot.attributes_for(:bug, creator_id: user.id) }, headers: auth_headers(user)
    expect(response).to have_http_status(422)
    response_json = JSON.parse(response.body)
    expect(response_json["error"]["project"][0]).to include("must exist")
  end
end
end

describe "PUT /bugs/:id" do
  context "When bug is updated successfully" do
    it "should update the bug" do
      user = users(:qa)
      bug = bugs(:bug_one)
      manager = users(:manager)
      project = projects(:one)
      user_to_assign = user
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(manager)
      put "/bugs/#{bug.id}",params: {bug: {title: "update"}}, headers: auth_headers(user)
      expect(response).to have_http_status(200)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to include("Bug updated successfully")
    end
  end

  context "When bug is not updated successfully" do
    it "should give error when bug is not found" do
      user = users(:qa)
      put "/bugs/999", params: { bug: { title: "Updated title" } }, headers: auth_headers(user)
      expect(response).to have_http_status(404)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to include("Bug not found")
    end
  end
end

describe "DELETE /bugs/:id" do
  context "When bug is deleted successfully" do
    it "should delete the bug" do
      user = users(:qa)
      bug = bugs(:bug_one)
      manager = users(:manager)
      project = projects(:one)
      user_to_assign = user
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(manager)
      delete "/bugs/#{bug.id}", headers: auth_headers(user)
      expect(response).to have_http_status(200)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to include("Bug deleted successfully")
    end
  end
  context "When bug is not deleted successfully" do
    it "should give error when bug is not found" do
      user = users(:qa)
      delete "/bugs/999", headers: auth_headers(user)
      expect(response).to have_http_status(404)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to include("Bug not found")
    end
  end
end

describe "POST /bugs/:id/assign" do
  context "When bug is assigned successfully" do
    it "should assign the bug" do
      developer = users(:developer)
      bug = bugs(:bug_one)
      manager = users(:manager)
      project = projects(:one)
      user_to_assign = developer
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(manager)
      put "/bugs/#{bug.id}/assign_bug_or_feature", headers: auth_headers(developer)
      expect(response).to have_http_status(200)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to include("Bug assigned successfully")
    end
  end

  context "When bug is not assigned successfully" do
    it "should give error when bug is already assigned" do
      developer = users(:developer)
      bug = bugs(:bug_one)
      manager = users(:manager)
      project = projects(:one)
      user_to_assign = developer
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(manager)
      put "/bugs/#{bug.id}/assign_bug_or_feature", headers: auth_headers(developer)
      put "/bugs/#{bug.id}/assign_bug_or_feature", headers: auth_headers(developer)
      expect(response).to have_http_status(422)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to include("Bug is already assigned to a user")
    end
  end
end

describe "POST /bugs/:id/complete" do
  context "When bug is completed successfully" do
    it "should complete the bug" do
      developer = users(:developer)
      bug = bugs(:bug_one)
      manager = users(:manager)
      project = projects(:one)
      user_to_assign = developer
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(manager)
      put "/bugs/#{bug.id}/assign_bug_or_feature", headers: auth_headers(developer)
      put "/bugs/#{bug.id}/mark_resolved_or_completed", headers: auth_headers(developer)
      expect(response).to have_http_status(200)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to include("Marked as resolved")
    end
  end

  context "When bug is not completed successfully" do
    it "should give error when bug is not assigned" do
      developer = users(:developer)
      bug = bugs(:bug_one)
      manager = users(:manager)
      project = projects(:one)
      user_to_assign = developer
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(manager)
      put "/bugs/#{bug.id}/mark_resolved_or_completed", headers: auth_headers(developer)
      expect(response).to have_http_status(403)
    end
  end
end
end