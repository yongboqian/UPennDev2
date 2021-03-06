
function createVRML(header)
  local vrml = {}
  vrml.__type = 'vrml'
  vrml.__header = header
  return vrml
end

function createPROTO(protoName)
  local proto = {}
  proto.__name = protoName
  proto.__type = 'proto'

  return proto
end



function createNode(nodeName, nodeType)
  local node = {}
  node.__name = nodeName
  node.__nodeType = nodeType
  node.__type = 'node'
  node.__def = 0

  return node
end

function createField(fieldName, value)
  local field = {}
  if type(value) == 'table' then
    field = value
  end
  field.__name = fieldName
  field.__type = 'field'

  return field
end

function createMultiField(fieldName, value)
  local field = {}
  if type(value) == 'table' then
    field = value
  end
  field.__name = fieldName
  field.__type = 'multifield'

  return field
end

function createProto(protoName)
  local proto = {}
  proto.__name = protoName
  proto.__type = 'field'
  return proto
end

function indentSpace(indent)
  local str = ''
  for i = 1, indent do
    str = str..'  '
  end
  return str
end

function writeproto(file, proto, indent)
  file:write(indentSpace(indent)..'PROTO '..proto.__name..' [')
  if proto.declaration then
  end
  file:write(indentSpace(indent)..']\n')
  file:write(indentSpace(indent)..' {\n')

  for k, v in ipairs(proto) do
    _G['write'..v.__type](file, v, indent + 1)
  end
  file:write(indentSpace(indent)..'}\n')
end

function writenode(file, node, indent)
  if node.__name then
    if node.__def == 1 then
      file:write(indentSpace(indent)..'DEF '..node.__name..' ')
    else
      file:write(indentSpace(indent)..node.__name..' ')
    end
    file:write(node.__nodeType..' {\n')
  else
    file:write(indentSpace(indent)..node.__nodeType..' {\n')
  end
  for k, v in ipairs(node) do
    _G['write'..v.__type](file, v, indent + 1)
  end
  file:write(indentSpace(indent)..'}\n')
end

function writefield(file, field, indent)
  file:write(indentSpace(indent)..field.__name)
  for k, v in ipairs(field) do
    file:write(' '..v)
  end
  file:write(indentSpace(indent)..'\n')
end

function writemultifield(file, field, indent)
  file:write(indentSpace(indent)..field.__name..' [\n')
  local numCount = 0
  local maxLineNum = 4

  for i = 1, #field do
    if type(field[i]) == 'string' then
      file:write(indentSpace(indent+1)..'"'..field[i]..'"\n')
    elseif type(field[i]) == 'number' then
      file:write(indentSpace(indent+1))
      file:write(field[i]..' ')
      numCount = numCount + 1
      if field.__delimiterFreq and numCount % field.__delimiterFreq == 0 then
        file:write(field.__delimiter)
      end
      if numCount % maxLineNum == 0 then
        file:write(indentSpace(indent)..'\n')
      end
    elseif type(field[i]) == 'table' then
      _G['write'..field[i].__type](file, field[i], indent + 1)
    end
  end
  file:write(indentSpace(indent)..']\n')
end

function saveVRML(vrml, filename)
  if vrml.__type ~= 'vrml' then
    error('input must be created by createVRML')
  end
  local indent = 0 
  file = assert(io.open(filename, 'w'))

  if vrml.__header then
    file:write(vrml.__header)
    file:write('\n\n')
  end
  for k, v in ipairs(vrml) do
    _G['write'..v.__type](file, v, indent)
  end
end
