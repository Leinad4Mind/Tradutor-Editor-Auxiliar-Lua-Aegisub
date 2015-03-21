--[[
 Copyright (c) 2012, Leinad4Mind
 All rights reserved®.
--]]

script_name = "Double Lines - Remove Double Lines"
script_description = "Double lines and remove double lines. For Helping Translators and Editors on 3.0.x"
script_author = "Leinad4Mind"
script_version = "6.0"
script_modified = "08 Outubro 2012"

--Recolhe nomes dos estilos
function collect_styles(subs)
	local n, styles = 0, {}
	for i=1, #subs do
		local sub = subs[i]
		if sub.class == "style" then
			n = n + 1
			styles[n] = sub.name
		end
	end
	return styles
end

--Configuração
function create_confi(subs)
	local styles = collect_styles(subs)
	local conf = {
		{
			class = "label",
			x = 1, y = 0, width = 5, height = 1,
			label = "\n...| Developed by Leinad4Mind |...",
		},
		{
			class = "label",
			x = 1, y = 2, width = 1, height = 1,
			label = "Select:"
		},
		{
			class = "dropdown", name = "comment",
			x = 2, y = 2, width = 5, height = 1,
			items = {"Double Lines", "Remove Double Lines"}, value = "Double Lines", hint = "Double Lines or Remove Double Lines?"
		},
		{
			class = "label",
			x = 1, y = 3, width = 1, height = 1,
			label = "Select:"
		},
		{
			class = "dropdown", name = "chosen",
			x = 2, y = 3, width = 5, height = 1,
			items = {"Selected Lines"}, value = "Selected Lines", hint = "Selected Lines or Specific Style?"
		}
	}
	for i,w in pairs(styles) do
		table.insert(conf[5].items,"Style: " .. w)
	end
	return conf
end

--função principal
function duplicate_tags(subs,sel,config)
    for _, i in ipairs(sel) do
        local line = subs[i]
		i = i + 1
		local newline = copy_line
		
		if line.class == "dialogue" and not line.comment and line.text ~= "" then
		line.comment = true
		line.effect = "Double"
		subs.append(line)
		end
    end
	aegisub.progress.set(100)
    aegisub.set_undo_point("Creating Double Lines...")
end

function duplicate_tags_style(subs,sel,config)
		for i=1, #subs do
		    local line = subs[i]
			if line.style == config.chosen:sub(9) then
				i = i + 1
				local newline = copy_line
			
				if line.class == "dialogue" and not line.comment and line.text ~= "" then
				line.comment = true
				line.effect = "Double"
				subs.append(line)
				end
			end
		end
end

function remove_comments(subs,sel,config)
    for i=#sel,1,-1 do
        local line = subs[sel[i]]
		if line.class == "dialogue" and line.comment and line.text ~= "" and line.effect == "Double" then
			subs.delete(sel[i])
		end
    end
	aegisub.progress.set(100)
    aegisub.set_undo_point("Removing Double Lines...")
end

function remove_comments_style(subs,sel,config)
		for i=#subs,1,-1 do
		    local line = subs[i]
			if line.class == "dialogue" and line.style == config.chosen:sub(9) and line.comment and line.text ~= "" and line.effect=="Duplicado" then
				subs.delete(i)
			end
		end
	aegisub.progress.set(100)
    aegisub.set_undo_point("Removing Double Lines...")
end

--Correr pelas linhas escolhidas
function add_tags(subs,sel,config)
	if config.chosen == "Selected Lines" then
			duplicate_tags(subs,sel,config)
	else
			duplicate_tags_style(subs,sel,config)
	end
end

function remove_tags(subs,sel,config)
	if config.chosen == "Selected Lines" then
			remove_comments(subs,sel,config)
	else
			remove_comments_style(subs,sel,config)
	end
end

function remove_text(subs,config)
	for i = 1, #subs do
		local line = subs[i]
			if line.class == "dialogue" and not line.comment and line.text ~= "" and line.effect ~= "Duplicado" then
				line.text = string.format("")
			end
		subs[i] = line
	end
end

--Ordenar!
function dialog_sort(subs)
	--Function to swap table values
	local function swap(t, i)
		local temp = t[i]
		t[i] = t[i+1]
		t[i+1] = temp
	end
	
	--Collect names of chosen type + dialog lines
	--Save first dialog line index
	local sort_table = {}
	local first_line
	for li=1, #subs do
		local line = subs[li]
		if line.class == "dialogue" then
			if not first_line then first_line = li end
			local index
			index = tostring(line.start_time)
			if not sort_table[index] then
				sort_table[index] = {}
			end
			table.insert(sort_table[index], line)
		end
	end
	
	--Save numeric type of sort table
	local sort_table_i = {}
	for key, lines in pairs(sort_table) do
		table.insert(sort_table_i, {key = key, lines = lines})
	end
	--Sort keys (bubble sort)
	for count = 1, #sort_table_i-1 do
		for name_i, name in ipairs(sort_table_i) do
			if name_i < #sort_table_i then
				local key1, key2 = name.key, sort_table_i[name_i+1].key
					if tonumber(key1) > tonumber(key2) then
						swap(sort_table_i, name_i)
					end
	
			end
		end
	end
	
	--Replace old lines with sorted lines
	local i = 0
	for _, name in ipairs(sort_table_i) do
		for _, line in ipairs(name.lines) do
			subs[first_line+i] = line
			i = i + 1
		end
	end
end

--Inicialização + GUI
function load_macro_add(subs,sel)
	local config
		ok, config = aegisub.dialog.display(create_confi(subs),{"Add","Cancel"})
	if ok == "Add" then
	if config.comment == "Double Lines" then
		add_tags(subs,sel,config)
		remove_text(subs)
		dialog_sort(subs)
	else
		remove_tags(subs,sel,config)
	end
		aegisub.set_undo_point("\""..script_name.."\"")
	end
end

--Registar macro no aegisub
aegisub.register_macro(script_name, script_description, load_macro_add)
