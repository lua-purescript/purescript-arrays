-- module Data.Array.Partial

local exports = {}

exports.unsafeIndexImpl = function (xs)
  return function (n)
    return xs[n+1]
  end
end

return exports
