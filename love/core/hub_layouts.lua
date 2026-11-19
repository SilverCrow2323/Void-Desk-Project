-- Per-node dashboard compositions. Each scene keeps the shared action lifecycle
-- but gets a layout that fits the way its tools are used.
local font = require("core.font")
local icon = require("core.icon")
local M = {}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function text(value,x,y,w,size,color,align,bold)
    local f=(bold and font.bold or font.regular)(size) or love.graphics.newFont(size)
    love.graphics.setFont(f); C(color or {.9,.94,.98})
    love.graphics.printf(tostring(value or ""),x,y,w,align or "left")
end
local function shell(x,y,w,h,selected,accent,kind,alpha)
    C({.018,.032,.05},.94*alpha); love.graphics.rectangle("fill",x,y,w,h,5,5)
    C(selected and accent or {.14,.22,.31},(selected and .92 or .62)*alpha)
    love.graphics.setLineWidth(selected and 2 or 1)
    love.graphics.rectangle("line",x,y,w,h,5,5)
    if kind=="workshop" then
        C(accent,.18*alpha); love.graphics.rectangle("fill",x+5,y+5,3,h-10)
    elseif kind=="media" then
        C(accent,.28*alpha); love.graphics.line(x+10,y+h-5,x+w-10,y+h-5)
    elseif kind=="toolbox" then
        C(accent,.24*alpha); love.graphics.rectangle("line",x+5,y+5,12,12,2,2)
    elseif kind=="info" then
        C(accent,.28*alpha); love.graphics.line(x+10,y+5,x+10,y+h-5)
    end
end
local function draw_item(item,index,x,y,w,h,selected,accent,kind,alpha,compact)
    shell(x,y,w,h,selected,accent,kind,alpha)
    local sz=compact and 18 or 22
    local ix=x+10; local iy=y+(h-sz)/2
    pcall(icon.draw,item.icon or "info",ix,iy,sz,selected and accent or {.63,.75,.84},{alpha=alpha})
    local tx=ix+sz+9
    local title_h=compact and 9 or 11
    text(item.label or "Untitled",tx,y+(h-20)/2,w-(tx-x)-48,title_h,
        {.92,.95,.98}, "left",true)
    if item.desc and not compact then
        text(item.desc,tx,y+(h-20)/2+13,w-(tx-x)-16,7,{.52,.64,.73},"left")
    end
    local value=item.value or (item.badge and ("["..item.badge.."]")) or "›"
    text(value,x+w-42,y+(h-9)/2,33,8,selected and accent or {.47,.62,.72},"right",true)
end

function M.navigate_grid(cols,action,index,count)
    cols=math.max(1,cols or 1)
    local row=math.floor((index-1)/cols)
    local col=(index-1)%cols
    local target=index
    if action=="left" and col>0 then target=index-1
    elseif action=="right" and col<cols-1 and index<count then target=index+1
    elseif action=="up" and index-cols>=1 then target=index-cols
    elseif action=="down" and index+cols<=count then target=index+cols end
    return target
end

function M.media(_scene,items,selected,r,accent,alpha)
    local gap=8; local hero_h=math.min(56,math.max(46,math.floor(r.height*.31)))
    if items[1] then
        shell(r.x,r.y,r.width,hero_h,selected==1,accent,"media",alpha)
        pcall(icon.draw,items[1].icon or "music",r.x+14,r.y+12,30,accent,{alpha=alpha})
        text("FEATURED CHANNEL",r.x+56,r.y+8,r.width-70,7,{.58,.72,.82},"left",true)
        text(items[1].label,r.x+56,r.y+21,r.width-70,13,{.95,.94,1},"left",true)
        text(items[1].desc or "",r.x+56,r.y+39,r.width-70,7,{.63,.72,.82})
        text(items[1].value or "OPEN",r.x+r.width-62,r.y+8,48,7,accent,"right",true)
    end
    local count=math.max(0,#items-1); local cols=2
    local top=r.y+hero_h+gap; local rows=math.max(1,math.ceil(count/cols))
    local h=math.max(30,(r.y+r.height-top-gap*(rows-1))/rows)
    for i=2,#items do
        local n=i-2; local col=n%2; local row=math.floor(n/2)
        draw_item(items[i],i,r.x+col*(r.width/2+gap/2),top+row*(h+gap),
            r.width/2-gap/2,h,selected==i,accent,"media",alpha,true)
    end
    return true
end

function M.workshop(_scene,items,selected,r,accent,alpha)
    local cols=2; local gap=8; local rows=math.max(1,math.ceil(#items/cols))
    local w=(r.width-gap)/cols; local h=(r.height-gap*(rows-1))/rows
    for i,item in ipairs(items) do
        local col=(i-1)%cols; local row=math.floor((i-1)/cols)
        draw_item(item,i,r.x+col*(w+gap),r.y+row*(h+gap),w,h,
            selected==i,accent,"workshop",alpha,false)
    end
    return true
end

function M.toolbox(_scene,items,selected,r,accent,alpha)
    local cols=3; local gap=7; local rows=math.max(1,math.ceil(#items/cols))
    local w=(r.width-gap*(cols-1))/cols; local h=(r.height-gap*(rows-1))/rows
    for i,item in ipairs(items) do
        local col=(i-1)%cols; local row=math.floor((i-1)/cols)
        local x=r.x+col*(w+gap); local y=r.y+row*(h+gap)
        shell(x,y,w,h,selected==i,accent,"toolbox",alpha)
        pcall(icon.draw,item.icon or "gear",x+w/2-12,y+7,24,
            selected==i and accent or {.62,.78,.68},{alpha=alpha})
        text(item.label or "Tool",x+4,y+37,w-8,8,{.92,.95,.96},"center",true)
        local sub=item.value or item.badge or "OPEN"
        text(sub,x+4,y+h-15,w-8,6,selected==i and accent or {.48,.65,.57},"center")
    end
    return true
end

function M.settings(_scene,items,selected,r,accent,alpha)
    local gap=10; local rail_w=math.floor(r.width*.40); local detail_x=r.x+rail_w+gap
    local row_h=math.min(22,(r.height-5)/math.max(1,#items))
    C({.014,.027,.042},.96*alpha); love.graphics.rectangle("fill",r.x,r.y,rail_w,r.height,5,5)
    C(accent,.36*alpha); love.graphics.rectangle("line",r.x,r.y,rail_w,r.height,5,5)
    for i,item in ipairs(items) do
        local y=r.y+3+(i-1)*row_h
        if selected==i then
            C(accent,.15*alpha); love.graphics.rectangle("fill",r.x+4,y,rail_w-8,row_h-1,3,3)
            C(accent,.8*alpha); love.graphics.rectangle("fill",r.x+4,y,2,row_h-1)
        end
        text(item.label or "Setting",r.x+12,y+5,rail_w-22,7,
            selected==i and accent or {.75,.82,.89},"left",selected==i)
    end
    local h=r.height
    shell(detail_x,r.y,r.width-rail_w-gap,h,true,accent,"settings",alpha)
    local item=items[selected] or {}
    pcall(icon.draw,item.icon or "gear",detail_x+15,r.y+13,32,accent,{alpha=alpha})
    text("CONFIGURATION ITEM",detail_x+58,r.y+15,r.width-rail_w-86,7,{.54,.68,.78},"left",true)
    text(item.label or "Setting",detail_x+16,r.y+58,r.width-rail_w-32,12,{.94,.96,.99},"left",true)
    text(item.desc or "No additional description.",detail_x+16,r.y+82,r.width-rail_w-32,8,{.64,.74,.82})
    local value=item.value or item.badge or "PRESS A TO APPLY"
    C(accent,.12*alpha); love.graphics.rectangle("fill",detail_x+14,r.y+h-40,r.width-rail_w-gap-28,25,4,4)
    text(value,detail_x+20,r.y+h-33,r.width-rail_w-gap-40,8,accent,"center",true)
    return true
end

function M.info(_scene,items,selected,r,accent,alpha)
    local cols=3; local gap=7; local rows=math.max(1,math.ceil(#items/cols))
    local w=(r.width-gap*(cols-1))/cols; local h=(r.height-gap*(rows-1))/rows
    for i,item in ipairs(items) do
        local col=(i-1)%cols; local row=math.floor((i-1)/cols)
        local x=r.x+col*(w+gap); local y=r.y+row*(h+gap)
        shell(x,y,w,h,selected==i,accent,"info",alpha)
        text(string.format("%02d  /  ARCHIVE",i),x+17,y+7,w-24,6,
            selected==i and accent or {.48,.58,.68},"left",true)
        text(item.label or "Entry",x+17,y+20,w-24,8,{.93,.95,.98},"left",true)
        local desc=item.desc or item.value or "Open archive entry"
        text(desc,x+17,y+34,w-27,6,{.56,.66,.75},"left")
    end
    return true
end

return M
