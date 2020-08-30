local a=require("my.gears.matrix")local b=require("my.gears.protected_call")local c=require("lgi").cairo;local d=require("my.wibox.widget.base")local e=d.no_parent_I_know_what_I_am_doing;local f={}local g=setmetatable({},{__mode="k"})function f.count_widget(h)g[h]=true end;local function i(j,k,l)local m={_matrix=a.identity,_matrix_to_device=a.identity,_need_update=true,_widget=nil,_context=nil,_redraw_callback=j,_layout_callback=k,_callback_arg=l,_size={width=nil,height=nil},_draw_extents={x=0,y=0,width=0,height=0},_parent=nil,_children={},_widget_counts={}}function m._redraw()j(m,l)end;function m._layout()local n=m;while n do n._need_update=true;n=n._parent end;k(m,l)end;function m._emit_recursive(h,o,...)local p=m;assert(h==p._widget)while p do if p._widget then p._widget:emit_signal(o,...)end;p=p._parent end end;for q,r in pairs(f)do if type(r)=="function"then m[q]=r end end;return m end;local s;function s(self,t,h,u,v,w,x,y)if not self._need_update and self._widget==h and self._context==t and self._size.width==u and self._size.height==v and a.equals(self._matrix,x)and a.equals(self._matrix_to_device,y)then return end;self._need_update=false;local z,A,B,C;local D=self._widget;if self._size.width and self._size.height then local E,F,G,n=a.transform_rectangle(self._matrix_to_device,0,0,self._size.width,self._size.height)z,A=math.floor(E),math.floor(F)B,C=math.ceil(E+G)-z,math.ceil(F+n)-A else z,A,B,C=0,0,0,0 end;if D and D~=h then self._widget:disconnect_signal("widget::redraw_needed",self._redraw)self._widget:disconnect_signal("widget::layout_changed",self._layout)self._widget:disconnect_signal("widget::emit_recursive",self._emit_recursive)end;self._widget=h;self._context=t;self._size.width=u;self._size.height=v;self._matrix=x;self._matrix_to_device=y;if D~=h then h:weak_connect_signal("widget::redraw_needed",self._redraw)h:weak_connect_signal("widget::layout_changed",self._layout)h:weak_connect_signal("widget::emit_recursive",self._emit_recursive)end;local H=self._children;local I=d.layout_widget(e,t,h,u,v)self._children={}for J,G in ipairs(I or{})do local K=table.remove(H,1)if not K then K=i(self._redraw_callback,self._layout_callback,self._callback_arg)K._parent=self end;s(K,t,G._widget,G._width,G._height,w,G._matrix,G._matrix*y)table.insert(self._children,K)end;local L,M,N,O=0,0,u,v;for J,n in ipairs(self._children)do local P,Q,R,S=a.transform_rectangle(n._matrix,n:get_draw_extents())L=math.min(L,P)M=math.min(M,Q)N=math.max(N,P+R)O=math.max(O,Q+S)end;self._draw_extents={x=L,y=M,width=N-L,height=O-M}self._widget_counts={}if g[h]and u>0 and v>0 then self._widget_counts[h]=1 end;for J,n in ipairs(self._children)do for G,T in pairs(n._widget_counts)do self._widget_counts[G]=(self._widget_counts[G]or 0)+T end end;for J,U in ipairs(H)do local E,F,G,n=a.transform_rectangle(U._matrix_to_device,U:get_draw_extents())w:union_rectangle(c.RectangleInt{x=E,y=F,width=G,height=n})U._parent=nil end;local E,F,G,n=a.transform_rectangle(self._matrix_to_device,0,0,self._size.width,self._size.height)local V,W=math.floor(E),math.floor(F)local X,Y=math.ceil(E+G)-V,math.ceil(F+n)-W;if V~=z or W~=A or X~=B or Y~=C or h~=D then w:union_rectangle(c.RectangleInt{x=z,y=A,width=B,height=C})w:union_rectangle(c.RectangleInt{x=V,y=W,width=X,height=Y})end end;function f.new(t,h,u,v,j,k,l)local m=i(j,k,l)m:update(t,h,u,v)return m end;function f:update(t,h,u,v,w)w=w or c.Region.create()s(self,t,h,u,v,w,self._matrix,self._matrix_to_device)return w end;function f:get_widget()return self._widget end;function f:get_matrix_to_parent()return self._matrix end;function f:get_matrix_to_device()return self._matrix_to_device end;function f:get_matrix_from_parent()local Z=self:get_matrix_to_parent()return Z:invert()end;function f:get_matrix_from_device()local Z=self:get_matrix_to_device()return Z:invert()end;function f:get_draw_extents()local _=self._draw_extents;return _.x,_.y,_.width,_.height end;function f:get_size()local _=self._size;return _.width,_.height end;function f:get_children()return self._children end;function f:get_count(h)return self._widget_counts[h]or 0 end;local function a0(a1)local L,M,N,O=a1:clip_extents()return N-L==0 or O-M==0 end;function f:draw(t,a1)local h=self:get_widget()if not h._private.visible then return end;a1:save()a1:transform(self:get_matrix_to_parent():to_cairo_matrix())a1:rectangle(self:get_draw_extents())a1:clip()if not a0(a1)then local a2=h:get_opacity()local function a3(a4,a5,a6)if not a4 then return end;if not a6 then b(a4,h,t,a1,self:get_size())else b(a4,h,t,a5,a6,a1,self:get_size())end end;if a2~=1 then a1:push_group()end;a1:save()a1:rectangle(0,0,self:get_size())a1:clip()a3(h.draw)a1:restore()a1:new_path()a3(h.before_draw_children)for a7,a8 in ipairs(self:get_children())do a3(h.before_draw_child,a7,a8:get_widget())a8:draw(t,a1)a3(h.after_draw_child,a7,a8:get_widget())end;a3(h.after_draw_children)a1:new_path()if a2~=1 then a1:pop_group_to_source()a1.operator=c.Operator.OVER;a1:paint_with_alpha(a2)end end;a1:restore()end;return f
