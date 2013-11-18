class Rubygem < Sequel::Model
  plugin :timestamps, update_on_create: true

  STATUSES = ['ready', 'not ready', 'unknown']

  dataset_module do
    def ordered_by_name
      order :name
    end

    def by_name name
      where Sequel.ilike(:name, "%#{ name }%")
    end

    def by_status status
      where status: status
    end
  end

  set_dataset self.ordered_by_name

  def self.recent limit = 25
    order(Sequel.desc(:updated_at)).limit limit
  end
end
