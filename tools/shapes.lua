local a=require("gears").shape local b={}
b.start_left_powerline=function(c,d,e)return a.transform(a.rectangular_tag)(c,d,e)end
b.start_right_powerline=function(c,d,e)return a.transform(a.rectangular_tag):rotate_at(d/2,e/2,math.pi)(c,d,e)end
b.finish_left_powerline=function(c,d,e)return a.transform(a.rectangular_tag):rotate_at(d/2,e/2,math.pi)(c,d,e,-e/2)end
b.finish_right_powerline=function(c,d,e)return a.transform(a.rectangular_tag)(c,d,e,-e/2)end
b.leftpowerline=function(c,d,e)return a.transform(a.powerline):rotate_at(d/2,e/2,math.pi)(c,d,e)end
b.double_trapeze=function(c,d,e)c:move_to(0,0)c:line_to(d,0)c:line_to(d-e/2,e/2)c:line_to(d,e)c:line_to(0,e)c:line_to(e/2,e/2)c:close_path()end
b.client_shape=function(c,d,e)c:move_to(0,0+20)c:line_to(d-160,0+20) c:line_to(d-160,0) c:line_to(d,0)c:line_to(d,e)c:line_to(0,e)c:close_path()end
--[[
b.client_shape=function(c,d,e)
radius = 5

	c:move_to(0,0+20+ radius)
c:arc(radius,radius+20,radius,math.pi,3*(math.pi/2))
c:line_to(d-160,0+20)

    c:arc( d-(160-radius), 20-radius, radius,    math.pi*2 ,    math.pi/2  )
c:arc(d-(150-radius),radius,radius,math.pi,3*(math.pi/2))


    c:arc( d-radius, radius       , radius, 3*(math.pi/2),    math.pi*2  )
    c:arc( d-radius, e-radius, radius,    math.pi*2 ,    math.pi/2  )
    c:arc( radius      , e-radius, radius,    math.pi/2 ,    math.pi    )
c:close_path()end
--]]
return b
