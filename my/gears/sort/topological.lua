local a={}local b=require("my.gears.table")local c={__index=a}local function d(self,e)if not self._edges[e]then self._edges[e]={}end end;function a:append(e,f)d(self,e)for g,h in ipairs(f)do d(self,h)self._edges[e][h]=true end end;function a:prepend(e,i)for g,h in ipairs(i)do self:append(h,{e})end end;local j,k=1,2;local function l(m,self,n,e)if n[e]==k then return end;if n[e]==j then m.BAD=e;return true end;n[e]=j;for h in pairs(self._edges[e])do if l(m,self,n,h)then return true end end;n[e]=k;table.insert(m,e)end;function a:clone()local o=a.topological()o._edges=b.clone(self._edges,false)return o end;function a:remove(e)self._edges[e]=nil;for g,p in pairs(self._edges)do p[e]=nil end end;function a:sort()local m,n={},{}for e in pairs(self._edges)do if l(m,self,n,e)then return nil,m.BAD end end;return m end;function a.topological()return setmetatable({_edges={}},c)end;return setmetatable(a,{__call=function(g,...)return a.topological(...)end})