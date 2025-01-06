class CompanyBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :registration_number

  association :addresses, blueprint: AddressBlueprint
end
