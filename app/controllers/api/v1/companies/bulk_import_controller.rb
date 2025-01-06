class Api::V1::Companies::BulkImportController < ApplicationController
  def create
    return render_file_not_provided_error unless file_present?

    result = Companies::BulkImporter.call(params[:file])

    if result.success?
      render json: {message: "Data successfully imported.", data: result.companies}, status: :ok
    else
      render json: {errors: result.errors}, status: :unprocessable_entity
    end
  end

  private

  def file_present?
    params[:file].present?
  end

  def render_file_not_provided_error
    render json: {errors: [message: "No file provided"]}, status: :bad_request
  end
end
