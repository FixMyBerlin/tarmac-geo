package.path = package.path .. ";/app/process/helper/?.lua"
require("Set")
require("FilterTags")
-- require("ToNumber")
-- require("PrintTable")
require("AddAddress")
require("MergeArray")
require("Metadata")

local table = osm2pgsql.define_table({
  name = 'education',
  ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
  columns = {
    { column = 'tags', type = 'jsonb' },
    { column = 'meta', type = 'jsonb' },
    { column = 'geom', type = 'point' },
  }
})

local function ExitProcessing(object)
  if not object.tags.amenity then
    return true
  end

  local allowed_values = Set({
    "childcare",
    "college",
    "kindergarten",
    "research_institute",
    "school",
    "university"
  })
  if not allowed_values[object.tags.amenity] then
    return true
  end

  return false
end

local function ProcessTags(object)
  local allowed_addr_tags = AddAddress(object.tags)
  local allowed_tags = Set(MergeArray({ "name", "amenity" }, allowed_addr_tags))
  FilterTags(object.tags, allowed_tags)
end

function osm2pgsql.process_node(object)
  if ExitProcessing(object) then return end

  ProcessTags(object)

  table:insert({
    tags = object.tags,
    meta = Metadata(object),
    geom = object:as_point()
  })
end

function osm2pgsql.process_way(object)
  if ExitProcessing(object) then return end
  if not object.is_closed then return end

  ProcessTags(object)

  table:insert({
    tags = object.tags,
    meta = Metadata(object),
    geom = object:as_polygon():centroid()
  })
end

function osm2pgsql.process_relation(object)
  if ExitProcessing(object) then return end
  if not object.tags.type == 'multipolygon' then return end

  ProcessTags(object)

  table:insert({
    tags = object.tags,
    meta = Metadata(object),
    geom = object:as_multipolygon():centroid()
  })
end
