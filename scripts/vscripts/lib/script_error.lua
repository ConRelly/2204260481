return function(err)
    local message = type(err) == "table" and rawget(err, "str")
    if type(message) ~= "string" then
        local ok
        ok, message = pcall(tostring, err)
        if not ok then message = "Script raised a " .. type(err) .. " error" end
    end
    return message
end
