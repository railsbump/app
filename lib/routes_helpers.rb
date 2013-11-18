module RoutesHelpers
  def not_found
    res.status = 404
    halt(res.finish)
  end
end
