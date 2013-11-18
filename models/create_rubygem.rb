class CreateRubygem < Scrivener
  attr_accessor :name, :status, :notes

  def validate
    assert_present :name
    assert_member :status, Rubygem::STATUSES
  end
end
