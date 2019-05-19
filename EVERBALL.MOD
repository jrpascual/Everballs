MODULE everball;
IMPORT IO, MsMouse, Storage;
FROM Storage IMPORT ALLOCATE,DEALLOCATE;
IMPORT FIO;
IMPORT ver, bmp;
IMPORT tablero;
IMPORT juego;
IMPORT Graph;
IMPORT Lib;
FROM Window IMPORT Clear;

(* Variables globales: Direcciones de memoria donde se encuentran los sprites
   de las bolas y los huecos *)

VAR
	bola, maskbola, huecos, maskhue, imagen, fondotitle: ADDRESS;
    title, reemplazar: bmp.SPRITE_D;
(* -------------------------------------------------------------- *)

PROCEDURE Obtener_Sprites();
VAR
BEGIN
	Storage.ALLOCATE(maskbola,CARDINAL(Graph.ImageSize(256,3,281,26)));
	Storage.ALLOCATE(bola,CARDINAL(Graph.ImageSize(288,3,313,25)));
	Storage.ALLOCATE(huecos,CARDINAL(Graph.ImageSize(256,3,281,26)));
	Storage.ALLOCATE(maskhue,CARDINAL(Graph.ImageSize(288,3,313,25)));
	Graph.FloodFill(298,2,255,0);
	Graph.FloodFill(250,2,255,0);
	Graph.GetImage(273,1,294,20,huecos);
	Graph.GetImage(297,1,318,20,maskhue);
	Graph.GetImage(249,1,271,21,maskbola);
	Graph.GetImage(224,1,246,21,bola);	

END Obtener_Sprites;

(* ------------------------------------------------------------------ *)

VAR
	paleta : ver.TipoPaleta;
	fich : FIO.File;
	tabla,fase : tablero.tabler;
	nombre : ARRAY [0..7] OF CHAR;
	c : CHAR;
	correcto : BOOLEAN;
	card : CARDINAL;
	pos : Graph.TextCoords;
    Comenzado : BOOLEAN;
    timer : juego.TipoTiempo;
    progreso: CARDINAL;
BEGIN
	correcto:= Graph.SetVideoMode(19);
    fich:= bmp.OpenBMP("cargando",correcto);
	bmp.FadeIn(fich);
	(*
	fich:= ver.OpenBMP("ever",correcto);
    IF correcto THEN
		ver.FadeIn(fich);
		ver.coge_paleta(fich,paleta);
		ver.FadeOut(paleta);
		FIO.Close(fich);
	ELSE
		HALT;
	END;
	fich:= ver.OpenBMP("presenta",correcto);
	IF correcto THEN
	   ver.FadeIn(fich);
	   ver.coge_paleta(fich,paleta);
	   ver.FadeOut(paleta);
	   FIO.Close(fich);
	END;
	fich:= ver.OpenBMP("everb",correcto);
	IF correcto THEN
		ver.FadeIn(fich);
		ver.coge_paleta(fich,paleta);
		c:= IO.RdKey();
		ver.FadeOut(paleta);
		FIO.Close(fich);
	ELSE
		HALT;
	END; *)
      Graph.Rectangle(43,149,263,158,15,FALSE);
      fich:= bmp.OpenBMP("title",correcto);
      IF correcto THEN
       progreso:= 0;
       title:= bmp.DCSPRITE(fich,85,158,164,174, progreso);
       reemplazar:= bmp.DCSPRITE(fich,84,140,205,157,progreso);
       Lib.Delay(1000);
      ELSE HALT; END;
    fich:= ver.OpenBMP("menu",correcto);
    IF correcto THEN
        	ver.FadeIn(fich);
        	FIO.Close(fich);
	ELSE
		HALT;
	END;
	
	REPEAT
		IO.RdLn;
		IF FIO.Exists("fase") THEN
			fich:=FIO.Open("fase");
			juego.CargarJuego(fase,timer,fich);
			FIO.Close(fich);
		ELSE
			HALT;
		END;
		CASE juego.Menu() OF
			"1":
				Graph.ClearScreen(Graph._GCLEARSCREEN);
				fich:= ver.OpenBMP("everball",correcto);
				IF correcto THEN
				(* sprite:= ver.coge_sprite(fich,8,8,35,33);
				   hueco:= ver.coge_sprite(fich,55,8,82,33); *)
				
				   ver.muestra(fich);
				   Obtener_Sprites;
      			FIO.Close(fich);
				ELSE
				HALT;
				END;
				tablero.IniciarTab(tabla);
				Comenzado:= Lib.SetTime(0,0,0,0);
				juego.Jugar(fase,tabla,bola,maskbola,huecos,maskhue,Comenzado,timer);
			
			|"2":
				(* Graph.ClearScreen(Graph._GCLEARSCREEN);
				IO.WrLn; IO.WrStr("            ");
				IO.WrStr("Nombre: "); *)
		(* Nuevo *)
				bmp.DMASCARA(title,85,162,TRUE);
				pos:= Graph.SetTextPosition(22,22);
				REPEAT
					IO.RdStr(nombre); IO.RdLn;
				UNTIL nombre[1] <> CHR(0);
				IF NOT FIO.Exists(nombre) THEN
					IO.WrStr("El fichero especificado no existe");
					IO.WrLn;
					IO.WrStr("Pulse una tecla para continuar...");
					c:=IO.RdKey();
				ELSE
				fich:= ver.OpenBMP("everball",correcto);
				IF correcto THEN
				    ver.muestra(fich);
					Obtener_Sprites;
				FIO.Close(fich);
				ELSE
				HALT;
				END;
				fich:= FIO.Open(nombre);
				juego.CargarJuego(tabla,timer,fich);
				FIO.Close(fich);
				juego.Jugar(fase,tabla,bola,maskbola,huecos,maskhue,Comenzado,timer);
				END;|
					
			"3":
			    IO.RdLn;
	(* Nuevo *)	ALLOCATE(fondotitle,CARDINAL(Graph.ImageSize(85,162,220,178)));
				Graph.GetImage(85,162,220,178,fondotitle);
				bmp.DMASCARA(title,85,162,TRUE);
				pos:= Graph.SetTextPosition(22,22);		
                IO.RdStr(nombre);
                Graph.PutImage(85,162,fondotitle,Graph._GPSET);
   			
                IF FIO.Exists(nombre) THEN
                bmp.DMASCARA(reemplazar,85,162,TRUE);	
					IO.RdLn;
					c:=CAP(IO.RdKey());
					Graph.PutImage(85,162,fondotitle,Graph._GPSET);
					IF c='Y' THEN
						fich:=FIO.Create(nombre);
						juego.GrabarJuego(tabla,timer,fich);
						FIO.Close(fich);
					END;
				ELSE
					fich:=FIO.Create(nombre);
					juego.GrabarJuego(tabla,timer,fich);
					FIO.Close(fich);
				END;
				DEALLOCATE(fondotitle,CARDINAL(Graph.ImageSize(85,162,220,178)));

			|"4":
					Graph.ClearScreen(Graph._GCLEARSCREEN);
					fich:= ver.OpenBMP("everball",correcto);
					IF correcto THEN
					(* sprite:= ver.coge_sprite(fich,8,8,35,33);
					   hueco:= ver.coge_sprite(fich,55,8,82,33);
					   ver.muestra(fich);
                       Obtener_Sprites; *)
					FIO.Close(fich);
					ELSE
					HALT;
					END;			
					Comenzado:= Lib.SetTime(timer.hora,timer.minu,timer.seg,0);
					juego.Jugar(fase,tabla,bola,maskbola,huecos,maskhue,Comenzado,timer);	
		
			|"5":
				  Graph.ClearScreen(Graph._GCLEARSCREEN);
				  fich:= ver.OpenBMP("sobre",correcto);
		          IF correcto THEN
		         	ver.coge_paleta(fich,paleta);
		         	ver.FadeIn(fich);
		         	c:= IO.RdKey();		
		            ver.FadeOut(paleta);
		            FIO.Close(fich);
		          ELSE
		          	HALT;
		          END;		
				
		  END;	
	IO.RdLn;
	UNTIL juego.Menu() = "6";	
(* fich:= ver.OpenBMP("creditos",correcto);
	IF correcto THEN
		ver.FadeIn(fich);
		FIO.Close(fich);
	ELSE
		HALT;
	END;     *)
	c:= IO.RdKey();
	ver.Telon;
	Graph.TextMode;
END everball.
