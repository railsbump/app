module HasTimestamps
  def self.[](*attrs)
    Module.new do
      extend ActiveSupport::Concern

      attrs_and_verbs = attrs.each_with_object({}) do |attr, hash|
        hash[attr] = attr.to_s.sub(/_(at|on)\z/, '')
      end

      included do
        attrs_and_verbs.each do |attr, verb|
          attr_with_table_name = "#{table_name}.#{attr}"
          scope verb,        -> { where.not(attr_with_table_name => nil) }
          scope "un#{verb}", -> { where(attr_with_table_name => nil) }

          scope "#{verb}_between", ->(start_time, end_time) {
            unless start_time && end_time
              raise "Start time and end time must be supplied when calling #{self}.#{verb}_between."
            end
            if start_time >= end_time
              raise "Start time must be before end time when calling #{self}.#{verb}_between."
            end
            where(attr_with_table_name => start_time..end_time)
          }

          { before: '<', after: '>' }.each do |before_or_after, operator|
            scope "#{verb}_#{before_or_after}", ->(time) { where("#{attr_with_table_name} #{operator} ?", time) }
          end
        end
      end

      attrs_and_verbs.each do |attr, verb|
        define_method "#{attr}=" do |value|
          if value.is_a?(Hash)
            values = value.fetch_values(:date, :time)
            if values.any?(&:blank?)
              value = nil
            else
              values.map! { |v| v.is_a?(String) ? Time.zone.parse(v) : v.to_time }
              date, time = values
              value = date.change(hour: time.hour, min: time.min, sec: time.sec)
            end
          end

          write_attribute attr, value
        end

        define_method "#{verb}?" do
          !!public_send(attr)
        end
        alias_method verb, "#{verb}?"

        define_method "un#{verb}?" do
          !public_send("#{verb}?")
        end
        alias_method "un#{verb}", "un#{verb}?"

        define_method "#{verb}!" do |time = Time.current, overwrite: true|
          if overwrite || public_send("un#{verb}?")
            update! attr => time
          end
        end

        define_method "un#{verb}!" do
          public_send "#{verb}!", nil
        end

        define_method "#{verb}=" do |value|
          if ActiveRecord::Type::Boolean.new.cast(value)
            unless public_send("#{verb}?")
              public_send "#{attr}=", Time.current
            end
          else
            public_send "#{attr}=", nil
          end
        end
      end
    end
  end
end
