local a={}local b={awesome=awesome,root=root,screen=screen}local c=require("my.beautiful")local d=require("my.wibox.widget.base")local e=require("lgi").cairo;local f=require("my.gears.color")local g=require("my.gears.object")local h=require("my.gears.surface")local i=require("my.gears.timer")local j=require("my.gears.geometry").rectangle;local k=require("my.gears.matrix")local l=require("my.wibox.hierarchy")local unpack=unpack or table.unpack;local m={}local n;local function o(self)local p=self.drawable:geometry()local q=self._forced_screen;if not q then local r={}for s in b.screen do r[s]=s.geometry end;q=j.get_by_coord(r,p.x,p.y)or b.screen.primary end;local t=self._widget_context;local u=q and q.dpi or 96;if not t or t.screen~=q or t.dpi~=u then t={screen=q,dpi=u,drawable=self}for v,w in pairs(self._widget_context_skeleton)do t[v]=w end;self._widget_context=t;self._need_complete_repaint=true end;return t end;local function x(self)if not self.drawable.valid then return end;if self._forced_screen and not self._forced_screen.valid then return end;local y=h.load_silently(self.drawable.surface,false)if not y then return end;local z=e.Context(y)local p=self.drawable:geometry()local A,B,C,D=p.x,p.y,p.width,p.height;local t=o(self)if self._need_relayout or self._need_complete_repaint then self._need_relayout=false;if self._widget_hierarchy and self._widget then local E=n and self._widget_hierarchy:get_count(n)>0;self._widget_hierarchy:update(t,self._widget,C,D,self._dirty_area)local F=n and self._widget_hierarchy:get_count(n)>0;if E and not F then n:_kickout(t)end else self._need_complete_repaint=true;if self._widget then self._widget_hierarchy_callback_arg={}self._widget_hierarchy=l.new(t,self._widget,C,D,self._redraw_callback,self._layout_callback,self._widget_hierarchy_callback_arg)else self._widget_hierarchy=nil end end;if self._need_complete_repaint then self._need_complete_repaint=false;self._dirty_area:union_rectangle(e.RectangleInt{x=0,y=0,width=C,height=D})end end;if self._dirty_area:is_empty()then return end;for G=0,self._dirty_area:num_rectangles()-1 do local H=self._dirty_area:get_rectangle(G)z:rectangle(H.x,H.y,H.width,H.height)end;self._dirty_area=e.Region.create()z:clip()z:save()if not b.awesome.composite_manager_running then local I=h.load_silently(b.root.wallpaper(),false)z.operator=e.Operator.SOURCE;if I then z:set_source_surface(I,-A,-B)else z:set_source_rgb(0,0,0)end;z:paint()z.operator=e.Operator.OVER else z.operator=e.Operator.SOURCE end;z:set_source(self.background_color)z:paint()z:restore()if self.background_image then z:save()if type(self.background_image)=="function"then self.background_image(t,z,C,D,unpack(self.background_image_args))else local J=e.Pattern.create_for_surface(self.background_image)z:set_source(J)z:paint()end;z:restore()end;if self._widget_hierarchy then z:set_source(self.foreground_color)self._widget_hierarchy:draw(t,z)end;self.drawable:refresh()assert(z.status=="SUCCESS","Cairo context entered error state: "..z.status)end;local function K(L,M,N,A,B)local O=N:get_matrix_from_device()local P,Q=O:transform_point(A,B)local R,S,T,U=N:get_draw_extents()if P<R or P>=R+T then return end;if Q<S or Q>=S+U then return end;local C,D=N:get_size()if P>=0 and Q>=0 and P<=C and Q<=D then local V,W,X,Y=k.transform_rectangle(N:get_matrix_to_device(),0,0,C,D)table.insert(M,{x=V,y=W,width=X,height=Y,widget_width=C,widget_height=D,drawable=L,widget=N:get_widget(),hierarchy=N})end;for Z,_ in ipairs(N:get_children())do K(L,M,_,A,B)end end;function a:find_widgets(A,B)local M={}if self._widget_hierarchy then K(self,M,self._widget_hierarchy,A,B)end;return M end;function a._set_systray_widget(a0)l.count_widget(a0)n=a0 end;function a:set_widget(a0)self._widget=d.make_widget_from_value(a0)self._need_relayout=true;self.draw()end;function a:get_widget()return rawget(self,"_widget")end;function a:set_bg(a1)a1=a1 or"#000000"local a2=type(a1)if a2=="string"or a2=="table"then a1=f(a1)end;local a3=not f.create_opaque_pattern(a1)if self._redraw_on_move~=a3 then self._redraw_on_move=a3;if a3 then self.drawable:connect_signal("property::x",self._do_complete_repaint)self.drawable:connect_signal("property::y",self._do_complete_repaint)else self.drawable:disconnect_signal("property::x",self._do_complete_repaint)self.drawable:disconnect_signal("property::y",self._do_complete_repaint)end end;self.background_color=a1;self._do_complete_repaint()end;function a:set_bgimage(a4,...)if type(a4)~="function"then a4=h(a4)end;self.background_image=a4;self.background_image_args={...}self._do_complete_repaint()end;function a:set_fg(a1)a1=a1 or"#FFFFFF"if type(a1)=="string"or type(a1)=="table"then a1=f(a1)end;self.foreground_color=a1;self._do_complete_repaint()end;function a:_force_screen(q)self._forced_screen=q end;function a:_inform_visible(a5)self._visible=a5;if a5 then m[self]=true;self:_do_complete_repaint()else m[self]=nil end end;local function a6(a7,a8,a9)local function aa(table,ab)for Z,w in pairs(table)do if w.widget==ab.widget then return true end end;return false end;for Z,w in pairs(a8)do if not aa(a9,w)then w.widget:emit_signal(a7,w)end end end;local function ac(L)a6("mouse::leave",L._widgets_under_mouse,{})L._widgets_under_mouse={}end;local function ad(L,A,B)if A<0 or B<0 or A>L.drawable:geometry().width or B>L.drawable:geometry().height then return ac(L)end;local ae=L:find_widgets(A,B)a6("mouse::leave",L._widgets_under_mouse,ae)a6("mouse::enter",ae,L._widgets_under_mouse)L._widgets_under_mouse=ae end;local function af(L)local ag=L.drawable;local function ah(a7)ag:connect_signal(a7,function(Z,...)L:emit_signal(a7,...)end)end;ah("button::press")ah("button::release")ah("mouse::enter")ah("mouse::leave")ah("mouse::move")ah("property::surface")ah("property::width")ah("property::height")ah("property::x")ah("property::y")end;function a.new(ag,ai,aj)local ak=g()ak.drawable=ag;ak._widget_context_skeleton=ai;ak._need_complete_repaint=true;ak._need_relayout=true;ak._dirty_area=e.Region.create()af(ak)for v,w in pairs(a)do if type(w)=="function"then ak[v]=w end end;ak._redraw_pending=false;ak._do_redraw=function()ak._redraw_pending=false;x(ak)end;ak.draw=function()if not ak._redraw_pending then i.delayed_call(ak._do_redraw)ak._redraw_pending=true end end;ak._do_complete_repaint=function()ak._need_complete_repaint=true;ak:draw()end;ag:connect_signal("property::surface",ak._do_complete_repaint)ag:connect_signal("property::x",ak.draw)ag:connect_signal("property::y",ak.draw)ak._redraw_on_move=false;ak:set_bg(c.bg_normal)ak:set_fg(c.fg_normal)ak._widgets_under_mouse={}ag:connect_signal("mouse::move",function(Z,A,B)ad(ak,A,B)end)ag:connect_signal("mouse::leave",function()ac(ak)end)ak._redraw_callback=function(al,am)if not ak._visible then return end;if ak._widget_hierarchy_callback_arg~=am then return end;local O=al:get_matrix_to_device()local A,B,C,D=k.transform_rectangle(O,al:get_draw_extents())local P,Q=math.floor(A),math.floor(B)local R,S=math.ceil(A+C),math.ceil(B+D)ak._dirty_area:union_rectangle(e.RectangleInt{x=P,y=Q,width=R-P,height=S-Q})ak:draw()end;ak._layout_callback=function(Z,am)if ak._widget_hierarchy_callback_arg~=am then return end;ak._need_relayout=true;if ak._visible then ak:draw()end end;ak.drawable_name=aj or g.modulename(3)local an={}local ao=tostring(ak)an.__tostring=function()return string.format("%s (%s)",ak.drawable_name,ao)end;ak=setmetatable(ak,an)ak._do_complete_repaint()return setmetatable(ak,{__index=function(self,v)if rawget(self,"get_"..v)then return rawget(self,"get_"..v)(self)else return rawget(ak,v)end end,__newindex=function(self,v,w)if rawget(self,"set_"..v)then rawget(self,"set_"..v)(self,w)else rawset(self,v,w)end end})end;b.awesome.connect_signal("wallpaper_changed",function()for ag in pairs(m)do ag:_do_complete_repaint()end end)local function ap()for ag in pairs(m)do ag:draw()end end;screen.connect_signal("property::geometry",ap)screen.connect_signal("added",ap)screen.connect_signal("removed",ap)return setmetatable(a,{__call=function(Z,...)return a.new(...)end})