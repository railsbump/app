class Rubygem < Sequel::Model
  STATUSES = ['ready', 'not ready', 'unknown']

  def self.recent
    order Sequel.desc(:updated_at)
  end
end
