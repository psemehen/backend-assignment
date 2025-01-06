require "rails_helper"

RSpec.describe Api::V1::CompaniesController, type: :request do
  describe "POST /api/v1/companies" do
    let(:valid_attributes) do
      {
        name: "Test Company",
        registration_number: 111,
        addresses_attributes: [
          {
            street: "Test Str 1",
            city: "Test City 1",
            postal_code: "1",
            country: "Test Country 1"
          },
          {
            street: "Test Str 2",
            city: "Test City 2",
            postal_code: "2",
            country: "Test Country 2"
          }
        ]
      }
    end

    let(:invalid_attributes) do
      {
        name: "",
        registration_number: nil,
        addresses_attributes: [
          {
            street: "",
            city: "",
            postal_code: "",
            country: ""
          }
        ]
      }
    end

    context "with valid parameters" do
      it "creates a new Company" do
        expect {
          post api_v1_companies_path, params: {company: valid_attributes}
        }.to change(Company, :count).by(1)
      end

      it "creates associated addresses" do
        expect {
          post api_v1_companies_path, params: {company: valid_attributes}
        }.to change(Address, :count).by(2)
      end

      it "returns a created status" do
        post api_v1_companies_path, params: {company: valid_attributes}
        expect(response).to have_http_status(:created)
      end

      it "returns the created company data" do
        post api_v1_companies_path, params: {company: valid_attributes}
        json_response = JSON.parse(response.body)
        expect(json_response["data"]).to include(
          "id" => be_present,
          "name" => "Test Company",
          "registration_number" => 111,
          "addresses" => be_an(Array)
        )
      end

      it "returns the created addresses data" do
        post api_v1_companies_path, params: {company: valid_attributes}
        json_response = JSON.parse(response.body)
        expect(json_response["data"]["addresses"].length).to eq(2)
        expect(json_response["data"]["addresses"].first).to include(
          "id" => be_present,
          "street" => "Test Str 1",
          "city" => "Test City 1",
          "postal_code" => "1",
          "country" => "Test Country 1"
        )
        expect(json_response["data"]["addresses"].last).to include(
          "id" => be_present,
          "street" => "Test Str 2",
          "city" => "Test City 2",
          "postal_code" => "2",
          "country" => "Test Country 2"
        )
      end
    end

    context "with invalid parameters" do
      it "does not create a new Company" do
        expect {
          post api_v1_companies_path, params: {company: invalid_attributes}
        }.not_to change(Company, :count)
      end

      it "does not create any addresses" do
        expect {
          post api_v1_companies_path, params: {company: invalid_attributes}
        }.not_to change(Address, :count)
      end

      it "returns an unprocessable entity status" do
        post api_v1_companies_path, params: {company: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages" do
        post api_v1_companies_path, params: {company: invalid_attributes}
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("errors")
        errors = json_response["errors"]

        expect(errors).to include("name", "registration_number", "addresses.street", "addresses.city",
                                  "addresses.country")

        expect(errors["name"]).to include("can't be blank")
        expect(errors["registration_number"]).to include("can't be blank")
        expect(errors["addresses.street"]).to include("can't be blank")
        expect(errors["addresses.city"]).to include("can't be blank")
        expect(errors["addresses.country"]).to include("can't be blank")
      end
    end
  end
end
