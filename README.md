Tradutor-Editor-Auxiliar-Lua-Aegisub
====================================

Visto que maioria não gosta do novo método do 3.0.x, ou não quer se habituar a ele,
para dar a volta a essa problema decidi criar 2 auxiliares para tradutores e editores
que irá alterar todo o método de trabalho destes. E claro está, facilitar o mesmo. 

Existe 2 métodos:
- O ficheiro comentar_trad_ed.lua irá alterar todas as linhas seleccionadas ou todas linhas de um determinado estilo, e comentar as próprias linhas da seguinte forma:

        "Today is gonna rain" irá ficar "Tradução {EN: Today is gonna rain}"

- O ficheiro duplicar_remover_duplicados.lua irá duplicar todas as linhas seleccionadas ou todas linhas de um determinado estilo, e após traduzir-se nas linhas não comentadas, basta correr a macro e escolher a opção remover duplicados, ficando apenas com a tradução.


Por fazer
---------
* Creio que já está tudo feito, mas estarei disposto a melhorar se houver dicas para tal.


Como instalar
-------------

Load Automático

1. Transferir XPTO.lua
2. Colocar esse ficheiro na pasta _autoload_ situada dentro da pasta _automation_ que por sua vez está presenta na sua pasta de instalação do aegisub


Load Manual

1. Transferir XPTO.lua e guarde-o onde bem desejar
2. Com o Aegisub aberto, quando desejar usá-lo terá de clicar em Automatização -> Automatização...
3. Clicar de seguida em _Adicionar_ e ir ao local onde se encontra o XPTO.lua


Como usar
---------

Não tem nada que saber, é muito intuitivo.
