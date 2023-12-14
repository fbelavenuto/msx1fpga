-------------------------------------------------------------------------
ExecROM vr. 1.2f
para o sistema MSX

(c) 1996-1999,2001-2009 A&L Software
-------------------------------------------------------------------------

	00. Indice
	    ------

	    01. O que e' o ExecROM
	    02. Por que o ExecROM
	    03. Por que arquivos ROM
	    04. O que voce precisa para executar arquivos ROM
	    05. O que e' o cartucho MegaRAM
	    06. Como usar o ExecROM
	    07. Modificando cartuchos ROM com o ExecROM
	    08. O arquivo de "patch"
	    09. Solucionando problemas no ExecROM
	    10. Creditos, uso, copia e agradecimentos
	

	01. O que e' o ExecROM
	    ------------------

	O ExecROM e' um programa que lhe permite executar arquivos ROM no
seu MSX1, MSX2, MSX2+ ou MSX Turbo R. Ele pode executar arquivos  ROM  de
4, 8, 16, 32, 48, 64, 96, 112, 128, 256, 512, 768, 1024 e 2048Kb.
	Um arquivo ROM e' apenas uma copia de um cartucho MSX  e pode ser
encontrado em varios sites na Internet. Um arquivo de imagem ROM pode ser
apenas um cartucho de 16k ou 32k ou ate' mesmo  um  cartucho  MegaROM  de
512k.
	Os arquivos ROM eram originalmente para se usar nos emuladores de
MSX,mas com o ExecROM voce agora pode executa-los em seu MSX REAL (que e'
muito melhor que um emulador :)!
       

	02. Por que o ExecROM
	    -----------------

	Por que usar o ExecROM? Eis alguns bons motivos:

a) O ExecROM executa qualquer tipo de arquivo ROM,  seja  ele  normal  ou 
   MegaROM, com pagimento de 8k ou 16k.

b) O carregamento e execucao do arquivo ROM e' totalmente automatico, dis
   pensando o usuario de fornecer dados sobre o seu MSX e sua  configura-
   cao.

c) A identificacao dos arquivos MegaROM e' automatica,  nao  necessitando 
   de nenhuma especificacao do usuario. Ainda assim, e'  possivel  forcar 
   um mapeamento especifico, nos mesmos moldes do emulador  fMSX,  nao  o
   obrigando a decorar novamente os tipos de mapeadores de MegaROMs.

d) Permite a utilizacao dos Game Masters da Konami em sua  totalidade  se
   voce possuir uma MegaRAM, no caso do Game Master I, ou no minimo  128k
   de Memory Mapper no caso do Game Master II.

e) Permite a utilizacao de "patches" de vidas  infinitas, imunidade, etc,
   nos jogos .ROM. Assim voce nao perde suas dicas e macetes para jogos.

f) Permite a utilizacao de arquivo de "patches" para modificacoes mais e-
   laboradas em arquivos ROM de jogos ou mesmo de aplicativos.

g) Permite o carregamento de arquivos ROM que contenham programas residen
   tes, nao sendo apenas mais um "carregador de jogos".

h) Pode enganar os programas e jogos ROM, fazendo-os identificar seu  MSX
   como uma maquina japonesa ou nao. Assim voce podera' ver telas e fases
   secretas de certos jogos que voce^ tanto queria,    ver em  ingles  os
   programas que so' se apresentavam em japones no seu Turbo-R  ou  mesmo
   ver em japones os programas que so se apresentam em ingles no seu MSX.

i) Os jogos de MSX1 executados em MSX2 ou superior em modo  "CoolColors",
   exclusivo do ExecROM, ganham um  visual  incrivel,  tornando-os  ainda
   mais bonitos e divertidos.

j) Suporte ao MSXDOS1 e MSXDOS2, sendo que neste ultimo possibilita o uso
   de subdiretorios, HD, ZIP drive, CDROM ou qualquer outro periferico.

k) Suporte a cartuchos ROM BASIC. Voce^ pode executar copias ROM de  car-
   tuchos BASIC originais como qualquer outro arquivo ROM. Voce^ nao pre-
   cisa converter o conteudo do arquivo ROM para um programa  BASIC  para
   executa-lo.

l) Suporte a SCC para todos os jogos da Konami. Mesmo que voce^ nao tenha
   um cartucho SCC em 'piggyback' com sua MegaRAM voce^ pode executar jo-
   gos da Konami com musica SCC completa.


	03. Por que arquivos ROM
	    --------------------

	A utilizacao de arquivos ROM, apesar de eles terem sido original-
mente criados para uso em emuladores, e' vantajosa para o MSX. Veja   al-
gumas dessas vantagens:

a) E' a imagem fiel do cartucho, ou seja, nao  possui  codigo  de progra-
   mador inexperiente em lugar algum. Como sempre  sera'  carregado  pelo
   ExecROM ou algum programa similar. Se houver algum problema de incompa
   tibilidade com este, basta obter uma versao corrigida e pronto:  todos
   os seus .ROM funcionarao. No caso dos arquivos .BIN seria necessario e
   ditar todos os arquivos um a um, para trocar os carregadores.

b) E' muito mais portavel "inter-OS", ou seja, e' possivel dar suporte  a
   eles tanto no MSX-DOS1, MSX-DOS2, WiOS ou qualquer outro sistema opera
   cional que venha a ser criado para o MSX.

c) Em relacao aos jogos MegaRAM e' muito mais rapido para ser  carregado,
   pois, devido ao fato de ser um arquivo so', o cabecote do drive nao fi
   ca "passeando" sobre o disco.

d) E' independente  do hardware utilizado. Portanto, pode rodar em emula-
   dores, MegaRAM ou qualquer futuro hardware que simule um MegaROM, seja
   por software ou por hardware.

e) "Patches" para algum bug existente no .ROM ficam muito mais faceis  de
   fazer, assim como para vidas infinitas, devido a padronizacao do forma
   to .ROM. No caso dos jogos MegaRAM tradicionais nunca se sabe se o ar-
   quivo ".000" e' o primeiro ou o ultimo bloco, nem se  ha' algum  outro
   programa de carregamento em seu inicio ou fim.  Por  isso  que  alguns
   "patches" funcionam para algumas pessoas e para outras nao.

f) Ao se comprimir um arquivo .ROM consegue-se uma taxa de compressao me-
   lhor que ao se comprimir os varios blocos dos jogos normais ou MegaRAM
   tradicionais.

g) Por separar o carregador do cartucho evita a replicacao de codigo  co-
   mum, economizando espaco em disco, alem de todas as  outras  vantagens
   obvias de se evitar tal replicacao.

h) Pode ser encarado como um "executavel" padronizado, ou seja, possui um
   cabecalho, endereco inicial e de execucao e outras informacoes  impor-
   tantes. Isso significa que um sistema operacional que diferencie  seus
   arquivos pelo cabecalho, ao inves da extensao,  pode  reconhece-los  e
   trata-los adequadamente.


	04. O que voce precisa para executar arquivos ROM
	    ---------------------------------------------

	Para executar arquivos ROM voce vai precisar:
	
	* do programa ExecROM;
	* do sistema operacional MSX-DOS;
	* de um computador MSX;
	* de um cartucho MegaRAM;

	Se voce deseja executar cartuchos MegaROM ou usar o Game Master I
voce REALMENTE precisara' de uma MegaRAM. Se  voce  deseja  usar  o  Game
Master II, alem da MegaRAM, voce precisara' ter pelo menos 128k de  memo-
ria no seu MSX. Mas se voce quer apenas executar cartuchos de 16k ou  32k
sem usar os Game Master I ou II, apenas um MSX,o MSX-DOS e o ExecROM  sao
necessarios.
	O ExecROM e' um arquivo COM do MSX-DOS, que e' necessario para  a
execucao do programa. Voce nao pode executar o ExecROM sob o BASIC.
	Originalmente escrito para ser executado em um computador MSX,  o
ExecROM pode ser executado com relativo sucesso nos emuladores (e' claro,
voce nao pode executar jogos MegaRAM ou usar os Game Masters naqueles que
nao emulam a MegaRAM...),e foi testado com sucesso com o emulador MSX CJS
versoes 0.99b e 1.0b, com o emulador fMSX versoes 1.4 e 1.6 para MS-DOS e
com o BrMSX (versao 1.101 e superiores).


	05. O que e' o cartucho MegaRAM
	    ---------------------------
	
	A MegaRAM e' um cartucho de memoria  parecido  com  os  cartuchos
MegaROM. A diferenca entre a MegaRAMs e os MegaROMs e' obvia: enquanto os
cartuchos MegaROM so' podem ser lidos, as MegaRAMs  podem  ser  lidas  ou
gravadas. Voce pode encontrar MegaRAMs com o tamanho de 256, 512 e 768Kb.
	Voce tambem pode encontrar a MegaRAM Disk, que e' uma MegaRAM com
a ROM de disco interna, usando a MegaRAM como uma RAM  Disk. Voce pode u-
sar a MegaRAM Disk como diskette  ou como uma MegaRAM normal (tambem cha-
mada de MegaRAM Game).
	A MegaRAM e' uma invencao brasileira  e e' quase desconhecida  na
Europa, Japao e outros paises. Ao contrario da Memory Mapper,  a  MegaRAM 
nao e' reconhecida como a verdadeira expansao de memoria do MSX.


	06. Como usar o ExecROM
	    -------------------

	E' muito facil usar o ExecROM. Para apenas  executar  um  arquivo 
ROM no seu MSX, digite, no prompt do DOS,

	ExecROM arquivo

	onde 'arquivo' e' o nome do arquivo ROM que voce quer executar. A
extensao '.ROM' pode ser omitida.
	Se o arquivo ROM esta' em outro drive, basta especifica-lo  antes
do nome, como se faz normalmente no MSXDOS. Se voce  esta'  executando  o
ExecROM no MSXDOS2, voce tambem pode especificar o diretorio  do  arquivo
ROM.
	Apenas espere alguns segundos e o cartucho sera' executado. Todas
as acoes (deteccao, analise, carregamento, etc), incluindo a deteccao  da
MegaRAM, sao automaticas.
	O ExecROM possui algumas opcoes, que podem ser selecionadas antes
do nome do arquivo. Elas estao listadas abaixo.

opcao /B: nao executa o arquivo diretamente, mas reseta o MSX para  isso.
	  Alguns jogos e programas residentes precisam desta opcao.

opcao /C: muda um byte no cartucho. E' util em jogos para se conseguir vi
	  das infinitas, imortalidade, etc. A sintaxe e':
	  /Cpp,xxxx,yy
	  onde:  pp - e' a pagina a ser mudada. E' apenas necessaria para
		      jogos MegaROM, que sao divididos em  paginas  (0  a
		      0Fh para cartuchos de 128k, 0 a 1Fh para  cartuchos
		      256k e de 0 a 3Fh para cartuchos de 512k).
		 xxxx - e' o endereco a ser modificado. O endereco  e'  o
			deslocamento relativo ao comeco do cartucho.  Nas 
			imagens MegaROM o endereco e' o deslocamento rela
			tivo ao comeco da pagina. O comeco do cartucho  e
			da pagina e' assumido como endereco 0.
		 yy - e' o byte a colocar no endereco.

opcao /D: permite a troca de disco entre o carregamento do  ExecROM  e  o
	  carregamento do arquivo ROM.   Assim,  voce^  pode  executar  o
	  ExecROM de um disco e carregar o arquivo ROM de outro.

opcao /E: nao seta a paleta CoolColors. Se sua maquina e' MSX2 ou superi-
	  or, o ExecROM seta automaticamente a paleta do MSX1 para o modo
	  CoolColors, dando um visual incrivel a jogos. Com a opcao /E es
	  te modo nao e' setado automaticamente.

opcao /F: preenche uma area do cartucho. E' util para jogos tambem. A sin
	  taxe e':
	  /Fpp,qq,xxxx,yy,zz
	  onde:  pp - e' a pagina inicial a ser preenchida. E' necessaria
		      apenas para jogos MegaROM.
		 qq - e' a pagina final   a ser preenchida. E' necessaria
		      apenas para jogos MegaROM.
		 xxxx - e' o endereco inicial a ser preenchido. O endere-
			co e' o deslocamento relativo ao inicio do cartu-
			cho (nos cartuchos MegaROMs e' relativo ao comeco
			da  pagina). O comeco do cartucho e da pagina  e'
			assumido como endereco 0.
		 yyyy - e' o endereco  final  a ser preenchido. O endere-
			co e' o deslocamento relativo ao inicio do cartu-
			cho (nos cartuchos MegaROMs e' relativo ao comeco
			da  pagina). O comeco do cartucho e da pagina  e'
			assumido como endereco 0.
		 zz - e' o byte a preencher a area.
	   
	  Nota importante: na opcao /F a imagem MegaROM e'  tratada, ape-
			   sar da divisao em paginas, como linear. Assim,
			   se voce requisitar /F1,2,7,10,8 a pagina 1 se-
			   ra' preenchida do endereco 7 ao final  com   o
			   byte 8 e a pagina 2 sera' preenchida do  ende-
			   reco 0 ao 10 com o byte 8. Se voce  colocar  5
			   no lugar do 2 as paginas 2,3 e 4 serao comple-
			   tamente preenchidas com o byte 8.

			   Representacao hipotetica da opcao /F1,2,7,10,8
			   ... pag. 1                       pag. 2    ...
			   |--------------------|------------------------
			   |??888888888888888888|8888????????????????????
			   ||-|-----------------||--|--------------------
			    0 7                  0  10        (enderecos)

			   Representacao hipotetica da opcao /F1,5,7,10,8
			   ... pag. 1 ... pags. 2,3  e  4 ... pag. 5  ...
			   |-----------|-----|------|------|-------------
			   |??888888888|88888|888888|888888|8888?????????
			   ||-|--------|-----|------|------||--|---------
			    0 7              (enderecos)    0  10        

opcao /G1:carrega o Game Master I da Konami com o arquivo ROM. Esta opcao
	  so' funciona se voce^ possuir uma MegaRAM.  O  arquivo  ROM  do
	  Game Master I deve possuir o nome de  GMASTER.ROM  e  estar  no
	  mesmo drive do ExecROM se voce estiver usando o MSXDOS1.Se voce
	  estiver usando o MSXDOS2, o Game Master deve estar no diretorio
	  do ROM carregado ou no diretorio local.
	  ATENCAO: o Game Master I da Konami so' funciona com os jogos da
		   Konami (que podem ser de qualquer  tamanho,  inclusive
		   de 16 e 32k).

opcao /G2:carrega o Game Master II da Konami com o arquivo ROM.Esta opcao
	  so' funciona se voce possuir  uma  MegaRAM  e, no minimo,  128k
	  de Memory Mapper. Para utilizar as funcoes  de  disco  do  Game
	  Master II voce deve possuir pelo menos 160k de  Memory  Mapper,
	  caso contrario elas serao desabilitadas. O arquivo ROM do  Game
	  Master II deve possuir o nome de GMASTER2.ROM e estar no  mesmo
	  drive do ExecROM se voce estiver usando o MSXDOS1.Se voce esti-
	  ver usando o MSXDOS2,o Game Master II deve estar  no  diretorio
	  do ROM carregado ou no diretorio local.
	  ATENCAO: o Game Master da Konami II so' funciona com  os  jogos
		   da Konami (que podem ser de qualquer tamanho,inclusive
		   de 16 e 32k).

opcao /H: mostra um resumo da utilizacao do programa (em ingles).

opcao /I: desabilita o auto-carregamento de arquivo de "patch".  A  secao
	  08 fornece maiores informacoes sobre este arquivo de "patch".

opcao /K: desabilita o auto-carretamento do arquivo de paleta. Sem essa
          opcao o ExecROM carregara' automaticamente a paleta externa de
          um arquivo que tenha o mesmo nome da ROM, mas com a extensao
          PLT.

opcao /M: apaga o MSXDOS da memoria  e  reinicializa  todos  os   ganchos
	  ("hooks") do MSX antes de executar o cartucho. Alguns jogos ne-
	  cessitam desta opcao.

opcao /N: carrega os ROMs de 16k ou 32k na MegaRAM (se detectada), e  nao 
	  na RAM do MSX.

opcao /P: carrega o arquivo de "patch" do arquivo ROM  identificado  logo
	  apos. Para maiores detalhes, veja a secao 08.

opcao /R: seleciona o tipo de MegaROM que sera' carregado (de 0 a 5). A i
	  dentificacao do mapeamento dos MegaROMs pelo ExecROM e' automa-
	  tica, mas, se voce, por algum motivo, desejar faze-lo,  utilize
	  esta opcao. A identificacao vem apos a opcao. Obvio, esta opcao 
	  so' fuciona para MegaROMs. O default e' o tipo  0,  conforme  a
	  lista:

				   0 - Konami 8kb        1 - Konami4/16kb
				   2 - Konami4/8kb       3 - Konami5/8kb
				   4 - ASCII/8kb         5 - ASCII/16kb

	  A identificacao dos MegaROMs e' igual `a do  emulador  fMSX  de
	  Marat Fayzullin. 
		    
opcao /S: coloca assinatura de cartucho no arquivo ROM carregado. Se voce
	  esta' carregando cartuchos de expansao do BASIC, programas resi
	  dentes (Eddy2, HotAsm, MegaAssembler, Logo, etc) ou  mesmo  al-
	  guns jogos, voce deve usar a opcao /S. Isto e'  devido  ao fato
	  de que o ExecROM desabilita a assinatura de cartucho do arquivo
	  ao carrega-lo. A nao existencia da assinatura de  cartucho  lhe
	  permite resetar seu MSX sem voltar ao jogo,sem ter que desliga-
	  lo para isso.

opcao /T: engana o cartucho ROM, fazendo-o identificar seu MSX como um ou
	  tro tipo, identificado logo apos. As opcoes disponiveis sao:

		I - MSX internacional           J - MSX japones
		1 - MSX1                        2 - MSX2       
		+ - MSX2+                       T - MSX Turbo-R

	  A opcao /T nao possui efeito em arquivos que nao sejam MegaROM.
	  ATENCAO: O ExecROM NAO FAZ modificacoes de hardware no seu MSX.
		   Se voce executa no seu MSX1 um cartucho de MSX2 com  a
		   opcao /T2, o programa ROM provavelmente ira' travar  o
		   micro, pois o hardware do MSX1 e do MSX2 e' diferente.

opcao /U: esta opcao faz o ExecROM nao habilitar o SCC mesmo se ele esti-
          ver conectado ao seu MSX e a ROM sendo carregada  for  um  jogo
          da Konami com SCC.

opcao /X: esta opcao faz o ExecROM voltar ao MSXDOS apos carregar o arqui
	  vo ROM na memoria.

opcao /Y: aceita automaticamente todas as modificacoes propostas nos  ar-
	  quivos de "patch" carregados.

opcao /Z: executa o arquivo ROM em modo R800  DRAM  se  seu  MSX  for  um
	  Turbo-R. Por default o ExecROM executa os arquivos ROM em  modo
	  Z80 no Turbo-R.

OBSERVACOES: as paginas, enderecos e bytes DEVEM ser dados em formato he-
	     xadecimal. Eles nao necessitam ter exatamente dois ou quatro
	     bytes (por exemplo: 0Dh pode ser 0D ou D; 12Fh pode ser  12F
	     ou 012F).

	     apenas forneca indicacao de pagina em jogos MegaROM.  Cartu-
	     chos com 16k or 32k nao requerem indicacao de pagina por se-
	     rem tratados de forma linear.

Exemplos:

* para executar o jogo MegaROM GAME01.ROM do drive B, mudando o  byte  no
  endereco 3Eh para 64h,  preenchendo a area de 1850h a 18A0h  da  pagina
  5h com o byte 40h e fazendo o jogo pensar que seu MSX e' japones:

  ExecROM /c3e,64 /f5,5,1850,18a0,40 /tj b:game01

* para executar o jogo de 32Kb GAME02.ROM do drive atual, mudando o  byte
  no endereco 21h para 0Fh e preenchendo a area de 2320h a  30A0h  com  o
  byte 10h:

  ExecROM /c21,f /f2320,30a0,10 game02

* para carregar o utilitario de 16Kb UTIL01.ROM que esta' em outro disco,
  sem apagar sua assinatura e resetando o MSX para que o cartucho seja e-
  executado:

  ExecROM /d /s /b util01

* para carregar o jogo MegaROM da Konami GAME03.ROM, do tipo  Konami4/16k
  no drive C, ativando o Game Master I, apagando o MSXDOS da memoria ao e
  xecuta-lo e fazendo o jogo pensar que seu MSX e' um MSX2 internacional:

  ExecROM /g1 /m /r1 /ti /t2 c:game03

* para carregar o jogo MegaROM GAME04.ROM, fazendo-o identificar o MSX co
  mo de fabricacao japonesa e carregando o arquivo de "patch" PATCH01.XPC

  ExecROM /tj /ppatch01 /r0 game04


	07. Modificando cartuchos ROM com o ExecROM
	    ---------------------------------------

	Foi mostrado que o ExecROM pode mudar arquivos  ROM, como  jogos,
para conseguir vidas infinitas, imunidade, etc. Mas a maioria destas adul
teracoes sao para jogos em formato binario, que e'  diferente do  formato
ROM.        
	Para usar estas adulteracoes no ExecROM voce tem  que  recalcular
o endereco a alterar. Segue um exemplo para um jogo de 32k e  que  contem
os procedimentos basicos para a adaptacao.
	Suponha que voce tenha um jogo de 32k em formato  binario  e  seu
carregador BASIC seja o  listado abaixo. Suponha que as linhas 30  40 mo-
dificam o jogo para lhe dar imunidade. Suponha tambem que voce  tem  este
mesmo jogo no formato ROM.
		
	10 cls:print"Carregando jogo..."
	20 bload"game-1.bin"
	25 ' * Inicio da alteracao para imunidade
	30 poke &ha320,&h30
	40 defusr=peek(&hfcbf)+256*peek(&hfcc0):a=usr(0)
	42 ' A linha 40 apenas executa o bloco 01
	45 ' * Fim da mudanca para imunidade
	50 bload"game-2.bin",r

	Se o jogo e' um cartucho de 16k ou 32k  inicialmente  voce   deve
achar os bytes de identificacao de cartucho ("AB") na memoria.E' isso que
faz a linha abaixo.

	bload"game-1.bin":for i=&h8000 to &hc000:if  peek(i)=&h41 and
	peek(i+1)=&h42 then print"Inicio:&h";hex$(i):end else next

	Suponha que a rotina lhe de^ o endereco &h9000.  Apenas  subtraia
esse endereco do endereco de imunidade para obter o endereco pro ExecROM.
Neste exemplo: &hA320-&h9000=&h1320. Apenas digite no BASIC:

	print hex$(&hA320-&h9000)

	Agora digite no DOS:

	ExecROM /p1320,30 game.rom

	Mas se o endereco a mudar estiver depois do carregamento do segun
do bloco, como abaixo?

	10 cls:print"Carregando jogo..."
	20 bload"game-1.bin",r
	30 bload"game-2.bin"
	35 ' * Inicio da mudanca para imunidade
	40 poke &ha320,&h30
	45 ' * Fim da mudanca para imunidade
	50 defusr=peek(&hfcbf)+256*peek(&hfcc0):a=usr(0)
	52 ' A linha 50 apenas executa o bloco 02

	Neste caso o procedimento mais comum e' subtrair &h8000 do endere
co a modificar. Neste exemplo obteriamos &h2320.
	Se nao funcionar, tente subtrair o endereco do  comeco  do  bloco
(que pode ser visto com qualquer leitor de cabecalho  de arquivo binario,
como o BINHEAD da A&L Software) do endereco a modificar.
	Para jogos Memory Mapper adaptados para MegaRAM nao ha' uma formu
la especifica por que os enderecos dos blocos mudam de jogo para  jogo  e
de bloco para bloco. Apenas um programador experiente de MSX  pode  faze-
lo.
	Para jogos MegaRAM a regra geral e' subtrair do endereco a modifi
car o comeco do bloco (use um leitor de cabecalho de arquivo binario).
	Para jogos com paginas de 8k, se os blocos em disco sao de 8kb de
tamanho, a pagina e' o numero do bloco menos um (assumindo o primeiro blo
co como bloco 1). Se os blocos sao de 16k, cada bloco contem 2 paginas. A
pagina e' o dobro do numero do bloco menos 2 (assumindo  que  o  primeiro
bloco e' o bloco 1). Se o endereco a modificar for maior que 2000h, incre
mente o numero da pagina e subtraia 2000h do endereco.
	Para jogos com paginas de 16kb, a pagina e' o  numero do bloco me
nos um (assumindo o primeiro bloco como bloco 1).
	Infelizmente esta tecnica nao funciona para todo e qualquer  jogo
MegaRAM, pois muitos foram modificados internamente com a adaptacao  para
a MegaRAM, o que impede que funcionem corretamente no ExecROM se  adapta-
dos.


	08. O arquivo de "patch"
	    --------------------

	O arquivo de "patch" contem uma serie de modificacoes para um ar-
quivo ROM e elas podem ter varios motivos. Adaptacao do ROM,  mudanca  de
opcoes, etc. Para jogos, o mais comum sao modificacoes para vidas infini-
tas, imunidade, etc. Recomenda-se que seu tamanho nao ultrapasse os 8kb.
	Quando um arquivo de "patch" e' carregado, cada modificacao e' a-
presentada ao usuario e este pode escolher se quer que ela seja feita  ou
nao.
	A estrutura do arquivo de "patch" e':

	/* cabecalho */
	string   ExecROM patchfile  /* identificacao */
	byte     0x1A
	byte     XY                 /* versao do arquivo X.Y (em BCD) */

	/* corpo */
	/* bloco de "patch" */
	byte     BB                 /* numero de blocos de modificacao */
	byte     EE                 /* indicativo de "patch" essencial */
	string   ...                /* identificacao do "patch" */
	byte     0x24               /* finalizador da identificacao */
	 /* blocos de modificacao */
	 byte     TT                /* tamanho da modificacao em bytes */
	 endereco AABB              /* endereco inicial da modificacao */
	 byte     PP                /* pagina a modificar */
	 bytes    ...               /* bytes de modificacao */

	/* fim */
	byte     00                   /* indica fim do arquivo */

	Quando um arquivo de  "patch"  e'  lido, a string  de identifica-
cao de cada modificacao e' apresentada em forma de pergunta (ou seja, se-
guida de um "(Y/N)?") e o usuario deve digitar uma resposta.
	Se EE, o indicador de "patch essencial", tiver valor 255  (0xFF),
a pergunta nao sera' feita e o "patch" sera' aplicado automaticamente  ao
ROM. Sao geralmente "patchs" essenciais aqueles que modificam o ROM  para
que o mesmo possa ser executado pelo ExecROM ou que sanam  algum  defeito
do ROM.
	Se a resposta for positiva ou o "patch" for essencial,os TT bytes
de modificacao sao colocados a partir do endereco AABB dado,na pagina PP.
Para arquivos 16k ou 32k o numero da pagina deve ser 00.
	O endereco e' o deslocamento relativo ao inicio da  pagina  ou ao
inicio do arquivo (ou seja, o comeco do cartucho e  da pagina e' assumido
como endereco 0000)
	Exemplo:

	'ExecROM patchfile'
	1A                             // assinatura
	10                             // versao 1.0
	01                             // este "patch" tem um bloco
	FF                             // "patch" e' essencial
	'MegaROM correction'           // definicao do "patch"
	24                             // fim da definicao do "patch"
	03 10 40 01                    // 3 bytes,endereco 4010h,pag. 01h
	28 54 72                       // dados do "patch"
	02                             // este "patch" tem dois blocos
	00                             // este "patch" vai ser indagado
	'Pula a tela inicial'          // definicao do "patch"
	24                             // fim da definicao do "patch"
	02 23 50 10                    // 2 bytes,endereco 5023h,pag. 10h
	56 8A                          // dados do "patch"
	01 14 60 05 56 8A              // 1 byte,endereco 6014h, pag. 05h
	C3                             // dado do "patch"
	00                             // fim do arquivo de "patch"


	09. Solucionando problemas no ExecROM
	    ---------------------------------

	* ATENCAO:

	a) Nao execute o ExecROM com MegaRAM Disk no slot 1; se voce  tem
	   a MegaRAM Disk no slot 1, de boot pelo disco.

	b) Nao execute o ExecROM a partir da MegaRAM RAMDisk,  ou um erro
	   travara' seu computador.
	       
	c) Geralmente, resete seu MSX com a tecla CONTROL apertada  antes
	   de executar o ExecROM se voce tem mais de um drive.

        d) Se voce esta' usando o programa DOS2TAB do Nyyrikki,  remova-o
           da memoria antes de usar o ExecROM ou o MSX pode travar duran-
           te a execucao da ROM sendo carregada.

        e) Se voce tem um SCC e sua MegaRAM esta' em um  slot  expandido,
           nao use o cartucho SCC no slot expandido. O ExecROM nao pode u
           sar o SCC se ele estiver no mesmo slot primario da MegaRAM.

	* SOLUCAO GERAL DE PROBLEMAS:
	    
	Se voce esta tendo problemas com o  ExecROM  usando  uma  MegaRAM
Disk e/ou tem mais que um drive conectado no seu MSX, tente ligar seu MSX
com a tecla DELETE apertada (para  desativar  a MegaRAM Disk  e  torna-la
MegaRAM Game) e/ou a tecla CONTROL apertada (para desativar os drives lo-
gicos).
	   
	* SOLUCAO DE PROBLEMAS ESPECIFICOS:
	
	a) Depois do carregamento o ExecROM trava o computador na  mensa-
	   gem "Executing ROM cartridge"

	   Este e' o mais generico dos problemas. Pode ser causado por um
	   erro no arquivo ROM, um erro de leitura ou mesmo  um  erro  no
	   seu MSX. Verifique se o arquivo ROM nao esta' danificado. Veri
	   fique  se  existe um arquivo  de  patch  necessario  para  ele
	   executar.  Resete   seu  MSX  e  tente  carrega-lo  novamente.
	   Alguns cartuchos  requerem algumas "condicoes especiais",  que
	   podem ser providas pelo ExecROM, para executarem. Alguns preci
	   sam do identificador de cartucho ou do reset do MSX ou de  am-
	   bos. Estes casos sao resolvidos com as opcoes /S (que coloca o
	   identificador de cartucho no arquivo ROM) e /B (que reseta seu
	   MSX para executar o arquivo ROM).Tente usar uma das duas ou as
	   duas opcoes com o arquivo ROM. Se ainda assim ele  nao  rodar,
	   veja o "SOLUCAO GERAL DE PROBLEMAS".
	   Aqui' estao alguns cartuchos que requerem opcoes especiais pa-
	   ra serem executados:
				Cartucho                        Opcoes

				 Elevator Action                 /S
				 Kung Fu Master                  /S /B
				 Star Force                      /S /B
				 Crazy Train                     /B

	b) Quando o arquivo ROM e' executado imagens  estranhas  aparecem
	   na tela e o computador trava
	   
	   Veja o topico anterior.
	   
	c) Cartuchos residentes nao sao habilitados quando carregados com
	   o ExecROM
 
	   Para cartuchos residentes voce deve usar a opcao /S no ExecROM
	   ou eles nao serao habilitados. Veja "Como usar o ExecROM" para
	   detalhes.
	   
	d) As modificacoes ("patchs") no arquivo ROM nao sao feitas
 
	   i)  . A pagina, endereco e byte do patch estao corretas?
	   ii) . Voce digitou os dados em formato hexadecimal?
	   iii). Voce nao recebeu a mensagem "Error in patch request"?
	   
	e) Depois de um erro no ExecROM o computador trava
	
	   Voce provavelmente esta' usando uma MegaRAM Disk e executou  o
	   ExecROM no drive da MegaRAM Disk. Execute o  ExecROM a  partir
	   do diskette ou resete seu MSX com a tecla DELETE apertada.  Se
	   o problema persistir, reinicie seu MSX a partir do   diskette, 
	   nao a partir da MegaRAM Disk.
	   
	f) O MSX trava apos a identificacao do computador
	
	   Veja o topico anterior.
	   
	g) O ExecROM e' reexecutado ou mensagens estranhas aparecem quan-
	   do  as  mensagens  "Stopping  the  drive"  ou  "Executing  ROM 
	   cartridge" aparecem

	   Veja "SOLUCAO GERAL DE PROBLEMAS".
			   
	h) O Game Master nao funciona com um jogo
	
	   O Game Master so' funciona com jogos da Konami. O jogo em ques
	   tao e' da Konami?
	   
	i) O ExecROM nao carrega o Game Master I ou II
	
	   i)  . O arquivo do Game Master tem nome de GMASTER.ROM (para o 
		 Game Master I) ou GMASTER2.ROM (para o Game Master II)?
	   ii) . Voce^ tem certeza que o arquivo e' o Game Master?
	   iii). Voce^ tem uma MegaRAM para usar o Game Master?
	   iv) . No caso de estar executando o Game Master  II, voce  tem
		 certeza que seu MSX possui pelo  menos  128k  de  Memory
		 Mapper?
           v)  . Voce tem certeza que as sua ROM do Game Master e' origi-
                 nal? O ExecROM nao ira' carregar o Game Master (I ou II)
                 se ele nao for original.

	j) O Game Master II nao grava ou le do disco
	
	   As funcoes de disco do Game Master II so' funcionam no ExecROM
	   se seu MSX possuir 160k ou mais de Memory Mapper.

	k) Usando a opcao /X, ao sair para o BASIC o MSX trava

	   Este e' um bug existente no ExecROM que ainda nao foi  sanado.
	   Por favor, aguarde que uma futura versao tenha esse erro  cor-
	   rigido.

        i) O ExecROM nao habilita o SCC em um jogo da Konami,  mesmo  ele
           sendo detectado.

           Verifique se o ExecROM reconhece o jogo da Konami que voce es-
           ta' executando atraves das mensagens exibidas  pelo  programa.
           Se o ExecROM nao o reconhece, entao o SCC nao sera'  habilita-
           do. Procure outra ROM do jogo, pois a sua pode estar corrompi-
           da ou alterada.

        j) O ExecROM reconhece o jogo da Konami e  habilita  o  SCC,  mas
           o MSX trava ao comecar o jogo.

           i)  . Verifique se voce nao esta' com o  programa  DOS2TAB  do
                 Nyyrikki carregado na memoria.
           ii) . Tente remover qualquer programa residente da memoria an-
                 tes de executar o ExecROM.
           iii). Tente usar outra ROM do mesmo jogo. O ExecROM, para habi
                 litar o SCC, faz modificacoes em lugares especificos  da
                 ROM do jogo. Se a ROM que voce esta' usando foi modifica
                 da, com grande chance as modificacoes que o ExecROM  faz
                 irao corromper o jogo, e nao habilitar o SCC.


	10. Creditos, uso, copia e agradecimentos
	    -------------------------------------

	O programa ExecROM e' freeware, ou seja, e' gratis. Voce nao pre-
cisa pagar por ele. Mas  voce so' pode usa-lo, copia-lo ou  distribui'-lo
se nao  remover  o  nome  do  autor  e  incluir  sempre  os  3  arquivos:
ExecROM.COM, ExecROM.ENG e ExecROM.POR.
        O ExecROM 1.2c pode executar cerca de 80% dos MegaROMs de MSX sem
precisar de arquivo de "patch" and quase todos os ROMs de 16k e  32k.  Se
voce descobrir qualquer bug ou tiver qualquer ideia ou comentario, deixe-
nos saber. Se um arquivo ROM nao funciona com voce (por favor, veja a so-
lucao de problemas primeiro!), conte-nos e, se possivel, mande-nos uma co
pia do seu arquivo ROM para que possamos resolver o problema mais rapido.
Se voce criou um arquivo de "patch" para algum ROM, por favor,  envie-nos
uma copia.
	A&L Software gostaria de agradecer a todo o pessoal ativo da lis-
ta MSX Broadcast da Unesp, SP, Brasil pelos testes, ideias, bugs e comen-
tarios.
	Agradecimentos especiais (sem ordem de preferencia):Marco Antonio
Simon Dal Poz, pela sua ajuda sobre a MegaRAM;  Fabio Ricardo  Schmidlin,
Giovanni Nunes e Werner Kai (MSX Core Club), pelas inumeras boas ideias e
dicas para o ExecROM; Daniel Caetano pela implementacao inicial  do  Game
Master II no ExecROM; Leonard Oliveira pela ajuda na deteccao do SCC e i-
deia de utilizacao de MSXDOS2;  Mauricio Braga pela ideia  de suporte `as
ROMs do Konami Game Collection; Ricardo Bittencourt pela ideia de  detec-
cao automatica do tipo de MegaROM.
	A paleta "CoolColors" e sua ideia de inclusao no ExecROM e' de au
toria de Fabio Ricardo Schmidlin e foi usada com permissao.
        O ExecROM e' copyright (c) 1996-1999,2001-2004 A&L Software. Con-
tacte em:

        alsoftware@alsoftware.com.br
        http://www.alsoftware.com.br

        A pagina de MSX da A&L Software pode ser encontrada em:

        http://www.alsoftware.com.br/adrianpage/

	E lembre-se: MSX agora e sempre!
