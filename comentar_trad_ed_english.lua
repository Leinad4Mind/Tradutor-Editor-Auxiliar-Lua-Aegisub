--[[
 Copyright (c) 2012-2013, Leinad4Mind
 All rights reserved®.
 
 Thanks to FichteFoll and tophf for all the help on regular expressions
 Thanks to Youka, some of this code was taken from his AddTags Script
 And Thanks to Shimapan for his modified 2.1 version, I decide to preserve those modifications
--]]

script_name = "Add or Remove Translation Comments"
script_description = "Put English dialogue into comments. For helping Translators and Editors on 3.x."
script_author = "Youka, Leinad4Mind, Shimapan"
script_version = "3.0"
script_modified = "2013-11-13"

include("cleantags.lua")

-- Clean tags
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
			aegisub.progress.task(linescleaned .. " lines cleaned")
		end
	end
end

-- Collect style names
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

-- Configuration
function create_confi(subs)
	local styles = collect_styles(subs)
	local conf = {
		{
			class = "label",
			x = 1, y = 0, width = 5, height = 1,
			label = "\n...| Developed by Leinad4Mind |...\nTranslation Comments",
		},
		{
			class = "label",
			x = 1, y = 2, width = 1, height = 1,
			label = "Select:"
		},
		{
			class = "dropdown", name = "comment",
			x = 2, y = 2, width = 5, height = 1,
			items = {"Turn dialogue into comments", "Remove translation comments"}, value = "Turn dialogue into comments", hint = "Do you want to turn dialogue into comments or remove the thusly generated comments?"
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

-- Handle tags
function change_tag(subs,index,config)
	local dialogue = subs[index]
			if config.comment == "Turn dialogue into comments" then
				local z = string.find(dialogue.text,"en: ")
				if not z then
					dialogue.text = dialogue.text:gsub("^([^{]+)({[^}]+})(.+)({[^}]+})(.*)", " %2%4 {en: %1#%3#%5}")
					-- Italic tag inside of the text
					-- "A fifth victim was {\i1}found{\i0} with most of her blood missing..."

					dialogue.text = dialogue.text:gsub("^([^{]+)({[^}]+})([^{]-)$", " %2 {en: %1#%3}")
					-- Tag inside of the text
					-- Touno,{\blur2} let's go.

					dialogue.text = dialogue.text:gsub("^({[^}]+})(.+)({[^}]+})$", "%1%3 {en: %2}")
					-- Tags at the beginning and the end
					-- {\blur1.5\i1}"And now, further news on the serial murders."{\i0}
					-- {\fad(1500,0)\be1}Book One\N{\fs65}New Hour

					dialogue.text = dialogue.text:gsub("^({[^}]+})([^{]+)$", "%1 {en: #%2}")
					-- Tags at the beginning
					-- {\pos(320,438)}Thanks for the food.
					local x = string.find(linha.text,"EN: ")
					if not x then
						dialogue.text = dialogue.text:gsub("^({[^}]+})(.+)({[^}]+})(.+)({[^}]+})(.*)$", "%1 %3%5  {en: #%2#%4#%6}")
						-- 3 tags
						--{\i1\blur3}Next time on {\i0}Occult Academy{\i1}:
					end
					local x = string.find(linha.text,"EN: ")
					if not x then
						dialogue.text = dialogue.text:gsub("^({[^}]+})(.+)({[^}]+})(.+)({[^}]+})(.+)({[^}]+})(.*)$", "%1 %3%5 %7%8 {EN: #%2#%4#%6#%8#%10}")
						--5 tags
						--{\i1\blur3}Next time on {\i0}Occult Academy{\i1}text {\i0}text{\i1}text
					end
					dialogue.text = dialogue.text:gsub("^([^{]+)$", " {en: %1}")
					-- No tags
					-- Okay, senpai, it's a promise then.
				end
			else		
				dialogue.text = dialogue.text:gsub(" ?{en: .+}", "")
				-- Remove everything written
			end
	subs[index] = dialogue
end

-- Run through the dialogue
function add_tags(subs,sel,config)
	if config.chosen == "Selected Lines" then
		for x, i in ipairs(sel) do
			change_tag(subs,i,config)
		end
	else
		for i=1, #subs do
			if subs[i].style == config.chosen:sub(8) then
				change_tag(subs,i,config)
			end
		end
	end
end

-- Initialisation + Gui
function load_macro_add(subs,sel)
	local config
		ok, config = aegisub.dialog.display(create_confi(subs),{"Go!","Cancel"})
	if ok == "Go!" then
		cleantags_subs(subs)
		add_tags(subs,sel,config)
		aegisub.set_undo_point("\""..script_name.."\"")
	end
end

-- Register macro with Aegisub
aegisub.register_macro(script_name,script_description,load_macro_add)
