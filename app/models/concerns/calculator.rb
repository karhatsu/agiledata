module Calculator
  def average(array)
    return nil if array.empty?
    array.reduce(:+).to_f / array.size
  end
end