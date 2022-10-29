# frozen_string_literal: true

module ApplicationHelper
  def page_classes
    [
      controller.controller_name,
      { "create" => "new", "update" => "edit" }.fetch(controller.action_name, controller.action_name)
    ].join(" ")
  end

  def alert(level, text = nil, &block)
    tag.div class: "alert alert-#{level} alert-dismissible fade show" do
      concat tag.button(type: "button", class: "btn-close", data: { bs_dismiss: "alert" })
      concat text&.html_safe || capture_haml(&block)
    end
  end

  def flash_messages
    flash.map do |level, message|
      level = { notice: "success", alert: "danger" }[level.to_sym] || level
      alert level, message
    end.compact.join("\n").html_safe
  end

  def compats_status(compats)
    case
    when compats.compatible.any?               then :compatible
    when compats.none? || compats.pending.any? then :checking
    else                                            :incompatible
    end
  end

  def compats_label_and_text(compats, gemmy, rails_release)
    compatible_compats = compats.compatible
    pending_compats    = compats.pending

    case
    when compats.none?
      return ["checking", "some versions of #{gemmy} are still being checked for compatibility with #{rails_release}."]
    when compatible_compats.none? && pending_compats.none?
      return ["none", "No version of #{gemmy} is compatible with #{rails_release}."]
    when compatible_compats.none? && pending_compats.any?
      return ["checking", "#{pluralize pending_compats.size, "version"} of #{gemmy} #{pending_compats.many? ? "are" : "is"} still being checked for compatibility with #{rails_release}."]
    when compatible_compats.ids == compats.ids
      return ["all", "All versions of #{gemmy} are compatible with #{rails_release}."]
    end

    compatible_versions   = gemmy.versions(compatible_compats.map(&:dependencies))
    all_versions          = gemmy.versions
    incompatible_versions = all_versions - compatible_versions

    compatible_versions_string, all_versions_string = [compatible_versions, all_versions].map { _1.join(":") }

    label, text_prefix = case
    when compatible_versions.many? && all_versions_string.start_with?(compatible_versions_string)
      [
        "<= #{compatible_versions.last}",
        "#{pluralize compatible_versions.size, "Version"} #{compatible_versions.last} and below"
      ]
    when compatible_versions.many? && all_versions_string.end_with?(compatible_versions_string)
      [
        ">= #{compatible_versions.first}",
        "#{pluralize compatible_versions.size, "Version"} #{compatible_versions.first} and above"
      ]
    else
      if compatible_versions.many?
        major_version_numbers = compatible_versions.map { _1.segments.first }.uniq
        major_version_numbers.each do |version_number|
          matching_compatible_versions = compatible_versions.select { _1.is_a?(Gem::Version) && _1.segments.first == version_number }
          if matching_compatible_versions.size == all_versions.count { _1.segments.first == version_number }
            index = compatible_versions.index(matching_compatible_versions.first)
            compatible_versions.delete_if { matching_compatible_versions.include?(_1) }
            compatible_versions.insert index, "#{version_number}.x"
          end
        end
      end

      label    = compatible_versions.size > 3 ? "some" : compatible_versions.join(", ")
      versions = compatible_versions.map(&:to_s).to_sentence

      [
        label,
        "#{"Version".pluralize(versions.size)} #{versions}"
      ]
    end

    text = "#{text_prefix} of #{gemmy} #{compatible_versions.many? ? "are" : "is"} compatible with #{rails_release}"
    if pending_compats.any?
      text << ", but #{pluralize pending_compats.size, "other version"} #{pending_compats.many? ? "are" : "is"} still being checked"
    end

    [
      label,
      "#{text}."
    ]
  end

  def async_turbo_frame(name, **attributes, &block)
    # If a ActiveRecord record is passed to `turbo_frame_tag`,
    # `dom_id` is called to determine its DOM ID.
    # This exposes the record ID, which is not desirable if the record has a slug.
    if name.is_a?(ActiveRecord::Base) && name.respond_to?(:slug)
      name = [name.class.to_s.underscore, name.slug].join("_")
    end

    unless url = attributes[:src]
      raise "async_turbo_frame needs a `src` attribute."
    end

    uris = [
      url_for(url),
      request.fullpath
    ].map { Addressable::URI.parse _1 }
    uris_match = %i(path query_values).all? { uris.map(&_1).uniq.size == 1 }

    if uris_match
      turbo_frame_tag name, &block
    else
      turbo_frame_tag name, **attributes do
        render "shared/loading"
      end
    end
  end
end
