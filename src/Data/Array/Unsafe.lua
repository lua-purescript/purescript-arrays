-- module Data.Array.Unsafe
local Unsafe = {}

exports.unsafeIndex = function (xs)
  return function (n)
    return xs[n+1]
  end
end

return Unsafe
