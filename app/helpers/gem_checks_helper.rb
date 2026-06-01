module GemChecksHelper
  def gem_check_result_badge_class(gem_check)
    return "bg-danger" if gem_check.failed?

    case gem_check.result
    when "compatible" then "bg-success"
    when "upgrade_needed" then "bg-warning text-dark"
    when "incompatible" then "bg-danger"
    when "skipped" then "bg-light text-muted border"
    else "bg-secondary"
    end
  end

  def gem_check_row_class(gem_check)
    return "table-danger" if gem_check.failed?

    case gem_check.result
    when "compatible" then "table-success"
    when "upgrade_needed" then "table-warning"
    when "incompatible" then "table-danger"
    else ""
    end
  end

  def gem_check_result_label(gem_check)
    return "Failed" if gem_check.failed?

    case gem_check.result
    when "compatible" then "Compatible"
    when "upgrade_needed" then "Upgrade Needed"
    when "incompatible" then "Incompatible"
    when "skipped" then "Skipped"
    else "Pending"
    end
  end
end
