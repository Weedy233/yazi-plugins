--- @since 25.5.31

local AVAILABLE_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."

local changed = ya.sync(function(st, new)
	local b = st.last ~= new
	st.last = new
	return b or not cx.active.finder
end)

local state = ya.sync(function(st)
	return st.case_sensitive
end)

local setup = ya.sync(function(st, ...)
	local args = { ... }
	-- Support `require("jump-to-char"):setup(opts)` (colon)
	-- and `require("jump-to-char").setup(opts)` (dot)
	local opts = args[1]
	if #args > 1 or (type(opts) == "table" and opts.setup) then
		opts = args[2]
	end

	if opts and opts.case_sensitive ~= nil then
		st.case_sensitive = opts.case_sensitive
	end
end)

local escape = function(s)
	return s == "." and "\\." or s
end

local function entry()
	local cands = {}
	for i = 1, #AVAILABLE_CHARS do
		cands[#cands + 1] = { on = AVAILABLE_CHARS:sub(i, i) }
	end

	local idx = ya.which { cands = cands, silent = true }
	if not idx then
		return
	end

	local char = cands[idx].on
	local kw = escape(char)

	if state() ~= true and char:match("%a") then
		kw = "[" .. char:lower() .. char:upper() .. "]"
	end

	if changed(kw) then
		ya.emit("find_do", { "^" .. kw })
	else
		ya.emit("find_arrow", {})
	end
end

return { setup = setup, entry = entry }
