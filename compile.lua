local RARPATH=[["C:\Program Files\WinRAR\WinRAR.exe"]]
local LOVEPATH=[["C:\Program Files\LOVE\love.exe"]]
require "lfs"

--local inputPath=[[C:\Users\Alexar\Desktop\celllife]]
--local outputPath=[[C:\Users\Alexar\Desktop\celllife_compile]]

local inputPath=arg[1] or [[C:\Users\Alexar\Desktop\box2d]]
local outputPath=inputPath.."_compile"
lfs.mkdir(outputPath)
function strippath(filename)
         --return string.match(filename, "(.+)/[^/]*%.%w+$") --*nix system
         return string.match(filename, "(.+)\\[^\\]*%.%w+$") --windows
 end
 --获取文件名
 function stripfilename(filename)
         --return string.match(filename, ".+/([^/]*%.%w+)$") -- *nix system
         return string.match(filename, ".+\\([^\\]*%.%w+)$") -- *nix system
 end
 
 function stripextension(filename)
         local idx = filename:match(".+()%.%w+$")
         if(idx) then
                 return filename:sub(1, idx-1)
         else
                 return filename
         end
 end
 
 function getextension(filename)
        return filename:match(".+%.(%w+)$")
 end

  
 function compile(path,output,name)
    os.execute("luajit -b "..path.." "..output..name)
end


function getpathes(rootpath, pathes)
    pathes = pathes or {}
    ret, files, iter = pcall(lfs.dir, rootpath)
    if ret == false then
        return pathes
    end
    for entry in files, iter do
        local next = false
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath .. "\\" .. entry
            local attr = lfs.attributes(path)
            if attr == nil then
                next = true
            end
            if next == false then 
                local output
                local dir=strippath(path)
                if dir then
                    output=outputPath..
                    string.sub(dir,string.len(inputPath)+1,-1).."\\"
                else
                    output=string.sub(path,string.len(inputPath)+1,-1).."\\"
                end
                if attr.mode == 'directory' then
                    lfs.mkdir(outputPath..output)
                    getpathes(path, pathes)
                else
                    local name=stripfilename(path)
                    if name then
                        local ext=getextension(name)
                        if ext=="lua" then 
                            compile(path,output,name) 
                        else
                            os.execute("copy /b \""..path.."\" \""..output..name.."\"")
                        end
                        table.insert(pathes, path)
                    end
                end
            end
        end
        next = false
    end
    return pathes
end

function build()

   os.execute(RARPATH.." a -r -ep1 -afzip "
       ..outputPath.."/game.love".." "..
    outputPath.."/") 
    print("copy /b "..LOVEPATH.." + \""..outputPath.."\\game.love\" \""..   outputPath.."\\game.exe\"")
    os.execute("copy /b "..LOVEPATH.." + \""..outputPath.."\\game.love\" \""..   outputPath.."\\game.exe\"")
 
end

pathes = {}

getpathes(inputPath, pathes)
build()
