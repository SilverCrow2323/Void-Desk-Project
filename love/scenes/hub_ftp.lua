local sm=require("core.scene_manager"); local input=require("core.input"); local font=require("core.font"); local icon=require("core.icon"); local bg=require("effects.uplink_bg")
local M={}; local CYAN={.22,.80,.98}; local t=0
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b) local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z); love.graphics.setFont(f); C(c or {.9,.94,.98}); love.graphics.printf(tostring(s or ""),x,y,w,align or "left") end
function M.enter() t=0; input.clear(); input.on("press",function(a) if a=="b" then sm.back() end end) end; function M.leave() input.clear() end; function M.update(dt) t=t+dt end
function M.draw()
 local W,H=love.graphics.getDimensions(); bg.draw(W,H,t,"transfer",CYAN,1); T("UPLINK  /  FILE TRANSFER",14,9,W-28,8,{.38,.83,.97},"left",true); T("FTPiercer",14,24,W-28,21,{.94,.97,1},"left",true)
 C({.02,.055,.08},.96); love.graphics.rectangle("fill",14,72,W-28,206,8,8); C(CYAN,.5); love.graphics.rectangle("line",14,72,W-28,206,8,8); icon.draw("upload",W/2-18,91,36,CYAN); T("FTP CLIENT",25,141,W-50,13,{.94,.97,1},"center",true); T("FRONTEND MIGRATION PENDING",25,166,W-50,9,{1,.69,.38},"center",true); T("FTPiercer is referenced by the legacy Python Uplink menu, but the current LÖVE frontend has no FTP profile or transfer service bridge.",28,196,W-56,9,{.77,.86,.92},"center"); T("This panel is intentionally read-only until profile storage, credential handling and transfer operations are migrated safely.",28,231,W-56,9,{.68,.8,.88},"center")
 C({.018,.042,.064},.94); love.graphics.rectangle("fill",14,292,W-28,82,7,7); C(CYAN,.3); love.graphics.rectangle("line",14,292,W-28,82,7,7); T("PLANNED CONTROL SURFACE",25,303,W-50,8,{.45,.82,.96},"left",true); T("Connection profiles · browse · upload/download queue · transfer log · certificate and credential handling",25,324,W-50,9,{.72,.82,.89})
 T("STATUS  ·  NOT YET CONNECTED TO A TRANSFER BACKEND",12,H-43,W-24,7,{.49,.82,.95},"center",true); T("B BACK",12,H-23,W-24,8,{.72,.87,.95},"center"); love.graphics.setColor(1,1,1,1)
end
return M