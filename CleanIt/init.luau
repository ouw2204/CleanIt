--!strict
local tins,tr,tc,tof = table.insert,table.remove,table.clear,typeof
local tcancel = task.cancel
local tabletxt,destroytxt,Instancetxt,Threadtxt,RbxlScriptConnectionTxt,FunctionTxt,DeleteFunctionToCallTxt = "table","Destroy","Instance","thread","RBXScriptConnection","function","DeleteFunctionToCall"

export type CleanerType = {
    Holder: {};
    Add: (Entity: any,CleanFunctionName: string) -> ();
    Destroy: (self: CleanerType) -> ();
    Remove: (self: CleanerType, Entity: any) -> ();
    Clean: (self: CleanerType) -> ();
    Extend: (self: CleanerType) -> CleanerType;
    DestroyAfter: (self: CleanerType, time: number) -> ();
}

local mt = {}
mt.__index = mt;
local module = {
    Delay = function(Entity: any, time: number, customCleanFunction: string?)
        if Entity == nil then return end;
        task.delay(time,CleanEntity,Entity,tof(Entity),customCleanFunction)
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
        if self[destroytxt] ~= nil then
            self:Destroy();
        end
    end)
end
function  mt:Extend()
    local Extended = module.New();
    self:Add(Extended)
    return Extended
end
function mt:Add(Entity: any,CleanFunctionName: string)
    if Entity == nil then return end;
    if CleanFunctionName ~= nil then
        tins(self,{Entity = Entity,DeleteFunctionToCall = CleanFunctionName})
    else
        tins(self,Entity)
    end;
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

function CleanEntity(Entity: any,type: string,customCleanFunction: string?)
    if Entity == nil then return end;
    if customCleanFunction ~= nil and Entity[customCleanFunction] ~= nil then
        Entity[customCleanFunction](Entity)
        return
    elseif (type == tabletxt and Entity[destroytxt] ~= nil) or type == Instancetxt then
        Entity:Destroy();
    elseif type == tabletxt and Entity[DeleteFunctionToCallTxt] ~= nil then
        Entity.Entity[Entity[DeleteFunctionToCallTxt] ](Entity.Entity)
        Entity.Entity = nil;
        Entity.DeleteFunctionToCallTxt = nil;
    elseif type == FunctionTxt then
        Entity()
    elseif type == RbxlScriptConnectionTxt then
        Entity:Disconnect();
    elseif type == Threadtxt then
        tcancel(Entity);
    elseif type == tabletxt then
        tc(Entity)
    end
end

function mt:Clean()
    local i = #self
    while i >0 do
        local v: any = self[i];
        if v == nil then continue end;
        local type = tof(v)
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