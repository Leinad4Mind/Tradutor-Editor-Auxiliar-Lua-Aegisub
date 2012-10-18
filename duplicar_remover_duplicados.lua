--[[
 Copyright (c) 2012, Leinad4Mind
 All rights reserved®.
 
 Um grande agradecimento a todos os meus amigos
 que sempre me apoiaram, e a toda a comunidade
 de anime portuguesa.
--]]

script_name = "Duplicar Linhas/Remover Duplicados"
script_description = "Duplica e remove duplicados. Aconselhado para a versão 3.0.x"
script_author = "Leinad4Mind"
script_version = "7.0"
script_modified = "18 Outubro 2012"

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
			label = "\n...| Desenvolvido por Leinad4Mind |...",
		},
		{
			class = "label",
			x = 1, y = 2, width = 1, height = 1,
			label = "Seleccione:"
		},
		{
			class = "dropdown", name = "comment",
			x = 2, y = 2, width = 5, height = 1,
			items = {"Duplicar Linhas", "Remover Linhas Duplicadas"}, value = "Duplicar Linhas", hint = "Duplicar ou Remover linhas duplicadas?"
		},
		{
			class = "label",
			x = 1, y = 3, width = 1, height = 1,
			label = "Seleccione:"
		},
		{
			class = "dropdown", name = "chosen",
			x = 2, y = 3, width = 5, height = 1,
			items = {"Linhas Seleccionadas"}, value = "Linhas Seleccionadas", hint = "Linhas Seleccionadas ou Estilo Específico?"
		}
	}
	for i,w in pairs(styles) do
		table.insert(conf[5].items,"Estilo: " .. w)
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
		line.effect = "Duplicado"
		subs.append(line)
		end
    end
	aegisub.progress.set(100)
    aegisub.set_undo_point("A Duplicar Linhas...")
end

function duplicate_tags_style(subs,sel,config)
		for i=1, #subs do
		    local line = subs[i]
			if line.style == config.chosen:sub(9) then
				i = i + 1
				local newline = copy_line
			
				if line.class == "dialogue" and not line.comment and line.text ~= "" then
				line.comment = true
				line.effect = "Duplicado"
				subs.append(line)
				end
			end
		end
end

function remove_comments(subs,sel,config)
    for i=#sel,1,-1 do
        local line = subs[sel[i]]
		if line.class == "dialogue" and line.comment and line.text ~= "" and line.effect == "Duplicado" then
			subs.delete(sel[i])
		end
    end
	aegisub.progress.set(100)
    aegisub.set_undo_point("A Remover Linhas Duplicadas...")
end

function remove_comments_style(subs,sel,config)
		for i=#subs,1,-1 do
		    local line = subs[i]
			if line.class == "dialogue" and line.style == config.chosen:sub(9) and line.comment and line.text ~= "" and line.effect=="Duplicado" then
				subs.delete(i)
			end
		end
	aegisub.progress.set(100)
    aegisub.set_undo_point("A Remover Linhas Duplicadas...")
end

--Correr pelas linhas escolhidas
function add_tags(subs,sel,config)
	if config.chosen == "Linhas Seleccionadas" then
			duplicate_tags(subs,sel,config)
	else
			duplicate_tags_style(subs,sel,config)
	end
end

function remove_tags(subs,sel,config)
	if config.chosen == "Linhas Seleccionadas" then
			remove_comments(subs,sel,config)
	else
			remove_comments_style(subs,sel,config)
	end
end

function remove_text(subs,sel,config)
	for x, i in ipairs(sel) do
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
		ok, config = aegisub.dialog.display(create_confi(subs),{"Adicionar","Cancelar"})
	if ok == "Adicionar" then
	if config.comment == "Duplicar Linhas" then
		add_tags(subs,sel,config)
		remove_text(subs,sel,config)
		dialog_sort(subs)
	else
		remove_tags(subs,sel,config)
	end
		aegisub.set_undo_point("\""..script_name.."\"")
	end
end

--Registar macro no aegisub
aegisub.register_macro(script_name, script_description, load_macro_add)
