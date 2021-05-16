function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {} 
    local i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i    = i + 1
    end
    return t
end

--[[去除str中的所有空格。成功返回去除空格后的字符串，失败返回nil和失败信息]]
function string.trim(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    str = string.gsub(str, " ", "")
    return str
end
--[[将str的第一个字符转化为大写字符。成功返回转换后的字符串，失败返回nil和失败信息]]
function string.capitalize(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local ch = string.sub(str, 1, 1)
    local len = string.len(str)
    if ch < 'a' or ch > 'z' then
        return str
    end
    ch = string.char(string.byte(ch) - 32)
    if len == 1 then
        return ch
    else
        return ch .. string.sub(str, 2, len)
    end
end
--[[统计str中substr出现的次数。from, to用于指定起始位置，缺省状态下from为1，to为字符串长度。成功返回统计个数，失败返回nil和失败信息]]
function string.count(str, substr, from, to)
    if str == nil or substr == nil then
        return nil, "the string or the sub-string parameter is nil"
    end
    from = from or 1
    if to == nil or to > string.len(str) then
        to = string.len(str)
    end
    local str_tmp = string.sub(str, from ,to)
    local n = 0
    local _, n = string.gsub(str, substr, '')
    return n
end
--[[判断str是否以substr开头。是返回true，否返回false，失败返回失败信息]]
function string.startswith(str, substr)
    if str == nil or substr == nil then
        return nil, "the string or the sub-stirng parameter is nil"
    end
    if string.find(str, substr) ~= 1 then
        return false
    else
        return true
    end
end
--[[判断str是否以substr结尾。是返回true，否返回false，失败返回失败信息]]
function string.endswith(str, substr)
    if str == nil or substr == nil then
        return nil, "the string or the sub-string parameter is nil"
    end
    local str_tmp = string.reverse(str)
    local substr_tmp = string.reverse(substr)
    if string.find(str_tmp, substr_tmp) ~= 1 then
        return false
    else
        return true
    end
end
--[[使用空格替换str中的制表符，默认空格个数为8。返回替换后的字符串]]
function string.expendtabs(str, n)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    n = n or 8
    str = string.gsub(str, "\t", string.rep(" ", n))
    return str
end
--[[如果str仅由字母或数字组成，则返回true，否则返回false。失败返回nil和失败信息]]
function string.isnumal(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local len = string.len(str)
    for i = 1, len do
        local ch = string.sub(str, i, i)
        if not ((ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or (ch >= '0' and ch <= '9')) then
            return false
        end
    end
    return true
end
--[[如果str全部由字母组成，则返回true，否则返回false。失败返回nil和失败信息]]
function string.isalpha(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local len = string.len(str)
    for i = 1, len do
        local ch = string.sub(str, i, i)
        if not ((ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z')) then
            return false
        end
    end
    return true
end
--[[如果str全部由数字组成，则返回true，否则返回false。失败返回nil和失败信息]]
function string.isdigit(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local len = string.len(str)
    for i = 1, len do
        local ch = string.sub(str, i, i)
        if ch < '0' or ch > '9' then
            return false
        end
    end
    return true
end
--[[如果str全部由小写字母组成，则返回true，否则返回false。失败返回nil和失败信息]]
function string.islower(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local len = string.len(str)
    for i = 1, len do
        local ch = string.sub(str, i, i)
        if ch < 'a' or ch > 'z' then
            return false
        end
    end
    return true
end
--[[如果str全部由大写字母组成，则返回true，否则返回false。失败返回nil和失败信息]]
function string.isupper(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local len = string.len(str)
    for i = 1, len do
        local ch = string.sub(str, i, i)
        if ch < 'A' or ch > 'Z' then
            return false
        end
    end
    return true
end
--[[使用substr连接str中的每个字符，返回连接后的新串。失败返回nil和失败信息]]
function string.join(str, substr)
    if str == nil or substr == nil then
        return nil, "the string or the sub-string parameter is nil"
    end
    local xlen = string.len(str) - 1
    if xlen == 0 then
        return str
    end
    local str_tmp = ""
    for i = 1, xlen do
        str_tmp = str_tmp .. string.sub(str, i, i) .. substr
    end
    str_tmp = str_tmp .. string.sub(str, xlen + 1, xlen + 1)
    return str_tmp
end
--[[将str中的小写字母替换成大写字母，返回替换后的新串。失败返回nil和失败信息]]
function string.lower(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local len = string.len(str)
    local str_tmp = ""
    for i = 1, len do
        local ch = string.sub(str, i, i)
        if ch >= 'A' and ch <= 'Z' then
            ch = string.char(string.byte(ch) + 32)
        end
        str_tmp = str_tmp .. ch
    end
    return str_tmp
end
--[[将str中的大写字母替换成小写字母，返回替换后的新串。失败返回nil和失败信息]]
function string.upper(str)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    local len = string.len(str)
    local str_tmp = ""
    for i = 1, len do
        local ch = string.sub(str, i, i)
        if ch >= 'a' and ch <= 'z' then
            ch = string.char(string.byte(ch) - 32)
        end
        str_tmp = str_tmp .. ch
    end
    return str_tmp
end
--[[将str以substr（从左向右查找）为界限拆分为3部分，返回拆分后的字符串。如果str中无substr则返回str, '', ''。失败返回nil和失败信息]]
function string.partition(str, substr)
    if str == nil or substr == nil then
        return nil, "the string or the sub-string parameter is nil"
    end
    local len = string.len(str)
    local start_idx, end_idx = string.find(str, substr)
    if start_idx == nil or end_idx == len then
        return str, '', ''
    end
    return string.sub(str, 1, start_idx - 1), string.sub(str, start_idx, end_idx), string.sub(str, end_idx + 1, len)
end
--[[在str前面补0，使其总长度达到n。返回补充后的新串，如果str长度已经超过n，则直接返回str。失败返回nil和失败信息]]
function string.zfill(str, n)
    if str == nil then
        return nil, "the string parameter is nil"
    end
    if n == nil then
        return str
    end
    local format_str = "%0" .. n .. "s"
    return string.format(format_str, str)
end





















function string.trim(s)
    return s:match "^%s*(.-)%s*$"
end

function string.pipei(s, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(s, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function string.split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end


function Weightsgetvalue_one_key(wtable,pronum)
    local rtable={}
    local lintable={}
    local endtable={}
    if pronum==0 then
        return endtable
    end
    for k,v in pairs(wtable) do
        lintable[k]=v
    end
    --print("===")
    --PrintTable(lintable)
    for i=1,pronum do
        local num=0
        local weight=0
        local valuetable={}
        for k,v in pairs(lintable) do
            lintable[k]=v
            local cc={}
            if v==0 then
                cc={0,0}
                rtable[k]=cc
            else
                table.insert(cc,weight+1)
                weight=v+weight
                table.insert(cc,weight)
                rtable[k]=cc
            end
        end
        local randomvalue=RandomInt(1, math.max(weight))
        
        for k,v in pairs(rtable) do
            
            if randomvalue>=v[1] and randomvalue<=v[2] then
                num=k
            end
        end
        
        table.insert(endtable,num)
        --lintable[num]=nil

    end
    
   
    return endtable
end
function Weightsgetvalue_one_keyss(wtable,pronum)
    local rtable={}
    local lintable={}
    local endtable={}
    if pronum==0 then
        return endtable
    end
    for k,v in pairs(wtable) do
        lintable[k]=v
    end
    --print("===")
    --PrintTable(lintable)
    for i=1,pronum do
        local num=0
        local weight=0
        local valuetable={}
        for k,v in pairs(lintable) do
            lintable[k]=v
            local cc={}
            if v==0 then
                cc={0,0}
                rtable[k]=cc
            else
                table.insert(cc,weight+1)
                weight=v+weight
                table.insert(cc,weight)
                rtable[k]=cc
            end
        end
        local randomvalue=RandomInt(1, math.max(weight))
        
        for k,v in pairs(rtable) do
            
            if randomvalue>=v[1] and randomvalue<=v[2] then
                num=k
            end
        end
        
        table.insert(endtable,num)
        lintable[num]=nil

    end
    
   
    return endtable
end
function Weightsgetvalue_one_se(wtable)
    local num=0
    local weight=0
    local valuetable={}
    for k,v in pairs(wtable) do
        local cc={}
        if v==0 then
            cc={0,0}
            table.insert(valuetable,cc)
        else
            table.insert(cc,weight+1)
            weight=v+weight
            table.insert(cc,weight)
            table.insert(valuetable,cc)
        end
    end
    if weight==0 then
        return num
    end
    local randomvalue=RandomInt(1, math.max(weight, 100))
    for k,v in pairs(valuetable) do
        
        if randomvalue>=v[1] and randomvalue<=v[2] then
            num=k
        end
        
    end

    return num
end
function table_repeat_no(wtable,num)
    
    local weight=0
    local valuetable={}
    local resulttable={}

    for k,v in pairs(wtable) do
        table.insert(valuetable,v)
    end
    
    for i=1,num do
      
        local randomint=RandomInt(1,#valuetable)
      
        table.insert(resulttable,valuetable[randomint])
        table.remove(valuetable,randomint)
    end
    
    return resulttable
end

function EachPlayer(teamNumber, func)
	if type(teamNumber) == "function" then
		func = teamNumber
		teamNumber = DOTA_TEAM_GOODGUYS
	end
	for n = 1, PlayerResource:GetPlayerCountForTeam(teamNumber), 1 do
		local playerID = PlayerResource:GetNthPlayerIDOnTeam(teamNumber, n)
		if PlayerResource:IsValidPlayerID(playerID) then
			if func(n, playerID) == true then
				break
			end
		end
	end
end

--随机不重复
function RandomNoRepeat(wtable,num)
    local valuetable={}
    local resulttable={}
    
    for k,v in pairs(wtable) do
        table.insert(valuetable,v) 
    end
    
    for i=1,num do
    	if #valuetable == 0 then
    		break;
    	end
       local idx = RandomInt(1,#valuetable);
       table.insert(resulttable,table.remove(valuetable,idx))
    end
   

    return resulttable
end
--字符串分割
function lua_string_split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end