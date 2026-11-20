-- Run with: luajit tests/test_love_input_map.lua
local input = dofile("love/core/input.lua")

local expected = {
    up = "up", down = "down", left = "left", right = "right",
    ["return"] = "a", a = "a",
    escape = "b", b = "b",
    x = "x", y = "y",
    ["1"] = "l1", ["2"] = "l2", ["3"] = "r2", ["4"] = "r1",
    q = "l3", e = "r3",
    f8 = "select", f9 = "start", m = "menu",
}

for key, action in pairs(expected) do
    assert(input.KEYMAP[key] == action,
        string.format("keyboard key %q should map to %q, got %q",
            key, action, tostring(input.KEYMAP[key])))
end
for key, action in pairs(input.KEYMAP) do
    assert(expected[key] == action,
        string.format("unexpected desktop keyboard binding %q -> %q", key, action))
end

-- The physical controller vocabulary remains unchanged across both frontends.
assert(input.GAMEPAD_NAMES.dpup == "up")
assert(input.GAMEPAD_NAMES.a == "a")
assert(input.GAMEPAD_NAMES.b == "b")
assert(input.GAMEPAD_NAMES.leftshoulder == "l1")
assert(input.GAMEPAD_NAMES.rightshoulder == "r1")
assert(input.GAMEPAD_NAMES.leftstick == "l3")
assert(input.GAMEPAD_NAMES.rightstick == "r3")

print("LÖVE/Pygame desktop keyboard parity: OK")
