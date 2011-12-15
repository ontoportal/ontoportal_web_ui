# Mixin for UTF-8 supported substring
class String
  def utf8_slice(index, size = 1)
    self[/.{#{index}}(.{#{size}})/, 1]
  end

  def utf8_slice!(index, size = 1)
    str = self[/.{#{index}}(.{#{size}})/, 1]
    self[/.{#{index}}(.{#{size}})/, 1] = ""
    str
  end
end


