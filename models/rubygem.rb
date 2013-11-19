class Rubygem < Sequel::Model
  plugin :timestamps, update_on_create: true

  STATUSES = ['ready', 'not ready', 'unknown']

  set_dataset order(:name)

  def self.recent limit = 25
    order(Sequel.desc(:updated_at)).limit limit
  end

  def self.search_by_name name
    where Sequel.ilike(:name, "%#{ name }%")
  end
end
