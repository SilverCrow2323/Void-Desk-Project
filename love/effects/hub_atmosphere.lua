-- Unique animated atmospheres for the remaining NEXUS hubs.
local M={}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function grid(W,H,t,color,a,step)
 step=step or 36
 for x=0,W,step do C(color,.055*a); love.graphics.line(x,0,x,H) end
 for y=0,H,step do C(color,.055*a); love.graphics.line(0,y,W,y) end
 for i=1,24 do
  local x=(i*67+math.sin(t*.4+i)*17)%W
  local y=(i*43+math.cos(t*.35+i)*13)%H
  C(color,(.10+.08*math.sin(t+i))*a); love.graphics.circle("fill",x,y,1.2)
 end
end
local function media(W,H,t,c,a)
 grid(W,H,t,c,a,42)
 local cx,cy=W*.78,H*.36
 for k=1,5 do
  C(c,(.10+.025*k)*a); love.graphics.setLineWidth(2)
  love.graphics.circle("line",cx,cy,18+k*13)
 end
 local rot=t*.55
 C(c,.22*a); love.graphics.circle("fill",cx,cy,73)
 C({.025,.018,.04},.9*a); love.graphics.circle("fill",cx,cy,66)
 C(c,.23*a)
 for k=1,12 do
  local ang=rot+k*math.pi/6
  love.graphics.line(cx+math.cos(ang)*8,cy+math.sin(ang)*8,
                     cx+math.cos(ang)*62,cy+math.sin(ang)*62)
 end
 C(c,.55*a); love.graphics.circle("fill",cx,cy,8)
 for i=0,44 do
  local x=i*(W/44); local v=math.sin(i*.47+t*2)*math.sin(i*.13+t*.8)
  local h=9+math.abs(v)*35
  C(c,(.08+math.abs(v)*.15)*a); love.graphics.rectangle("fill",x,H*.74-h,W/44-2,h*2,1,1)
 end
end
local function workshop(W,H,t,c,a)
 grid(W,H,t,c,a,30)
 local function gear(cx,cy,r,teeth,rot,scale)
  C(c,.12*a); love.graphics.circle("fill",cx,cy,r*.77)
  C(c,.30*a); love.graphics.setLineWidth(2)
  love.graphics.circle("line",cx,cy,r*.68)
  love.graphics.circle("line",cx,cy,r*.40)
  for i=0,teeth-1 do
   local an=rot+i*math.pi*2/teeth
   local x1,y1=cx+math.cos(an)*r*.68,cy+math.sin(an)*r*.68
   local x2,y2=cx+math.cos(an)*r,cy+math.sin(an)*r
   love.graphics.line(x1,y1,x2,y2)
   love.graphics.circle("fill",x2,y2,2*scale)
  end
  C(c,.24*a); love.graphics.circle("line",cx,cy,r*.17)
 end
 gear(W*.75,H*.36,76,12,t*.35,1)
 gear(W*.9,H*.62,42,10,-t*.48,.7)
 gear(W*.57,H*.68,31,8,t*.62,.6)
 for i=1,16 do
  local x=(i*79+t*(8+i%3*4))%W; local y=(i*31+math.sin(t+i)*13)%H
  C(c,.36*a); love.graphics.circle("fill",x,y,1.4)
 end
end
local function toolbox(W,H,t,c,a)
 grid(W,H,t,c,a,24)
 for row=0,4 do for col=0,8 do
  local x=col*W/8; local y=row*H/4
  local pulse=.08+.08*(.5+.5*math.sin(t*1.8+row*2+col))
  C(c,pulse*a); love.graphics.rectangle("line",x+3,y+3,W/8-6,H/4-6,2,2)
 end end
 local cx=W*.77+math.sin(t*.5)*22; local cy=H*.43+math.cos(t*.65)*17
 C(c,.24*a); love.graphics.circle("line",cx,cy,68)
 C(c,.36*a); love.graphics.rectangle("line",cx-40,cy-40,80,80,5,5)
 love.graphics.line(cx-52,cy,cx+52,cy); love.graphics.line(cx,cy-52,cx,cy+52)
 C(c,.42*a); love.graphics.circle("fill",cx,cy,3)
end
local function settings(W,H,t,c,a)
 grid(W,H,t,c,a,32)
 for i=1,9 do
  local x=(i*89)%W; local y=(i*51)%H
  local side=(i%2==0) and 1 or -1
  C(c,.15*a); love.graphics.line(x,y,x+side*32,y)
  love.graphics.line(x+side*32,y,x+side*32,y+24)
  C(c,(.22+.12*math.sin(t*2+i))*a); love.graphics.circle("fill",x+side*32,y+24,2.4)
 end
 local cx,cy=W*.78,H*.38
 for k=1,4 do
  C(c,.10*a); love.graphics.circle("line",cx,cy,30+k*20)
 end
 C(c,.25*a); love.graphics.circle("line",cx,cy,25+math.sin(t*2)*4)
end
local function info(W,H,t,c,a)
 for i=1,50 do
  local x=(i*137+math.sin(t*.25+i)*15)%W
  local y=(i*71+math.cos(t*.22+i)*15)%H
  local tw=.12+.18*(.5+.5*math.sin(t+i*.8))
  C(c,tw*a); love.graphics.circle("fill",x,y,1+(i%3)*.25)
 end
 local cx,cy=W*.77,H*.39
 C(c,.10*a); love.graphics.rectangle("fill",cx-62,cy-76,124,152,3,3)
 C(c,.24*a); love.graphics.rectangle("line",cx-62,cy-76,124,152,3,3)
 love.graphics.line(cx,cy-74,cx,cy+74)
 for i=0,6 do
  C(c,.12*a); love.graphics.line(cx-48,cy-49+i*15,cx-8,cy-49+i*15)
  love.graphics.line(cx+9,cy-49+i*15,cx+48,cy-49+i*15)
 end
 for i=1,5 do
  local ang=t*.1+i*math.pi*2/5
  C(c,.25*a); love.graphics.circle("line",W*.5+math.cos(ang)*(72+i*13),H*.52+math.sin(ang)*(45+i*8),2)
 end
end
M.MODES={media=media,workshop=workshop,toolbox=toolbox,settings=settings,info=info}
function M.draw(W,H,t,mode,color,alpha)
 alpha=alpha or 1
 love.graphics.clear(.008,.012,.024,1)
 local fn=M.MODES[mode] or grid
 fn(W,H,t,color or {.5,.6,.8},alpha)
 love.graphics.setColor(1,1,1,1)
end
return M