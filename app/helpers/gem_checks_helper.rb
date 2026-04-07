module GemChecksHelper
  def gem_check_result_badge_class(result)
    case result
    when "compatible" then "bg-success"
    when "upgrade_needed" then "bg-warning text-dark"
    when "incompatible" then "bg-danger"
    when "skipped" then "bg-light text-muted border"
    else "bg-secondary"
    end
  end

  def gem_check_row_class(result)
    case result
    when "compatible" then "table-success"
    when "upgrade_needed" then "table-warning"
    when "incompatible" then "table-danger"
    else ""
    end
  end

  def gem_check_result_label(result)
    case result
    when "compatible" then "Compatible"
    when "upgrade_needed" then "Upgrade Needed"
    when "incompatible" then "Incompatible"
    when "skipped" then "Skipped"
    else "Pending"
    end
  end
end
