class Rubygems < Cuba
  define do
    on root do
      render 'gems', gems: Rubygem.recent.limit(20)
    end
  end
end
