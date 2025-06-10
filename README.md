# CleanIt
A LUAU memory cleaner, it's a simple package that helps you clean memory. As of now, CleanIt has cleaning support for: 
- Functions
- Instances
- Connections
- Threads
- Tables
- Anything with a Destroy function
> [!CAUTION]
> If you are sending in functions or objects with custom destroy functions, make sure there is error handling in those functions. **All** yields in any destroy functions will effect all of the other elements in the CleanIt cleaning list.
## Installation
### Roblox
https://create.roblox.com/store/asset/87184763787563/CleanIt
### Wally
```
CleanIt = "prophetouw/cleanit@1.3.18"
```
### Github
To download this from the github, see the [releases](https://github.com/ProphetOuw/CleanIt/releases/tag/first) section and download the latest rbxm file.
## Methods
### Timed cleaning
```lua
CleanIt.Delay(Entity,.2)
```
### Add
Adds the Entity to the cleaning list.
```lua
local Cleaner = CleanIt.New()
Cleaner:Add(object1)
Cleaner:Destroy()
```
If you want custom cleaning logic you can use functions:
```lua
local Object = workspace.Object
Cleaner:Add(function()
    task.spawn(function()
        Object.Name = "--";
        task.wait(1)
        Object:Destroy()
    end)
end)
task.wait(.5)
Cleaner:Destroy() -- deletes the thread before it gets to the point of deleting the object
Print(Object.Parent.Name)
```
### Clean
If you want to empty the cleaner without deleting it
```lua
Cleaner:Clean()
```
### Connect
For signals
```lua
Cleaner:Connect(Workspace.ChildAdded,function(child)
    print(child.Name)
end)
```
### Remove
Removes the entity's reference from the cleaner's cleaning list. This function is useful for garbage collection.
```lua
local Object = {
    Name = "Hi"
    Run = function()

    end
}
function Object:Destroy()
    Cleaner:Remove(self) -- remove reference so garbage collector can clean the memory
    for k in pairs(self) do
        self[k] = nil;
    end
end
Cleaner:Add(Object)
return Object
```
### DestroyAfter
Destroys the cleaner after a certain amount of seconds
```lua
Cleaner:DestroyAfter(2)
```
### Destroy
Cleans everything in the CleanIt cleaning list and itself.
```lua
Cleaner:Add(object1)
Cleaner:Destroy()
```