--[[
Autor: Julio Sardinha
Versão: 1.0
Descrição:
Script que adiciona ao OBS o recurso de configurar duas teclas de atalho
para que o passador de slides, ou qualquer outro dispositivo do tipo,
possa cumprir sua função, selecionando a próxima cena ou a anterior.
Como usar:
No OBS, vá ao menu Ferramentas > Scripts. Clique no botão +, selecione
esse script.
Feche essa janela.
Vá à configurações do OBS, na aba Teclas de Atalho e encontre os dois campos:
"Avança para a próxima cena" e "Retorna para a cena anterior".
Atribua as teclas do passador de slides respectivas a cada uma das funções
e pronto, brinque à vontade!

ATENÇÃO: nunca tinha programado em Lua antes e não sei direito a API do OBS,
mas o script roda e atendeu às minhas necessidades. Fique à vontade se quiser
sugerir modificações, só temos a ganhar com isso, você e eu. Obrigado!
]]

obs = obslua
seletor = ""
avanca_cena = "Avanca cena"
retorna_cena = "Retorna cena"
cena_exibida = ""
cena_proxima = ""
cena_anterior = ""

-- Guarda a cena atual e retorna o nome dela
local function cenaAtual()
	local src = obs.obs_frontend_get_current_scene()
	local nome = obs.obs_source_get_name(src)
	--obs.script_log(obs.LOG_INFO, string.format("Cena atual : %s", nome))
	obs.obs_source_release(src)
	return nome
end

-- Lista todas as cenas
local function listaCenas(seletor)
	-- tabela de cenas
	local cenas = obs.obs_frontend_get_scenes()
	-- fixa a cena atual
	cena_exibida = cenaAtual()

	-- checa se não há cenas
	if cenas ~= nil then
		-- loop das cenas
		for posicao, cena in ipairs(cenas) do
			-- guarda o nome da cena
			local nome = obs.obs_source_get_name(cena);
			--obs.script_log(obs.LOG_INFO, string.format("Cena %s = %s", posicao, nome))
			-- checa se o nome da cena é o mesmo da cena exibida
			if nome == cena_exibida then
				if seletor == "anterior" then
					-- guarda a cena anterior
					cena_anterior = cenas[posicao - 1]
					--obs.script_log(obs.LOG_INFO, string.format("Anterior = %s", obs.obs_source_get_name(cena_anterior)))
					obs.obs_frontend_set_current_scene(cena_anterior)
				end
				-- cena exibida na tela
				--obs.script_log(obs.LOG_INFO, string.format("Cena exibida = %s", cena_exibida))
				-- guarda a próxima cena
				if nome == cena_exibida then
					if seletor == "proxima" then
						cena_proxima = cenas[posicao + 1]
						--obs.script_log(obs.LOG_INFO, string.format("Próxima = %s", obs.obs_source_get_name(cena_proxima)))
						obs.obs_frontend_set_current_scene(cena_proxima)
					end
				end
			end
		end
	end
	obs.source_list_release(cenas)
	return
end

-- Função para retornar a cena
local function retornaCena(cena_exibida)
	--obs.obs_frontend_set_current_scene(cena_proxima)
	--obs.script_log(obs.LOG_INFO, string.format("Exibida = %s . Qual é a anterior?", cena_exibida))
	listaCenas("anterior")
end

-- Função para avancar a cena
local function avancaCena(cena_exibida)
	--obs.obs_frontend_set_current_scene(cena_proxima)
	--obs.script_log(obs.LOG_INFO, string.format("Exibida = %s . Qual é a próxima?", cena_exibida))
	listaCenas("proxima")
end

local function onTeclaPressionada(action)
	-- obs.script_log(obs.LOG_INFO, string.format("Hotkey : %s", action))
	if action == "Avanca cena" then
		-- Avanca a cena
		--obs.script_log(obs.LOG_INFO, string.format("Tecla pressionada : %s", action))
		avancaCena(cenaAtual())
	elseif action == "Retorna cena" then
		-- Retorna a cena
		--obs.script_log(obs.LOG_INFO, string.format("Tecla pressionada : %s", action))
		retornaCena(cenaAtual())
	end
end

function script_properties()
	-- Deixando só para estudos futuros
	--[[
	local props = obs.obs_properties_create()
	local p = obs.obs_properties_add_list(props, "tecla_de_atalho", "Tecla de Atalho", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)

	local scenes = obs.obs_frontend_get_scenes()
	if scenes ~= nil then
		for _, scene in ipairs(scenes) do
			local name = obs.obs_source_get_name(scene);
			obs.obs_property_list_add_string(p, name, name)
		end
	end
	obs.source_list_release(scenes)

	return props
	]]
end

function script_description()
	return "Avança ou retorna cena de acordo com a tecla de atalho pressionada. Lembre-se de cadastrar os atalhos nas preferências toda vez que ativar o script."
end

function script_update(settings)
	-- pause_scene = obs.obs_data_get_string(settings, "pause_scene")
end

-- called on startup
function script_load(settings)
	obs.obs_frontend_add_event_callback(on_event)
	-- Registra a tecla de atalho para avançar a cena
	obs.obs_hotkey_register_frontend(avanca_cena, "Avança para a próxima cena",
		function(pressed)
			if pressed
				-- then obs.script_log(obs.LOG_INFO, "Avança para a próxima cena")
				then onTeclaPressionada("Avanca cena")
			end
		end
	)
	-- Registra a tecla de atalho para retornar a cena
	obs.obs_hotkey_register_frontend(retorna_cena, "Retorna para a cena anterior",
		function(pressed)
			if pressed
				-- then obs.script_log(obs.LOG_INFO, "Retorna para a cena anterior")
				then onTeclaPressionada("Retorna cena")
			end
		end
	)

-- ainda não sei para que servem nas vou estudar depois
--[[	for k, v in pairs(teclas_de_atalho) do
		hk[k] = obs.obs_hotkey_register_frontend(k, v, function(pressed) if pressed then onTeclaPressionada(k) end end)
		local hotkeyArray = obs.obs_data_get_array(settings, k)
		obs.obs_hotkey_load(hk[k], hotkeyArray)
		obs.obs_data_array_release(hotkeyArray)
	end
]]
end


-- called on unload
function script_unload()
end
