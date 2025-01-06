class AddressBlueprint < Blueprinter::Base
  identifier :id

  fields :street, :city, :postal_code, :country
end
