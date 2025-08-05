--!strict
local tins,tr,tc,tof,tf = table.insert,table.remove,table.clear,typeof,table.find
local tcancel = task.cancel
local tabletxt,destroytxt,Instancetxt,Threadtxt,RbxlScriptConnectionTxt,FunctionTxt,DeleteFunctionToCallTxt,CleanTxt = "table","Destroy","Instance","thread","RBXScriptConnection","function","DeleteFunctionToCall", "Clean"

export type CleanerType = {
    Holder: {};
    Add: (Entity: any,CleanFunctionName: string) -> ();
    Destroy: (self: CleanerType) -> ();
    Remove: (self: CleanerType, Entity: any) -> ();
    Clean: (self: CleanerType) -> ();
    Extend: (self: CleanerType) -> CleanerType;
    DestroyAfter: (self: CleanerType, time: number) -> ();
    CleanAfter: (self: CleanerType, time: number) -> ();
    Exists: (self: CleanerType, Entity: any) -> boolean,
    Connect: (self: CleanerType, connection: RBXScriptSignal, func: (...any) -> any) -> ();
    CleanIndividual: (self: CleanerType, Entity: any,CustomCleanFunction: string?) -> ();
}

local mt = {}
mt.__index = mt;
local module = {
    delay = function(Entity: any, Time: number, customCleanFunction: string?)
        if Entity == nil then return end;
        task.delay(Time,CleanEntity,Entity,tof(Entity),customCleanFunction)
    end,
    new = function() : CleanerType
        local Cleaner = {
            Holder = {};
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
function mt:CleanAfter(time: number)
    if time == nil then return end;
    task.delay(time,function()
        if self[CleanTxt] ~= nil then
            self:Clean();
        end
    end)
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
    local Extended = module.new();
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
   local find = tf(self,Entity)
   if find ~= nil then
    tr(self,find)
    return true;
   end
   
end

local animationtracktxt = "AnimationTrack"
local TweenTxt = "Tween";
function CleanEntity(Entity: any,type: string,customCleanFunction: string?)
    if Entity == nil then return end;
    if customCleanFunction ~= nil and Entity[customCleanFunction] ~= nil then
        Entity[customCleanFunction](Entity)
        return
    elseif (type == tabletxt and Entity[destroytxt] ~= nil) or type == Instancetxt then

        --|
        if Entity.ClassName == animationtracktxt then
            Entity:Stop();
        elseif Entity.ClassName == TweenTxt then
            Entity:Cancel();
        end
        --|>

        Entity:Destroy();
    elseif type == tabletxt and Entity[DeleteFunctionToCallTxt] ~= nil then
        Entity.Entity[Entity[DeleteFunctionToCallTxt] ](Entity.Entity)
        Entity.Entity = nil;
        Entity.DeleteFunctionToCallTxt = nil;
    elseif type == FunctionTxt then
        task.spawn(Entity)
    elseif type == RbxlScriptConnectionTxt then
        Entity:Disconnect();
    elseif type == Threadtxt then
        tcancel(Entity);
    elseif type == tabletxt then
        tc(Entity)
    end
end
function mt:CleanIndividual(Entity: any,CustomCleanFunction: string?)
    if self[Entity] ~= nil then
        CleanEntity(self[Entity],tof(self[Entity]),CustomCleanFunction)
        self[Entity] = nil;
    else
        CleanEntity(Entity,tof(Entity),CustomCleanFunction)
        local f = tf(self,Entity)
        if f ~= nil then
            tr(Entity,f)
        end
    end
end
function mt:Exists(Entity)
    if Entity == nil then return false end;
    return tf(self,Entity) ~= nil
end

function mt:GetAll()
    return self;
end
function mt:Clean()
    for _,v in pairs(self) do
        local type = tof(v)
        CleanEntity(v,type);
    end
    tc(self)
end
local thistxt = "Cleaner"
--[[function mt.__tostring()
    return thistxt
end]]
function mt:Destroy()
    self:Clean();
    setmetatable(self,nil);
end
return module