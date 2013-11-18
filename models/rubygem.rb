class Rubygem < Sequel::Model
  STATUSES = ['ready', 'not ready', 'unknown']

  def self.recent quantity
    order(Sequel.desc(:updated_at)).limit quantity
  end
end
