module HasTimestamps
  def self.[](*attrs)
    Module.new do
      extend ActiveSupport::Concern

      attrs_and_verbs = attrs.index_with do |attr|
        attr.to_s.sub(/_(at|on)\z/, '')
      end

      included do
        attrs_and_verbs.each do |attr, verb|
          attr_with_table_name = "#{table_name}.#{attr}"
          scope verb,        -> { where.not(attr_with_table_name => nil) }
          scope "un#{verb}", -> { where(attr_with_table_name => nil) }

          scope "#{verb}_between", ->(start_time, end_time) {
            if start_time >= end_time
              raise 'Start time must be before end time.'
            end
            where(attr_with_table_name => start_time..end_time)
          }

          { before: %w(< >), after: %w(> <) }.each do |before_or_after, (operator, unoperator)|
            scope "#{verb}_#{before_or_after}", ->(time = Time.current) {
              where("#{attr_with_table_name} #{operator} ?", time)
            }
            scope "un#{verb}_#{before_or_after}", ->(time = Time.current) {
              where("(#{attr_with_table_name} IS NULL) OR (#{attr_with_table_name} #{unoperator} ?)", time)
            }
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

        define_method "#{verb}_between?" do |start_time, end_time|
          if start_time >= end_time
            raise 'Start time must be before end time.'
          end
          public_send("#{verb}?") && (start_time..end_time).cover?(public_send(attr))
        end

        %i(before after).each do |before_or_after|
          define_method "#{verb}_#{before_or_after}?" do |time = Time.current|
            public_send("#{verb}?") && (before_or_after == :before ? public_send(attr) < time : public_send(attr) > time)
          end
        end

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
