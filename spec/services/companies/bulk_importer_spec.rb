require "rails_helper"

RSpec.describe Companies::BulkImporter, type: :service do
  let(:valid_csv_content) do
    <<~CSV
      name,registration_number,street,city,postal_code,country
      Example Co,123456789,123 Main St,New York,10001,USA
      Another Co,987654321,456 Elm St,Los Angeles,90001,USA
      Third Co,555555555,789 Oak St,Chicago,60601,USA
    CSV
  end

  let(:duplicate_csv_content) do
    <<~CSV
      name,registration_number,street,city,postal_code,country
      Example Co,123456789,123 Main St,New York,10001,USA
      Example Co,123456789,456 Elm St,Los Angeles,90001,USA
    CSV
  end

  let(:invalid_csv_content) do
    <<~CSV
      name,registration_number,street,city,postal_code,country
      Invalid Co,,"",,,
    CSV
  end

  let(:file) { Tempfile.new(["companies", ".csv"]) }

  before do
    file.write(csv_content)
    file.rewind
  end

  after { file.close && file.unlink }

  describe "#call" do
    subject { described_class.new(file).call }

    context "with valid CSV data" do
      let(:csv_content) { valid_csv_content }

      it "imports companies and their addresses successfully" do
        result = subject

        expect(result).to be_success
        expect(result.companies.size).to eq(3)
      end
    end

    context "with invalid data" do
      let(:csv_content) { invalid_csv_content }

      it "does not import invalid companies and returns errors" do
        result = subject

        expect(result.errors.first[:errors]).to include("Registration number can't be blank")
        expect(result.errors.first[:errors]).to include("Addresses street can't be blank")
        expect(result.errors.first[:errors]).to include("Addresses city can't be blank")
        expect(result.errors.first[:errors]).to include("Addresses country can't be blank")
      end
    end

    context "with duplicate records" do
      let(:csv_content) { duplicate_csv_content }

      it "imports the company once with multiple addresses" do
        result = subject

        expect(result).to be_success
        expect(result.companies.size).to eq(1)

        imported_company = result.companies.first
        expect(imported_company.name).to eq("Example Co")
        expect(imported_company.registration_number).to eq(123456789)
        expect(imported_company.addresses.size).to eq(2)

        addresses = imported_company.addresses
        expect(addresses.map(&:street)).to contain_exactly("123 Main St", "456 Elm St")
        expect(addresses.map(&:city)).to contain_exactly("New York", "Los Angeles")
        expect(addresses.map(&:postal_code)).to contain_exactly("10001", "90001")
        expect(addresses.map(&:country)).to all(eq("USA"))
      end
    end
  end
end
