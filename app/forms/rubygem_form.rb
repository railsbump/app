require 'reform/rails'

class ExistsInRubygemsDotOrgValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    record.errors[attribute] << "is not the name of a gem registered in http://rubygems.org" if Net::HTTP.get("rubygems.org", "/api/v1/gems/#{value}.json") == "This rubygem could not be found."
  end
end

class HasRubygemNameFormatValidator < ActiveModel::EachValidator
  SPECIAL_CHARACTERS = ".-_"
  ALLOWED_CHARACTERS = "[A-Za-z0-9#{Regexp.escape(SPECIAL_CHARACTERS)}]+"
  NAME_PATTERN       = /\A#{ALLOWED_CHARACTERS}\Z/

  def validate_each record, attribute, value
    record.errors[attribute] << "must include at least one letter" if value !~ /[a-zA-Z]+/
    record.errors[attribute] << "can only include letters, numbers, dashes, and underscores" if value !~ NAME_PATTERN
  end
end

class RubygemForm < Reform::Form
  include DSL
  include Reform::Form::ActiveRecord

  properties [:name, :status, :notes], on: :rubygem

  attr_accessor :miel # honeypot field for spammers

  model :rubygem

  validates :name,   presence: true, uniqueness: { case_sensitive: false }, has_rubygem_name_format: true, exists_in_rubygems_dot_org: true
  validates :status, presence: true, inclusion: Rubygem::STATUSES
  validates :notes,  presence: true
  validates :miel,   format: { without: /.+/ }

  def save params
    rubygem.update(to_h) if validate(params)
  end

end
