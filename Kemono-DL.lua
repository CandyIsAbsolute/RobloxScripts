
local contents = game:HttpGet(tostring(_G.user))

if not isfolder("Downloads") then
    makefolder("Downloads")
end

warn("Lol. . ")
for _,v in next, contents:split(" ") do
    if v:match("/post/") then
        v = v:gsub('href="', "")
        v = v:gsub('"', "")
        v = v:gsub("\n", "")
        local post_contents = game:HttpGet("https://kemono.party"..v)
        num = 1
        for _,v in next, post_contents:split(" ") do
            if v:match(".png") or v:match(".mp4") or v:match(".gif") then
                if v:match("href=") then
                    local title = string.gmatch(post_contents, "<title>.+</title>")()
                    local file_extension = v:match(".png") or v:match(".mp4") or v:match(".gif")
                    title = title:gsub("<title>", "")
                    title = title:gsub("</title>", "")
                    title = title:gsub("%p", "")
                    title = title:gsub(" ", "")
                    title = title:gsub("%s", "")

                    v = v:gsub('href="', "")
                    v = v:gsub('"', "")
                    v = v:gsub("\n", "")
                    v = v:gsub(">", "")
                    v = "https://kemono.party"..v   
                    writefile("Downloads/"..title..num..file_extension, game:HttpGet(v))
                    num += 1
                end
            end
        end
        num = 0
    end
end
