class Api::V1::CompaniesController < ApplicationController
  def create
    company = Company.new(company_params)

    if company.save
      render json: CompanyBlueprint.render(company, root: :data), status: :created
    else
      render json: {errors: company.errors}, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :registration_number,
      addresses_attributes: [:street, :city, :postal_code, :country])
  end
end
