
module("SQLColumn", package.seeall )

DEBUG = true

local MetaTable = {
	__index = getfenv()
}

/*
column = COLUMN NAME

//What should be inserted into the UPDATE query
fullupdate = nil or function(ply) returning "columnname = value"

//If fullupdate is not set, this will be called, just return value
update = function(ply) return val end

//What should be put in the sql query
selectquery = nil or columnname

//What column should be selected from the database
selectresult = nil or columname

//Called when the new value has been se
onupdate = nil or function(ply, val) ply:SetVal( val ) end

//Called when the default value need to be set
defaultvalue = nil or function


// type = Store the database of the column
// Possible values:
// 'tinyint', 'int', 'bigint'
// 'real', 'double',
// 'varchar(%d)', 'text', 'blob'
// 'boolean'

*/

function Init( data )

	if !data.column then
		return
	end
--PrintTable(data)
	--if DEBUG then
		print("Loading column: " .. data.column )
	--end
	table.insert(SQL.ColumnInfo,data)
	local o = {}

	setmetatable( o, MetaTable )

	o.Column = data.column
	o.UnimportantUpdate = data.UnimportantUpdate
	o.DataType = data.type

	if data.defaultvalue then
		o.DefaultValueFunc = data.defaultvalue
	end

	if data.onupdate then
		o.SelectCallback = data.onupdate

		//No need to have a select query if it does not have a call back function
		o.SelectQuery = data.selectquery or data.column
		o.SelectResult = data.selectresult or data.selectquery or data.column
	end

	if type( data.fullupdate ) == "function" then

		o.FullUpdate = data.fullupdate
		o.GetUpdate = GetFullUpdate

	elseif type( data.update ) == "function" then

		o.UpdateFunc = data.update
		o.GetUpdate = GetUpdateValue

	end

	//Check if the column exists in the database
	/*if SQL.ColumnInfo[ o.Column ] then

		//TODO: Check if the DataType is correspondign with the database
		if DEBUG then
			print("\tColumn " .. o.Column .. " already exists in the database.")
		end

	if o.DataType then

		table.insert( SQL.AlterTableQuery, "ADD `".. o.Column .."` " .. o.DataType .. " NULL" )

		if DEBUG then
			print("\tAdding " .. o.Column .. " to the list to be modified.")
		end

	else

		//Uh oh! The column does not exist and it did not specify the datatype
		ErrorNoHalt( o.Column .. " does not have a datatype!")
		return

	end*/


	o.Id = table.insert( SQL.Colums, o )

	return o

end

function GetSelect( self )
	if self.SelectCallback then
		return self.SelectQuery
	end
end

function GetSelectCallback( self )
	return self.SelectResult
end

function GetFullUpdate( self, ply, ondisconnect )

	local b, retval = SafeCall( self.FullUpdate, ply, ondisconnect )

	if b && retval then
		return retval
	end

end

function GetUpdateValue( self, ply, ondisconnect )

	local b, retval = SafeCall( self.UpdateFunc, ply, ondisconnect )

	if type( retval ) == "table" then
		PrintTable( self )
	end

	if b && retval then
		return "`" .. self.Column .. "`=" ..  retval
	end

end

GetUpdate = function() end

function DefaultValue( self, ply )
	if self.DefaultValueFunc then
		SafeCall( self.DefaultValueFunc, ply )
	end
end

function OnSelect( self, ply, val )
	if self.SelectCallback then
		SafeCall( self.SelectCallback, ply, val )
	end
end
