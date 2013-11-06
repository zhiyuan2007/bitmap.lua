local bitmap = require 'bitmap'

local function test(caption, fun)
  io.write(string.format("[T] %-30s", caption))
  ok, err = pcall(fun)
  if ok then
    io.write("[OK]\n")
  else
    io.write("[ERR]\n    ! " .. err .. "\n\n")
  end
end

local function must_equal(a, b)
  if a ~= b then
    error("Expected '" .. tostring(b) .. "' but was '" .. tostring(a) .. "'")
  end
end

test("#new & #__gc", function()
  local map = bitmap.new(10000)
  must_equal(type(map), "userdata")

  local ok, err = pcall(bitmap.new)
  must_equal(ok, false)
  must_equal(err, "bad argument #1 to '?' (number expected, got no value)")
end)

test("#fill & #zero", function()
  local map = bitmap.new(100)
  must_equal(map:csv(), "")
  map:fill()
  must_equal(map:csv(), "0-99")
  map:zero()
  must_equal(map:csv(), "")
end)

test("#get & #set & #clear", function()
  local map = bitmap.new(100)
  must_equal(map:csv(), "")
  map:set(60, 8)
  map:set(29, 4)
  must_equal(map:csv(), "29-32,60-67")

  must_equal(map:get(59), false)
  must_equal(map:get(60), true)
  must_equal(map:get(67), true)
  must_equal(map:get(68), false)

  map:set(59, 5)
  must_equal(map:csv(), "29-32,59-67")
  map:clear(63, 2)
  must_equal(map:csv(), "29-32,59-62,65-67")
  map:clear(59, 1):clear(60, 3):set(90, 10)
  must_equal(map:csv(), "29-32,65-67,90-99")

  local ok, err = pcall(map.clear, map, 200, 5)
  must_equal(ok, false)
  must_equal(err, "bad argument #2 (out of bounds)")

  local ok, err = pcall(map.set, map, 98, 3)
  must_equal(ok, false)
  must_equal(err, "bad argument #2 (out of bounds)")

  map:clear(0, 100)
  must_equal(map:empty(), true)
end)

test("#band", function()
  local m1 = bitmap.new(100):set(10, 50):set(95, 2)
  local m2 = bitmap.new(90):set(30, 50)
  local mn = m1:band(m2)
  must_equal(type(mn), "userdata")
  must_equal(m1:csv(), "10-59,95-96")
  must_equal(m2:csv(), "30-79")
  must_equal(mn:csv(), "30-59")
  must_equal(mn:size(), 90)
end)

test("#bor", function()
  local m1 = bitmap.new(100):set(10, 50):set(95, 2)
  local m2 = bitmap.new(90):set(30, 50)
  local mn = m1:bor(m2)
  must_equal(type(mn), "userdata")
  must_equal(mn:csv(), "10-79,95-96")
  must_equal(mn:size(), 100)
end)

test("#bxor", function()
  local m1 = bitmap.new(100):set(10, 50):set(95, 2)
  local m2 = bitmap.new(90):set(30, 50)
  local mn = m1:bxor(m2)
  must_equal(type(mn), "userdata")
  must_equal(mn:csv(), "10-29,60-79,95-96")
  must_equal(mn:size(), 100)
end)

test("#bandnot", function()
  local m1 = bitmap.new(100):set(10, 50):set(95, 2)
  local m2 = bitmap.new(90):set(30, 50)
  local mn = m1:bandnot(m2)
  must_equal(type(mn), "userdata")
  must_equal(mn:csv(), "10-29,95-96")
  must_equal(mn:size(), 100)

  local mo = m2:bandnot(m1)
  must_equal(type(mo), "userdata")
  must_equal(mo:csv(), "60-79")
  must_equal(mo:size(), 90)
end)

test("#bnot", function()
  local m1 = bitmap.new(100):set(10, 50):set(95, 2)
  local mn = m1:bnot()
  must_equal(type(mn), "userdata")
  must_equal(mn:csv(), "0-9,60-94,97-99")
  must_equal(mn:size(), 100)
end)

test("#equal", function()
  local m1 = bitmap.new(10):set(1, 2)
  local m2 = bitmap.new(20):set(1, 2)
  local m3 = bitmap.new(10):set(1, 2)
  local m4 = bitmap.new(10):set(2, 3)
  must_equal(m1:equal(m2), false)
  must_equal(m1:equal(m3), true)
  must_equal(m1:equal(m4), false)
  must_equal(m2:equal(m4), false)
end)

test("#intersects", function()
  local m1 = bitmap.new(10):set(1, 5)
  local m2 = bitmap.new(20):set(4, 10)
  local m3 = bitmap.new(10):set(7, 1)
  local m4 = bitmap.new(10):set(5, 3)
  must_equal(m1:intersects(m2), true)
  must_equal(m1:intersects(m3), false)
  must_equal(m3:intersects(m4), true)
  must_equal(m2:intersects(m4), true)
end)

test("#empty", function()
  local m1 = bitmap.new(10)
  must_equal(m1:empty(), true)
  m1:set(1,1)
  must_equal(m1:empty(), false)
end)

test("#full", function()
  local m1 = bitmap.new(10)
  must_equal(m1:full(), false)
  m1:set(1,9)
  must_equal(m1:full(), false)
  m1:set(0,1)
  must_equal(m1:full(), true)
end)

test("#weight", function()
  local m1 = bitmap.new(10)
  must_equal(m1:weight(), 0)
  m1:set(1,5)
  must_equal(m1:weight(), 5)
  m1:set(7,1)
  must_equal(m1:weight(), 6)
end)
