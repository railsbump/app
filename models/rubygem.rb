class Rubygem < Sequel::Model
  plugin :timestamps, update_on_create: true

  STATUSES = ['ready', 'not ready', 'unknown']

  dataset_module do
    def by_name
      order :name
    end
  end

  def self.recent limit
    order(Sequel.desc(:updated_at)).limit limit
  end

  def self.search query, limit
    where(Sequel.ilike(:name, "%#{query}%")).limit(limit).by_name
  end
end
