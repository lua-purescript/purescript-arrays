-- module Data.Array.ST
local ST = {}

ST.runSTArray = function (f)
  return f
end

ST.emptySTArray = function ()
  return {}
end

ST.peekSTArrayImpl = function (just)
  return function (nothing)
    return function (xs)
      return function (i)
        return function ()
          return i >= 0 and i < #xs and just(xs[i+1]) or nothing
        end
      end
    end
  end
end

ST.pokeSTArray = function (xs)
  return function (i)
    return function (a)
      return function ()
        local ret = i >= 0 and i < #xs
        if ret then xs[i+1] = a end
        return ret
      end
    end
  end
end

ST.pushAllSTArray = function (xs)
  return function (as)
    return function ()
	  error("Not implemented: pushAllSTArray")
      return xs.push.apply(xs, as) -- TODO
    end
  end
end

ST.spliceSTArray = function (xs)
  return function (i)
    return function (howMany)
      return function (bs)
        return function ()
          error("Not implemented: spliceSTArray")
          return xs.splice.apply(xs, [i, howMany].concat(bs)) -- TODO
        end
      end
    end
  end
end

ST.copyImpl = function (xs)
  return function ()
    return copyTbl(xs)
  end
end

ST.toAssocArray = function (xs)
  return function ()
    local n = #xs
    local as = {}
    for i = 0, n do
      as[i+1] = {value = xs[i+1], index = i}
    end
    return as
  end
end

local function copyTbl(tbl)
  local result = {}
  for i = 1, #tbl do
    result[i] = tbl[i]
  end
  return result
end

return ST
