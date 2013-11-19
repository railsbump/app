module RoutesHelpers
  def not_found
    res.status = 404
    halt(res.finish)
  end

  def json data
    res.write data.to_json
  end
end
