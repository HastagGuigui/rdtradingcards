function string:split(sep)
	local fields = {}
	sep = sep or ":"
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields + 1] = c end)
	return fields
end

function table.shallow_copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

--- Check if a file or directory exists in this path
function fs.exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function fs.isdir(path)
   -- "/" works on both Unix and Windows
   return fs.exists(path.."/")
end

