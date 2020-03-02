# Especificaciones:

- MSX1
- Memoria mapeada: 128K (ZX-Uno de 512 KB) o 1024K (ZX-Uno de 2MB) 
- Puede trabajar a 50Hz (PAL) o a 60Hz (NTSC)
- Utiliza el sistema operativo Nextor-DOS, el cual es una versión ampliada y mejorada del MSX-DOS, con el cual es 100% compatible, unido a un driver para trabajar con tarjetas SD formateadas en FAT16. Permite cargar ficheros .CAS (imágenes de casetes) y .DSK (imágenes de disquetes)
- Megaram SCC/SCC+ del proyecto OCM de 256K. Permite cargar ficheros .ROM los cuales son volcados de cartuchos.
- 512K of ESE-SCC   (solo ZX-Uno de 2MB)
- Teclado configurable en varios idiomas: Español, Inglés, Portugués de Brasil y Francés.
- Salida de video VGA (Scandoubler), RGB 15/31 Khz y CVBS video (video compuesto)
- Scanlines
- Modo Turbo (7MHz)
- Permite la carga de ficheros por audio

## INSTRUCCIONES DE USO DEL CORE:

Formatear una tarjeta SD en FAT16 (máx 4GB) y descomprimir el fichero 'msx1_sd_files.zip' en el directorio raíz de la tarjeta SD.

### NOTA IMPORTANTE 2018.05.12: Al descomprimir el fichero 'msx1_sd_files.zip' se crea la carpeta MSX1FPGA, y dentro de ella se encuentra el fichero SPA.KMP con la definición de las teclas para el teclado español. Esta definición contiene numerosos errores, por ejemplo, las comillas no están en su sitio o bien es imposible conseguir el paréntesis de cierre. Podéis conseguir una definición alternativa del teclado español sin esos errores desde esta entrada (http://www.zxuno.com/forum/viewtopic.php?f=53&t=2087)

CTRL+ALT+DEL es Soft reset, CTRL+ALT+F12 es Hard reset (reinicia la máquina MSX como si la hubieses apagado) y CTRL+ALT+BACKSPACE resetea el ZX-Uno.

El puerto del joystick para placas Multicore se asigna como JoyMega y se configura para usar un joypad SEGA Genesis / Megadrive. Otras placas se asignan como un solo joystick / joypad con 2 botones.

Para cargar una ROM en el SCC Megaram se usa el comando ROMLOAD.COM (está en los ficheros de 'msx1_sd_files.zip') con '/S' para que comience inmediatamente. Ejemplo:  ROMLOAD game.rom /S

Para ir al BASIC desde el MSX-DOS se debe ejecutar el comando BASIC
Para ir al MSX-DOS desde el BASIC se debe ejecutar CALL SYSTEM

## Teclas del CORE:

- **CTRL+ALT+SUP/Del** = Soft Reset del MSX
- **CTRL+ALT+F12** = Hard Reset del MSX. Si tienes cargada una rom con esto se descarga.
- **CTRL+ALT+BACKSPACE** = Resetea el ZX-Uno 

- **Print Screen / Impr Pant** = Alterna modo de video entre VGA y  RGB 15 KHz / CVBS video 
- **Scroll Lock / Bloq. Despl** = Alterna a modo con Scanlines o sin ellas.
- **F11** = Alterna a modo Turbo o normal.

Y usando el teclado español alternativo:

- **Right Alt / Alt Gr** = Tecla CODE del MSX
- **Left Alt / Alt** = Tecla GRAPH del MSX
- **Tecla Menú o Page Up / Re Pág** = Tecla SELECT del MSX
- **Home / Inicio** = Tecla HOME del MSX  (SHIFT + HOME --> CLS)
- **End / Fin** = Tecla STOP del MSX
- **Ñ o Tecla Windows** = Tecla DEAD del MSX


NOTAS:

- En BASIC usar las teclas "CTRL+STOP" para parar la ejecución de un programa. La tecla STOP de MSX está mapeada a la tecla END/Fin del PC.
- Para cambiar el modo de vídeo conmutando entre 50HZ y 60HZ, y de ese modo jugar a velocidad correcta a los juegos PAL, como "Invasion of the Zombie Monsters", a través de la salida VGA, se puede usar el programa "DISPLAY.COM", que está para descargar en este hilo  (https://www.msx.org/forum/msx-talk/software/dos-tool-to-switch-from-50-to-60hz).


## CARGA DE PROGRAMAS:

### A.- FICHEROS .ROM

Son volcados de programas en cartuchos. Para archivos de 48K o menos, utilizar el programa ODO.COM (hOndonadas De hOstias).

#### ODO is a ROM loader for MSX1 and up, running MSX-DOS (supports MSX-DOS2 too). It can load and play ROM files up to 48K in RAM. ROMs that execute from page 0 are supported as well. 

Podéis descargaros la versión 0.4 desde aqui (http://msxbanzai.tni.nl/dev/software.html), y colocar luego el archivo "ODO.COM" en la carpeta "\util" de la tarjeta SD.

Para ficheros .ROM de más de 48K, usar el comando **ROMLOAD**. Se puede usar de dos formas:

 *1ª*: ROMLOAD fichero.ROM  /S  (el "/S" fuerza a la ejecución del programa), o
 *2ª*: fichero /S  (el nombre del fichero .ROM sin la extensión)

Si no se pone el /S es necesario realizar un Soft Reset (CTRL+ALT+DEL/Supr) para que se ejecute el programa. 
Por defecto el sistema de mapeo de memoria que utiliza es el de Konami. Si se trata de juegos que no son de Konami, como Golvellius o el Abu Simbel Profanation, hay que cambiar el "/S" por "/A"  o "/1" - mapper ASCII8 y ASCII16 respectivamente - (se prueba uno u otro hasta encontrar el que funcione). Por ejemplo:  ROMLOAD ascii8.rom /A /S

De todas formas, en la carpeta "\util" de la SD hay 2 ficheros: ROMLOAD.TXT con instrucciones de como usar este comando, y ROMLOAD.LST con una lista de juegos y las opciones que hay que usar para que carguen.


### B.- FICHEROS .DSK

Para ello hay dos formas, usando el comando **EMUFILE** o el comando **MAPDRV**. Supongamos que el disco del programa *Cuerpo Humano: Sistema Circulatorio* se llama CH-CIRCU.DSK, lo podremos cargar de estas dos formas:

#### 1ª FORMA. EMUFILE

```
EMUFILE CH-CIRCU.DSK -r
```

Este comando crea un fichero **NEXT_DSK.DAT** en el directorio raíz de la tarjeta SD con el contenido del disquete, y la opción "-r" fuerza un Soft Reset que hará que cuando vuelva a arrancar el Nextor-DOS cargue automáticamente el disquete.

Cada vez que arranquemos el ordenador se ejecutará el disquete, a menos que lo borremos. Para evitarlo, cuando arranque el ordenador debemos tener pulsada la tecla "0" (cero), y eso hará que no se cargue el disquete. En ese momento podemos borrar el archivo con un  ERASE NEXT_DSK.DAT o DEL NEXT_DSK.DAT.

Para ver todas las opciones que tiene el comando EMUFILE, ejecutarlo simplemente tecleando su nombre. El comando permite el que se puedan montar varios disquetes a la vez, útil, por ejemplo, para un juego multi-disquete.


#### 2ª FORMA. MAPDRV

Este comando monta el contenido de la imagen de un disquete en una nueva unidad de disco. Por ejemplo:

```
MAPDRV B: CH-CIRCU.DSK
```

Ahora podemos ir a la unidad B: y ver los ficheros. Vemos que hay un fichero AUTOEXEC.BAS, el cual podemos ejecutar simplemente con AUTOEXEC, y el programa ya arranca.


#### Nota importante 2018.05.13: Hay imágenes de disquete que a veces no funcionan, y es posible que un mismo juego tenga varias versiones. Por ejemplo, en (http://www.planetemu.net/roms/msx-various-dsk?page=A) veréis hasta 4 versiones en .dsk del juego "La Abadía del Crimen". Solo me ha funcionado la etiquetada como "Abadia del Crimen, La (1988)(Opera Soft)(es)[a3]". Una forma sencilla de comprobar si la imagen .dsk tiene algún problema es usar el emulador de MSX on-line WebMSX (http://webmsx.org), configurarlo como MSX 1, europeo o americano, según lo que queráis, y arrastar el fichero .dsk para probarlo. En el caso anterior, ninguna de las otras 3 versiones de La Abadía me funcionaron, y solo la que funcionaba en el WebMSX funcionó también en el ZX-Uno.


### C.- FICHEROS .CAS

Son imágenes con el contenido de las cintas de audio. La forma de utilizarlas está muy bien explicado en el artículo Cargar archivos CAS con MegaFlashROM y un MSX-2 (https://programbytes48k.wordpress.com/2015/11/19/cargar-archivos-cas-con-megaflashrom-y-un-msx-2/)   

Los ficheros **LOADCAX** y **LOADCAXX** se encuentran en la carpeta BIN del disquete http://www.msxcartridgeshop.com/bin/ROMDISK.DSK del MegaFlashROM SCC+ SD. Como hemos visto antes, con MAPDRV podemos acceder a su contenido y extraerlos.


### D.- FICHEROS .BAS

Son programas en BASIC que podemos grabar en la SD, y también cargarlos para ejecutarlos. Desde dentro del BASIC podremos teclear:

```
SAVE "A:HOLA.BAS"
```

para salvar el programa, y con 

```
LOAD "A:HOLA.BAS"
```

lo recuperamos. 

Para saber las diferencias entre CSAVE, BSAVE y SAVE, u otros comandos para almacenar y recuperar la información, se puede consultar este apartado (https://www.msx.org/wiki/Category:Disk_BASIC) con comandos del Disk BASIC  del wiki de msx.org (https://www.msx.org/wiki/).

Para cargar un fichero .BAS desde el Nextor-DOS, simplemente escribimos su nombre con o sin extensión y pulsamos ENTER.


### E.- ENTRADA AUDIO

El core permite la carga de programas por audio.  La forma de  hacerlo es desde BASIC con los comandos:

```
RUN”CAS:”
```
o bien
```
BLOAD”CAS:”,R
```
o bien:
```
LOAD”CAS:”,R
```

Está perfectamente explicado en el artículo Cómo cargar programas en MSX (https://programbytes48k.wordpress.com/2012/01/04/como-cargar-programas-en-msx/).

Si se quiere oir el audio de la carga será necesario utilizar la versión del core "1.2 rev. jepalza", ya que las versiones sintetizadas por Fabio no reproducen el sonido de carga, como también ocurría en ciertos MSX reales.

En (http://www.vintagenarios.com/hilo-oficial-wavs-msx-t1997.html) del foro de **Vintagenarios** se pueden encontrar multitud de programas de MSX en formato WAV que se pueden cargar por audio.
