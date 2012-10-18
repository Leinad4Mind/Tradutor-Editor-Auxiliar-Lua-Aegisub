--[[
 Copyright (c) 2012, Leinad4Mind
 All rights reserved®.
 
 Agradecimentos a FichteFoll e tophf pela ajuda nas expressões regulares
 
 Um grande agradecimento a todos os meus amigos
 que sempre me apoiaram, e a toda a comunidade
 de anime portuguesa.
--]]

script_name = "Add/Remover Comentários"
script_description = "Colocar todas as linhas como comentários para se traduzir. E possibilidade de apagar todas as linhas dos comentários. Expressões aos Estilos ou Linhas Seleccionadas. Aconselhado para a versão 3.0.x"
script_author = "Leinad4Mind"
script_version = "2.0"
script_modified = "08 Outubro 2012"

include("cleantags.lua")

--Cleantags do cleantags-autoload
function cleantags_subs(subtitles)
	local linescleaned = 0
	for i = 1, #subtitles do
		aegisub.progress.set(i * 100 / #subtitles)
		if subtitles[i].class == "dialogue" and not subtitles[i].comment and subtitles[i].text ~= "" then
			ntext = cleantags(subtitles[i].text)
			local nline = subtitles[i]
			nline.text = ntext
			subtitles[i] = nline
			linescleaned = linescleaned + 1
			aegisub.progress.task(linescleaned .. " linhas limpas")
		end
	end
end

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
			items = {"Comentar Linhas", "Remover Linhas Comentadas"}, value = "Comentar Linhas", hint = "Comentar ou Remover linhas comentadas?"
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

--Adiciona expressões ao campo de texto
function change_tag(subs,index,config)
	local linha = subs[index]
			if config.comment == "Comentar Linhas" then
				linha.text = linha.text:gsub("^([^{]+)({[^}]+})(.+)({[^}]+})([a-zA-Z ]+)(.+)", "Tradução %2Tradução%4 Tradução {EN: %1%2 { %3 } %4 { %5%6}") -- Com expressão itálico numa palavra a meio.
				-- "A fifth victim was {\i1}found{\i0} with most of her blood missing..."
				linha.text = linha.text:gsub("^([^{]+)({[^}]+})([^{]-)$", "Tradução %2Tradução {EN: %1 } %2 {%3}") -- Com expressão a meio.
				--Tohno,{\blur2} let's go.
				linha.text = linha.text:gsub("^([^{]+)({[^}]+})(.+)({[^}]+})([.?!]+)", "Tradução %2Tradução%4%5 {EN: %1%2 { %3 } %4{%5}") -- Com expressão itálico numa palavra a meio.
				--Yeah, {\i1}certainly{\i0}.
				linha.text = linha.text:gsub("^({[^}]+})(.+)({[^}]+})$", "%1Tradução%3 {EN: %2}") -- Com expressão inicial e final
				-- {\blur1.5\i1}"And now, further news on the serial murders."{\i0}
				linha.text = linha.text:gsub("^({[^}]+})([^{]+)$", "%1Tradução {EN: %2}") -- Com expressão inicial
				--{\pos(320,438)}Thanks for the food
				linha.text = linha.text:gsub("^([^{]+)$", "Tradução {EN: %1}") -- Sem expressões
				--Okay, senpai, it's a promise then.
			else		
				linha.text = linha.text:gsub(" ?{EN: .+}", "") --Remove tudo criado
			end
	subs[index] = linha
end

--Correr pelas linhas escolhidas
function add_tags(subs,sel,config)
	if config.chosen == "Linhas Seleccionadas" then
		for x, i in ipairs(sel) do
			change_tag(subs,i,config)
		end
	else
		for i=1, #subs do
			if subs[i].style == config.chosen:sub(9) then
				change_tag(subs,i,config)
			end
		end
	end
end

--Inicialização + GUI
function load_macro_add(subs,sel)
	local config
		ok, config = aegisub.dialog.display(create_confi(subs),{"Adicionar","Cancelar"})
	if ok == "Adicionar" then
		cleantags_subs(subs)
		add_tags(subs,sel,config)
		aegisub.set_undo_point("\""..script_name.."\"")
	end
end

--Registar macro no aegisub
aegisub.register_macro(script_name,script_description,load_macro_add)