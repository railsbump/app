module GemChecksHelper
  def gem_check_result_badge_class(gem_check)
    case gem_check_display_state(gem_check)
    when "failed" then "bg-danger"
    when "compatible" then "bg-success"
    when "upgrade_needed" then "bg-warning text-dark"
    when "incompatible" then "bg-danger"
    when "skipped" then "bg-light text-muted border"
    else "bg-secondary"
    end
  end

  def gem_check_row_class(gem_check)
    case gem_check_display_state(gem_check)
    when "failed", "incompatible" then "table-danger"
    when "compatible" then "table-success"
    when "upgrade_needed" then "table-warning"
    else ""
    end
  end

  def gem_check_result_label(gem_check)
    case gem_check_display_state(gem_check)
    when "failed" then "Failed"
    when "compatible" then "Compatible"
    when "upgrade_needed" then "Upgrade Needed"
    when "incompatible" then "Incompatible"
    when "skipped" then "Skipped"
    else "Pending"
    end
  end

  private

    def gem_check_display_state(gem_check)
      gem_check.failed? ? "failed" : (gem_check.result || "pending")
    end
end
