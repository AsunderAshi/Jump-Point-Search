local node = {}

-----------------------------------------------------------------------------
-- Node class holds basic information about maze cell
-- 
-- @constructor
-- @param x              x coordintae of the node
-- @param y              y coordinate of the node
-- @param walkable       [optional] if not given, set as true, otherwize
--                       set given value
-----------------------------------------------------------------------------
function node:new(x, y, walkable)
  self.__index = self
  local new_node = {
    x = x, 
    y = y, 
    walkable = walkable == nil and true or walkable
  }
  return setmetatable(new_node, self)
end

-----------------------------------------------------------------------------
-- Shortcut for comparing equality between two nodes with '=' operator
--
-- @param  other         node to compare with
-- @return               node.x == other.x and node.y == other.y
-----------------------------------------------------------------------------
function node:__eq(other)
  return node.x == other.x and node.y == other.y
end

return node
