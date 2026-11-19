local sm=require("core.scene_manager"); local input=require("core.input"); local font=require("core.font"); local icon=require("core.icon"); local bg=require("effects.uplink_bg")
local M={}; local CYAN={.22,.80,.98}; local t=0
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b) local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z); love.graphics.setFont(f); C(c or {.9,.94,.98}); love.graphics.printf(tostring(s or ""),x,y,w,align or "left") end
function M.enter() t=0; input.clear(); input.on("press",function(a) if a=="b" then sm.back() end end) end; function M.leave() input.clear() end; function M.update(dt) t=t+dt end
function M.draw()
 local W,H=love.graphics.getDimensions(); bg.draw(W,H,t,"server",CYAN,1); T("UPLINK  /  PC COMPANION",14,9,W-28,8,{.38,.83,.97},"left",true); T("B.S. SERVER",14,24,W-28,21,{.94,.97,1},"left",true)
 C({.02,.055,.08},.96); love.graphics.rectangle("fill",14,72,W-28,205,8,8); C(CYAN,.5); love.graphics.rectangle("line",14,72,W-28,205,8,8); icon.draw("globe",W/2-18,91,36,CYAN); T("VOID BASESTATION",25,140,W-50,13,{.94,.97,1},"center",true); T("PC-ONLY COMPANION",25,163,W-50,9,{1,.69,.38},"center",true); T("BaseStation currently runs on a Linux PC, not on the handheld.",28,193,W-56,9,{.78,.87,.93},"center"); T("Its embedded daemon is still a prototype. This screen intentionally does not start a server or expose a handheld endpoint.",28,218,W-56,9,{.68,.8,.88},"center")
 C({.018,.042,.064},.94); love.graphics.rectangle("fill",14,291,W-28,93,7,7); C(CYAN,.3); love.graphics.rectangle("line",14,291,W-28,93,7,7); T("COMPANION WORKFLOW",25,302,W-50,8,{.45,.82,.96},"left",true); T("Run VOID BaseStation on a trusted PC and use its PC-side discovery / SSH / SFTP tools. Handheld pairing and authenticated Uplink transport remain separate work.",25,324,W-50,9,{.72,.82,.89})
 T("STATUS  ·  NOT HOSTED ON THIS DEVICE",12,H-43,W-24,8,{.49,.82,.95},"center",true); T("B BACK",12,H-23,W-24,8,{.72,.87,.95},"center"); love.graphics.setColor(1,1,1,1)
end
return M