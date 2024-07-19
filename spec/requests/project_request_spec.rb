require "rails_helper"

RSpec.describe "Project", type: :request do
  fixtures :users
  fixtures :projects
  fixtures :bugs

  def create_project_with_user(user)
    project_params = FactoryBot.attributes_for(:project)
    post "/projects", params: { project: project_params }, headers: auth_headers(user)
  end

  describe "POST /projects" do
    context "when creating a project" do
      it "should create a project when manager" do
        user = users(:manager)
        create_project_with_user(user)
        expect(response).to have_http_status(:created)
        response_json = JSON.parse(response.body)
        expect(response_json["message"]).to eq("Project created successfully")
      end

      it "should not create a project when developer" do
        user = users(:developer)
        create_project_with_user(user)
        expect(response).to have_http_status(403)
        response_json = JSON.parse(response.body)
        expect(response_json["error"]).to include("Access denied: You are not authorized to access this page.")
      end

      it "should not create a project when QA" do
        user = users(:qa)
        create_project_with_user(user)
        expect(response).to have_http_status(403)
        response_json = JSON.parse(response.body)
        expect(response_json["error"]).to include("Access denied: You are not authorized to access this page.")
      end
    end

    context "when updating a project" do
      it "should update a project when manager" do
        user = users(:manager)
        project_params = FactoryBot.attributes_for(:project, name: "updated project name")
        create_project_with_user(user)
        project_id = JSON.parse(response.body)["project"]["id"]
        put "/projects/#{project_id}", params: { project: project_params }, headers: auth_headers(user)
        expect(response).to have_http_status(:success)
        response_json = JSON.parse(response.body)
        expect(response_json["message"]).to eq("Project updated successfully")
      end
    end
  end

  describe "GET /projects" do
    context "when no projects are present" do
      it "should give error when no projects found" do
        user = users(:manager)
        get "/projects", headers: auth_headers(user)
        expect(response).to have_http_status(422)
        response_json = JSON.parse(response.body)
        expect(response_json["error"]).to eq("No projects found for the current user")
      end
    end

    context "when projects are present" do
      fixtures :user_projects
      it "should fetch all projects" do
        user = users(:manager)
        get "/projects", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
        response_json = JSON.parse(response.body)
        project_names = response_json.map { |project| project["name"] }
        expect(project_names).to include("Project1", "Project2", "Project3")
      end

      it "should fetch all developer assigned projects" do
        user = users(:developer)
        get "/projects", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
      end

      it "should fetch all QA assigned projects" do
        user = users(:qa)
        get "/projects", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
      end
    end

    context "when fetching a project" do
      it "should fetch a project when manager" do
        user = users(:manager)
        project = projects(:one)
        get "/projects/#{project.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
        response_json = JSON.parse(response.body)
        expect(response_json["name"]).to eq("Project1")
      end

      it "should fetch a project when developer" do
        user = users(:developer)
        project = projects(:three)
        get "/projects/#{project.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
        response_json = JSON.parse(response.body)
        expect(response_json["name"]).to eq("Project3")
      end
    end
  end

  describe "DELETE /projects/:id" do
    it "should delete a project when manager" do
      user = users(:manager)
      project = projects(:one)
      delete "/projects/#{project.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to eq("Project deleted successfully")
    end
  end

  describe "POST /projects/:id/assign_user" do
    it "should assign a developer user to a project when manager" do
      user = users(:manager)
      project = projects(:one)
      user_to_assign = users(:developer)
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to eq("User assigned successfully")
    end

    it "should assign a QA user to a project when manager" do
      user = users(:manager)
      project = projects(:one)
      user_to_assign = users(:qa)
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to eq("User assigned successfully")
    end

    it "should not assign a user to a project when already assigned" do
      user = users(:manager)
      project = projects(:three)
      user_to_assign = users(:developer)
      post "/projects/#{project.id}/assign_user/#{user_to_assign.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:unprocessable_entity)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to eq("User is already assigned to the project")
    end

    it "should not assign a user to a project when user not found" do
      user = users(:manager)
      project = projects(:three)
      post "/projects/#{project.id}/assign_user/100712i12", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to eq("User or project not found")
    end

    it "should remove a user from a project" do
      user = users(:manager)
      project = projects(:three)
      user_to_remove = users(:developer)
      delete "/projects/#{project.id}/remove_user/#{user_to_remove.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json["message"]).to eq("User removed successfully")
    end

    it "should not remove a user from a project when user not found" do
      user = users(:manager)
      project = projects(:one)
      delete "/projects/#{project.id}/remove_user/100712i12", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to eq("User or project not found")
    end
  end

  describe "GET /projects/:id/users_and_bugs_by_project" do
    it "should fetch users and bugs by project" do
      user = users(:manager)
      project = projects(:three)
      get "/projects/#{project.id}/users_and_bugs_by_project", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json["collaborators"].length).to eq(3)
      expect(response_json["bugs"].length).to eq(1)
    end
  end

  describe "GET /projects/search" do
    it "should search for projects with one letter" do
      user = users(:manager)
      get "/projects/search?query=P", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end

    it "should search for projects with two letters" do
      user = users(:manager)
      get "/projects/search?query=Pr", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end

    it "should search for specific projects" do
      user = users(:manager)
      get "/projects/search?query=Project1", headers: auth_headers(user)
      expect(response).to have_http_status(:success)
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
    end

    it "should not find any projects when project exists but not assigned" do
      user = users(:developer)
      get "/projects/search?query=Project1", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to eq('No projects found')
    end

    it "should not find any projects when project does not exist" do
      user = users(:manager)
      get "/projects/search?query=Project100", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to eq('No projects found')
    end

    it "should not find any projects when query is empty" do
      user = users(:manager)
      get "/projects/search?query=", headers: auth_headers(user)
      expect(response).to have_http_status(422)
      response_json = JSON.parse(response.body)
      expect(response_json["error"]).to eq('No search query provided')
    end
  end
end
