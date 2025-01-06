module Companies
  class BulkImporter < BaseService
    def initialize(file)
      @file_path = file.path
      @errors = []
      @imported_companies = []
    end

    def call
      companies_data = parse_csv
      grouped_data = companies_data.group_by { |data| data[:registration_number] }

      grouped_data.each do |registration_number, entries|
        next if company_exists?(registration_number)

        company = build_company(entries)
        if company.valid?
          company.save
          @imported_companies << company
        else
          collect_errors(company)
        end
      end

      response
    end

    private

    attr_reader :file_path
    attr_accessor :errors, :imported_companies

    def parse_csv
      CSV.foreach(@file_path, headers: true).map do |row|
        {
          name: row["name"],
          registration_number: row["registration_number"],
          street: row["street"],
          city: row["city"],
          postal_code: row["postal_code"],
          country: row["country"]
        }
      end
    end

    def company_exists?(registration_number)
      Company.exists?(registration_number: registration_number)
    end

    def build_company(entries)
      Company.new(
        name: entries.first[:name],
        registration_number: entries.first[:registration_number],
        addresses_attributes: entries.map do |entry|
          {
            street: entry[:street],
            city: entry[:city],
            postal_code: entry[:postal_code],
            country: entry[:country]
          }
        end
      )
    end

    def collect_errors(company)
      @errors << {
        registration_number: company.registration_number,
        errors: company.errors.full_messages
      }
    end

    def response
      if @errors.any?
        failure(@errors)
      else
        success(companies: @imported_companies)
      end
    end
  end
end
