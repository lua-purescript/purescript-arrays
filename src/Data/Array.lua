-- module Data.Array

local Data_Array = {}

--------------------------------------------------------------------------------
-- Array creation --------------------------------------------------------------
--------------------------------------------------------------------------------

Data_Array.range = function (start)
  return function (end_)
    local step = start > end_ and -1 or 1
    local result = {}
    local n = 1
    for i = start, end_, step do
      result[n] = i
      n = n + 1
    end

    result[n] = i
    return result
  end
end

Data_Array.replicate = function (n)
  return function (v)
    if (n < 1) then return {} end
    local r = {}
    for i = 1, n do
      r[i] = v
    end
    return r
  end
end

//------------------------------------------------------------------------------
// Array size ------------------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array.length = function (xs)
  return #xs
end

//------------------------------------------------------------------------------
// Extending arrays ------------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array.cons = function (e)
  return function (l)
    return concatTbl({e}, l)
  end
end

Data_Array.snoc = function (l)
  return function (e)
    return concatTbl(l, {e})
  end
end

//------------------------------------------------------------------------------
// Non-indexed reads -----------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array["uncons'"] = function (empty)
  return function (next)
    return function (xs)
      return xs.length == 0 and empty({}) or next(xs[0])(sliceTbl(xs,1))
    end
  end
end

//------------------------------------------------------------------------------
// Indexed operations ----------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array.indexImpl = function (just)
  return function (nothing)
    return function (xs)
      return function (i)
        return i < 0 or i >= #xs and nothing or just(xs[i+1])
      end
    end
  end
end

Data_Array.findIndexImpl = function (just)
  return function (nothing)
    return function (f)
      return function (xs)
        local l = #xs
        for i = 0, l do
          if f(xs[i+1]) then return just(i) end
        end
        return nothing
      end
    end
  end
end

Data_Array.findLastIndexImpl = function (just)
  return function (nothing)
    return function (f)
      return function (xs)
        for i = (#xs - 1), 0, -1 do
          if f(xs[i+1]) then return just(i) end
        end
        return nothing
      end
    end
  end
end

Data_Array._insertAt = function (just)
  return function (nothing)
    return function (i)
      return function (a)
        return function (l)
          if i < 0 or i > #l then return nothing end
          local l1 = copyTbl(l)
          table.insert(l1, i, a)
          return just(l1)
        end
      end
    end
  end
end

Data_Array._deleteAt = function (just)
  return function (nothing)
    return function (i)
      return function (l)
        if i < 0 or i >= #l then return nothing end
        local l1 = copyTbl(l)
        table.remove(l1, i)
        return just(l1)
      end
    end
  end
end

Data_Array._updateAt = function (just)
  return function (nothing)
    return function (i)
      return function (a)
        return function (l)
          if i < 0 || i >= l.length then return nothing end
          local l1 = copyTbl(l)
          l1[i] = a
          return just(l1)
        end
      end
    end
  end
end

//------------------------------------------------------------------------------
// Transformations -------------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array.reverse = function (l)
  local result = {}
  local n = 1
  for i = #tbl, 1, -1 do
    result[n] = tbl[i]
    n = n + 1
  end
  return result
end

Data_Array.concat = function (xss)
  local result = {}
  local l = #xss
  for i=0, l do
    local xs = xss[i+1]
    local m = #xs
    for j = 0, m do
      result[#result+1] = xs[j+1]
    end
  end
  return result
end

Data_Array.filter = function (f)
  return function (xs)
    return xs.filter(f)
  end
end

Data_Array.partition = function (f)
  return function (xs)
    local yes = {}
    local no  = {}
    for var i = 0, i < #xs do
      local x = xs[i+1]
      if f(x) then
        yes[#yes+1] = x
      else
        no[#no+1] = x
      end
    end
    return { yes = yes, no = no }
  end
end

//------------------------------------------------------------------------------
// Sorting ---------------------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array.sortImpl = function (f)
  return function (l)
    local result = copyTbl(l)
    table.sort(result, function(x,y)
      local c = f(x)(y)
      return c ~= 1
    end)
  end
end

//------------------------------------------------------------------------------
// Subarrays -------------------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array.slice = function (s)
  return function (e)
    return function (l)
      return sliceTbl(l, s, e)
    end
  end
end

Data_Array.drop = function (n)
  return function (l)
    return n < 1 and l or sliceTbl(l, n)
  end
end

//------------------------------------------------------------------------------
// Zipping ---------------------------------------------------------------------
//------------------------------------------------------------------------------

Data_Array.zipWith = function (f)
  return function (xs)
    return function (ys)
      local l = #xs < #ys and #xs or #ys
      local result = {}
      for i = 0, l do
        result[i+1] = f(xs[i+1])(ys[i+1])
      end
      return result
    end
  end
end

local function copyTbl(tbl)
  local result = {}
  for i = 1, #tbl do
    result[i] = tbl[i]
  end
  return result
end

local function concatTbl(t1, t2)
  local result = {}
  local n = 1
  for i=1, #t1 do
    result[n] = t1[i]
    n = n + 1
  end
  for i=1, #t2 do
    result[n] = t2[i]
    n = n + 1
  end
  return result
end

local function sliceTbl(tbl, start, end_)
  if #tbl == 0 then return {} end

  local ent = end_ and end_ or #tbl
  local strt = start and start or 1
  local result = {}
  local n = 1
  for i=strt+1, ent do
    result[n] = tbl[i]
    n = n + 1
  end
  return result
end

local function spliceTbl(tbl, pos, stuff)
  for i = 1, #stuff do
    table.insert(tbl, pos+1, stuff[i])
  end
end

return Data_Array
