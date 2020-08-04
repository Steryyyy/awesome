local gears = require("my.gears")
local shape = {}
shape.startn = function(cr, w, h)
        
    return gears.shape.transform(gears.shape.rectangular_tag)    (cr, w, h  )

end
shape.leftstart = function(cr, w, h)
        
    return gears.shape.transform(gears.shape.rectangular_tag)  : rotate_at(w/2,h/2,math.pi)   (cr, w, h  )

end
shape.finishn = function(cr, w, h)
    
    return gears.shape.transform(gears.shape.rectangular_tag) : rotate_at(w/2,h/2,math.pi)  (cr,  w, h,-h/2)

end
shape.leftpowerline = function(cr, w, h)
        
    return gears.shape.transform(gears.shape.powerline) : rotate_at(w/2,h/2,math.pi) (cr, w, h  )

end
shape.tagstart = function(cr, w, h)
    return gears.shape.transform(gears.shape.rectangular_tag)  : rotate_at(w/2,h/2,math.pi)   (cr, w, h  )
end

shape.tagfinish = function(cr, w, h)
    return gears.shape.transform(gears.shape.rectangular_tag)   (cr,  w, h,-h/2)
end
shape.taskdouble   = function(cr,w,h)
    cr:move_to(0+h/2,0)
    cr:line_to(w-h/2,0)
    cr:line_to(w,h/2)
    cr:line_to(w-h/2,h)
    cr:line_to(h/2,h)
    cr:line_to(0,h /2)

    cr:close_path()

  end
  shape.taskend  = function(cr,w,h)
    cr:move_to(0,0)
    cr:line_to(w,0)
    cr:line_to(w-h/2,h/2)
    cr:line_to(w,h)
    cr:line_to(0,h)
    cr:line_to(h/2,h /2)

    cr:close_path()

  end
  shape.taskendright = function(cr,w,h)
    cr:move_to(0,0)
    cr:line_to(w,0)
    cr:line_to(w-h/2,h/2)
    cr:line_to(w,h)
    cr:line_to(0,h)


    cr:close_path()

  end
  shape.taskendleft  = function(cr,w,h)
    cr:move_to(0,0)
    cr:line_to(w,0)
   
    cr:line_to(w,h)
    cr:line_to(0,h)
    cr:line_to(h/2,h /2)

    cr:close_path()

  end
  shape.clockshape = function(cr,w,h)
    cr:move_to(0,0)
    cr:line_to(w,0)
    cr:line_to(w-h/2,h/2)
    cr:line_to(w,h)
    cr:line_to(0,h)
    cr:line_to(h/2,h /2)

    cr:close_path()

  end
  return shape