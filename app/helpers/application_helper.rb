module ApplicationHelper
  def page_classes
    [
      controller.controller_name,
      { 'create' => 'new', 'update' => 'edit' }.fetch(controller.action_name, controller.action_name)
    ].join(' ')
  end

  def alert(level, text = nil, &block)
    content_tag :div, class: "alert alert-#{level} alert-dismissible fade show" do
      concat content_tag(:button, '×', type: 'button', class: 'close', data: { dismiss: 'alert' })
      concat text&.html_safe || capture_haml(&block)
    end
  end

  def flash_messages
    %i(notice alert).map do |level|
      next if flash[level].blank?
      alert_level = { notice: 'success', alert: 'danger' }.fetch(level)
      alert alert_level, flash[level]
    end.compact.join("\n").html_safe
  end

  def compats_status(compats)
    case
    when compats.none?              then :checking
    when compats.any?(&:compatible) then :compatible
    else                                 :incompatible
    end
  end

  def compats_label_and_text(compats, gemmy, rails_release)
    compatible_compats = compats.select(&:compatible)

    case compatible_compats
    when []      then return ['none', "No versions of #{gemmy} are compatible with #{rails_release}."]
    when compats then return ['all', "All versions of #{gemmy} are compatible with #{rails_release}."]
    end

    compatible_versions   = gemmy.versions(compatible_compats.map(&:dependencies))
    all_versions          = gemmy.versions
    incompatible_versions = all_versions - compatible_versions

    compatible_versions_string, all_versions_string = [compatible_versions, all_versions].map { _1.join(':') }

    label, text_prefix = case
    when all_versions_string.start_with?(compatible_versions_string)
      [
        "<= #{compatible_versions.last}",
        "Versions #{compatible_versions.last} and below"
      ]
    when all_versions_string.end_with?(compatible_versions_string)
      [
        ">= #{compatible_versions.first}",
        "Versions #{compatible_versions.first} and above"
      ]
    else
      major_version_numbers = compatible_versions.map { _1.segments.first }.uniq
      major_version_numbers.each do |version_number|
        matching_compatible_versions = compatible_versions.select { _1.is_a?(Gem::Version) && _1.segments.first == version_number }
        if matching_compatible_versions.size == all_versions.count { _1.segments.first == version_number }
          index = compatible_versions.index(matching_compatible_versions.first)
          compatible_versions.delete_if { matching_compatible_versions.include?(_1) }
          compatible_versions.insert index, "#{version_number}.x"
        end
      end
      label    = compatible_versions.size > 3 ? 'some' : compatible_versions.join(', ')
      versions = compatible_versions.map(&:to_s).to_sentence
      [
        label,
        "Versions #{versions}"
      ]
    end

    [
      label,
      "#{text_prefix} of #{gemmy} are compatible with #{rails_release}."
    ]
  end
end
