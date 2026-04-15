# frozen_string_literal: true

require "rails_helper"

# Evaluation suite for DirectResolver. Runs real resolution against rubygems.org
# using scenarios defined in direct_resolver_scenarios.yml.
#
# These are non-deterministic: gem releases can change resolution results.
# A failure means "review what changed", not necessarily "code is broken."
#
# Run:    bundle exec rspec spec/lib/direct_resolver_eval_spec.rb
# Update: EVAL_UPDATE=1 bundle exec rspec spec/lib/direct_resolver_eval_spec.rb
#         (updates the YAML with current results for any mismatches)

SCENARIOS_PATH = Rails.root.join("spec/lib/direct_resolver_scenarios.yml")

RSpec.describe "DirectResolver evaluation", :network do
  scenarios = YAML.safe_load_file(SCENARIOS_PATH, permitted_classes: [Symbol])

  scenarios.each do |scenario|
    describe scenario["name"] do
      it "is #{scenario['expected']}" do
        result = DirectResolver.new(
          rails_version: scenario["rails_version"],
          ruby_version: scenario["ruby_version"],
          dependencies: scenario.fetch("dependencies", {}),
          promoter: (scenario["promoter"] || "latest").to_sym
        ).call

        actual = result.compatible? ? "compatible" : "incompatible"

        if actual != scenario["expected"] && ENV["EVAL_UPDATE"]
          update_scenario(scenario["name"], actual)
          pending "Result changed from #{scenario['expected']} to #{actual} (YAML updated)"
        end

        expect(actual).to eq(scenario["expected"]),
          "Expected #{scenario['expected']} but got #{actual}.\n" \
          "Error: #{result.error}\n" \
          "Notes: #{scenario['notes']}\n" \
          "Run with EVAL_UPDATE=1 to update the scenario file."
      end
    end
  end
end

def update_scenario(name, new_expected)
  content = File.read(SCENARIOS_PATH)
  updated = false

  lines = content.lines
  lines.each_with_index do |line, i|
    if line.strip == "- name: \"#{name}\""
      # Find the expected: line within the next 10 lines
      ((i + 1)..[i + 10, lines.length - 1].min).each do |j|
        if lines[j].match?(/^\s+expected:/)
          lines[j] = lines[j].sub(/expected:\s*\S+/, "expected: #{new_expected}")
          updated = true
          break
        end
      end
    end
  end

  File.write(SCENARIOS_PATH, lines.join) if updated
end
