--!strict
local tins,tr,tc = table.insert,table.remove,table.clear
local tcancel = task.cancel

export type CleanerType = {
    Holder: {};
    Add: (Entity: any) -> ();
    Destroy: (self: CleanerType) -> ();
    Remove: (self: CleanerType, Entity: any) -> ();
    Clean: (self: CleanerType) -> ();
    Extend: (self: CleanerType) -> CleanerType;
    DestroyAfter: (self: CleanerType, time: number) -> ();
}

local mt = {}
mt.__index = mt;
local module = {
    Delay = function(Entity: any, time: number)
        if Entity == nil then return end;
        task.delay(time,CleanEntity,Entity,typeof(Entity))
    end,
    New = function() : CleanerType
        local Cleaner = {
        } :: CleanerType;
        setmetatable(Cleaner,mt);
        return Cleaner :: any
    end
}
function mt:Connect(Connection: RBXScriptSignal, func: () -> ())
    if Connection ~= nil and func ~= nil then
        tins(self,Connection:Connect(func))
    end
end
function mt:DestroyAfter(time: number)
    if time == nil then return end;
    task.delay(time,function()
        if self["Destroy"] ~= nil then
            self:Destroy();
        end
    end)
end
function  mt:Extend()
    local Extended = module.New();
    self:Add(Extended)
    return Extended
end
function mt:Add(Entity: any)
    if Entity == nil then return end;
    tins(self,Entity)
    return Entity;
end;
function mt:Remove(Entity)
    if Entity == nil then return end;
   local find = table.find(self,Entity)
   if find ~= nil then
    tr(self,find)
    return true;
   end
   
end
function CleanEntity(Entity: any,type: string)
    if Entity == nil then return end;
    if (type == "table" and Entity["Destroy"] ~= nil) or type == "Instance" then
        Entity:Destroy();
    elseif type == "function" then
        Entity()
    elseif type == "RBXScriptConnection" then
        Entity:Disconnect();
    elseif type == "thread" then
        tcancel(Entity);
    elseif type == "table" then
        tc(Entity)
    end
end

function mt:Clean()
    local i = #self
    while i >0 do
        local v: any = self[i];
        if v == nil then continue end;
        local type = typeof(v)
        CleanEntity(v,type);
        self[i] = nil;
        i = #self;
    end
end
function mt:Destroy()
    self:Clean();
    setmetatable(self,nil);
end
return module