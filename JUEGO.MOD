IMPLEMENTATION MODULE juego;
IMPORT bmp;
IMPORT tablero;
IMPORT IO;
IMPORT Graph;
IMPORT MsMouse;
IMPORT Storage;
IMPORT Lib;
IMPORT FIO;
FROM MsMouse IMPORT MsGraphcur;

(* ---------------------------------------------------------------- *)

PROCEDURE Sprite_con_Mask(sprite,mascara: ADDRESS; x,y : CARDINAL);
VAR
BEGIN
	Graph.PutImage(x,y,mascara,Graph._GAND);
	Graph.PutImage(x,y,sprite,Graph._GOR);	

END Sprite_con_Mask;

(* ---------------------------------------------------------------- *)



PROCEDURE Jugar(fase: tablero.tabler; VAR table : tablero.tabler;
				bola,maskbola,hueco, maskhue: ADDRESS; VAR Comenzado : BOOLEAN; VAR Timer : TipoTiempo);
VAR
  existe, pulsado : BOOLEAN;
  Fi : FIO.File;
  tecla : CHAR;
  data : MsMouse.MsData;
  x, y,X2, Y2, sonido, hsec, color, reservaX, reservaY,xf,yf : CARDINAL;
  resx, resy, numero_bolas, antx,anty : INTEGER;
  fondo, reserva : ADDRESS;
  tamano:LONGCARD;
  Coordenadas : Graph.TextCoords;

PROCEDURE retorna(VAR fondo,reserva:ADDRESS; xf,yf,xr,yr:CARDINAL);
BEGIN
	Graph.PutImage(xf,yf,fondo,Graph._GPSET);
	DISPOSE(fondo);
	Graph.PutImage(xr,yr,reserva,Graph._GPSET);
	DISPOSE(reserva);
END retorna;	
	
BEGIN
    pulsado := FALSE;
    numero_bolas:= tablero.numBolas(table);
    tablero.ImprimeTab(table,fase,bola,maskbola,hueco,maskhue);
    x:=0;
    y:=0;
    LOOP
    	 MsMouse.Cursor(TRUE);
         REPEAT  (* REPITE HASTA PULSARSE EL BOTON IZQUIERDO DEL RATON*)
              color:= Graph.SetTextColor(25);
              Coordenadas:= Graph.SetTextPosition(2,31);
              Lib.GetTime(Timer.hora,Timer.minu,Timer.seg,hsec);
              IO.WrCard(Timer.hora,1); IO.WrStr(":"); IO.WrCard(Timer.minu,1);
              IO.WrStr(":"); IO.WrCard(Timer.seg,1); IO.WrStr(":"); IO.WrCard(hsec,1);
              MsMouse.GetPress(1,data);
              IF IO.KeyPressed() THEN EXIT END;
         UNTIL data.left_pressed;
         MsMouse.Cursor(FALSE);

        (*  MsMouse.Cursor(TRUE); *)
         MsMouse.GetStatus(data);
         IF ((data.row>10) AND (data.row<185) AND (data.col>120)
            AND (data.col<500)) THEN
            x:= (CARDINAL(data.row) - 10) DIV 25;
            y:= (CARDINAL(data.col+6) - 120) DIV 54;
            IF table[x,y] THEN    (* SI HAY UNA BOLA DONDE SE HA PULSADO*)
               reservaY:=x*25+10;
               reservaX:=y*27+60;
               ALLOCATE(reserva,CARDINAL(Graph.ImageSize(reservaX,reservaY,reservaX+27,reservaY+25)));
               Graph.GetImage(reservaX,reservaY,reservaX+27,reservaY+25,reserva);
               Lib.Sound(200);
               Lib.Delay(100);
               Lib.NoSound;
               Lib.Sound(300);
               Lib.Delay(100);
               Lib.NoSound;
               MsMouse.Cursor(FALSE);
               pulsado:= TRUE;
      (* *)    Sprite_con_Mask(hueco,maskhue,(y*27+60),(x*25+10+1));
               anty:= data.row;
               antx:= data.col DIV 2;

               REPEAT
                  MsMouse.GetRelease(1,data);   (* Hasta soltarse *)
               UNTIL (NOT data.left_pressed);

               ALLOCATE(fondo,CARDINAL(Graph.ImageSize(antx,anty,(antx)+25,anty+23)));
               Graph.GetImage(antx,anty,antx+25,anty+23,fondo);
               REPEAT  (* Habiendo cogido la bola, hasta pulsar raton *)
                   MsMouse.GetStatus(data);
                   IF (data.row <> anty) OR (data.col DIV 2 <> antx) THEN
                   	   Graph.PutImage(antx,anty,fondo,Graph._GPSET);
                   	   DEALLOCATE(fondo,CARDINAL(Graph.ImageSize(antx,anty,antx+25,anty+23)));
                   	   ALLOCATE(fondo,CARDINAL(Graph.ImageSize(data.col DIV 2,data.row,(data.col DIV 2)+25,data.row+23)));
                   	   Graph.GetImage((data.col DIV 2),data.row,(data.col DIV 2)+25,data.row+23,fondo);
                       Sprite_con_Mask(bola,maskbola,data.col DIV 2,data.row);
                   END;
                   anty:= data.row;
                   antx:= data.col DIV 2;	
                   MsMouse.GetPress(1,data);
                   IF IO.KeyPressed() THEN EXIT END;
               UNTIL data.left_pressed;
               MsMouse.GetStatus(data);

          (*  VER SI SE HA PULSADO DENTRO DEL TABLERO    *)

(*coment*)  IF ((data.row>10) AND (data.row<185) AND (data.col>120)
                AND (data.col<500))  THEN
                  X2:= (CARDINAL(data.row)- 10) DIV 25;
                  Y2:= (CARDINAL(data.col)- 120) DIV 54;
                  resx:= INTEGER(X2) - INTEGER(x);
                  resy:= INTEGER(Y2) - INTEGER(y);

           (* VER SI SOLO SE HA PULSADO UNA DISTANCIA DE DOS HUECOS Y NO EN *)
           (* OBLICUO *)
                  IF ((resx*resy = 0) AND fase[X2,Y2]) THEN
                     IF ((resx=2) AND table[X2-1,Y2]) OR ((resy=2) AND table[X2,Y2-1])
                     OR ((resx=-2) AND table[X2+1,Y2]) OR ((resy=-2) AND table[X2,Y2+1]) THEN
                        IF (NOT table[X2,Y2])  THEN
                           table[x,y]:= FALSE;
                           table[X2,Y2]:= TRUE;

                     (* Quitamos la bola de donde est  ahora mismo *)

                           Graph.PutImage(antx,anty,fondo,Graph._GPSET);
						   DISPOSE(fondo);
						   DISPOSE(reserva);

                     (* Ahora se quita la bola que salta *)

                           MsMouse.Cursor(FALSE);
                           IF resx > 0 THEN
                              table[X2-1,Y2]:= FALSE;
                              (* ver.muestraXY(hueco,LONGINT(Y2*27+60),LONGINT((X2-1)*25+10));
                              Graph.Rectangle(Y2*27+60,(X2-1)*25+10,Y2*27+85,(X2-1)*25+33,10,TRUE);  *)

                              Sprite_con_Mask(hueco,maskhue,(Y2*27+60),((X2-1)*25+10+1));
                              numero_bolas:= numero_bolas - 1;
                           ELSIF resx < 0 THEN
                               table[X2+1,Y2]:= FALSE;
                               (* ver.muestraXY(hueco,LONGINT(Y2*27+60),LONGINT((X2+1)*25+10));
                               Graph.Rectangle(Y2*27+60,(X2+1)*25+10,Y2*27+85,(X2+1)*25+33,10,TRUE);  *)

                               Sprite_con_Mask(hueco,maskhue,(Y2*27+60),((X2+1)*25+10+1));
                           ELSIF resx = 0 THEN
                                 IF resy > 0 THEN
                                    table[X2,Y2-1]:= FALSE;
                                  (*   ver.muestraXY(hueco,LONGINT((Y2-1)*27+60),LONGINT(X2*25+10));
                                       Graph.Rectangle((Y2-1)*27+60,X2*25+10,(Y2-1)*27+85,X2*25+33,10,TRUE); *)

                                   Sprite_con_Mask(hueco,maskhue,((Y2-1)*27+60),(X2*25+10+1));
                                 ELSIF resy < 0 THEN
                                       table[X2,Y2+1]:= FALSE;
                                       (* ver.muestraXY(hueco,LONGINT((Y2+1)*27+60),LONGINT(X2*25+10));
                                       Graph.Rectangle((Y2+1)*27+60,X2*25+10,(Y2+1)*27+85,X2*25+33,10,TRUE);    *)

                                       Sprite_con_Mask(hueco,maskhue,((Y2+1)*27+60),(X2*25+10+1));
                                 END;
                           END;
                           FOR sonido:= 100 TO 500 BY 20 DO
                             Lib.Sound(sonido);
                             Lib.Delay(10);
                           END;
                           Lib.NoSound;

                           

                        (*    ver.muestraXY(hueco,LONGINT(y*27+60),LONGINT(x*25+10));
                              Graph.Rectangle(y*27+60,x*25+10,y*27+85,x*25+33,10,TRUE); *)

                           Sprite_con_Mask(hueco,maskhue,(y*27+60),(x*25+10+1));

                        (*   ver.muestraXY(sprite,LONGINT(Y2*27+60),LONGINT(X2*25+10)); *)

                           Sprite_con_Mask(bola,maskbola,(Y2*27+60),(X2*25+10));
                             MsMouse.Cursor(TRUE);
                        ELSE
                           Lib.Sound(50);
                           Lib.Delay(300);
                           Lib.NoSound;
                           retorna(fondo,reserva,antx,anty,reservaX,reservaY);
                        END;
                     ELSE retorna(fondo,reserva,antx,anty,reservaX,reservaY);
                     END;
                  ELSE retorna(fondo,reserva,antx,anty,reservaX,reservaY);
                  END;
               MsMouse.Cursor(TRUE);
(*comentado*)END;

(*                     Graph.PutImage(y*27+h,x*25+v,addr,Graph._GPSET);  *)
            ELSE
                  Lib.Sound(50);
                  Lib.Delay(300);
                  Lib.NoSound;
            END;
         END;
         REPEAT
             MsMouse.GetRelease(1,data);
         UNTIL (NOT data.left_pressed);
    END;
    MsMouse.Cursor(FALSE);

END Jugar;

(* ------------------------------------------------------------ *)

PROCEDURE Menu(): CHAR;
VAR
 fich : FIO.File;
 opcion : CHAR;
 correcto: BOOLEAN;
 color : CARDINAL;
 Raton : MsMouse.MsData;

BEGIN
     fich:= ver.OpenBMP("menu",correcto);
     IF correcto THEN
       	ver.muestra(fich);
       	FIO.Close(fich);
	    Graph.Line(0,0,0,200,0);
	ELSE
		HALT;
	END;
	MsMouse.Cursor(TRUE);
    REPEAT
      IO.RdLn;            			
    	 LOOP
    		MsMouse.GetPress(1,Raton);
    		IF IO.KeyPressed() THEN
    			 opcion:= IO.RdKey();
				 EXIT
		    END;
    	   IF Raton.left_pressed THEN
    		  MsMouse.GetStatus(Raton);
    		  IF (Raton.col >= 40) AND (Raton.col <= 500) THEN
    		    	IF (Raton.row >= 43) AND (Raton.row <= 63) THEN
    					opcion:= "1"; EXIT
    				ELSIF (Raton.row >= 64) AND (Raton.row <= 80) THEN
    					opcion:= "2"; EXIT 	
    	   			ELSIF (Raton.row >= 83) AND (Raton.row <= 99) THEN
    	        		opcion:= "3"; EXIT
					ELSIF (Raton.row >= 102) AND (Raton.row <= 120) THEN
    	        		opcion:= "4"; EXIT
            		ELSIF (Raton.row >= 121) AND (Raton.row <= 140) THEN
    	        		opcion:= "5"; EXIT
    	   			ELSIF (Raton.row >= 142) AND (Raton.row <= 160) THEN
    	   				opcion:= "6"; EXIT
    	   			END;
    		 END;	
    	  END;
      END;	
	 UNTIL (opcion >= "1") AND (opcion <= "6");
     MsMouse.Cursor(FALSE);
     RETURN opcion;
END Menu;

(* ------------------------------------------------------------------ *)

PROCEDURE GrabarJuego(tabl: tablero.tabler;timer : TipoTiempo ;fich:FIO.File);
VAR
	i,j:INTEGER;
BEGIN
	FIO.WrInt(fich,tablero.numBolas(tabl),0);
	FOR i:=0 TO 6 DO
		FOR j:=0 TO 6 DO
			IF tabl[i][j] THEN
				FIO.WrLn(fich);
				FIO.WrInt(fich,i,0);
				FIO.WrChar(fich,' ');
				FIO.WrInt(fich,j,0);
			END;
		END;
	END;
    FIO.WrLn(fich);
    FIO.WrCard(fich,timer.hora,1); FIO.WrChar(fich," ");
    FIO.WrCard(fich,timer.minu,1); FIO.WrChar(fich," ");
    FIO.WrCard(fich,timer.seg,1);  FIO.WrChar(fich," ");
END GrabarJuego;

(* PROCEDIMIENTO PARA CARGAR PARTIDA DESDE FICHERO *)

PROCEDURE CargarJuego(VAR tabl: tablero.tabler ; VAR timer : TipoTiempo; fich:FIO.File);
VAR
	contador,i,j:INTEGER;
BEGIN
	contador:= FIO.RdInt(fich);
	tablero.BorrarTablero(tabl);
	WHILE (contador<>0) DO
		i:= FIO.RdInt(fich);
		j:= FIO.RdInt(fich);
		tabl[i][j]:= TRUE;
		contador:=contador-1;
		IF contador = 0 THEN
			timer.hora:= FIO.RdCard(fich);
			timer.minu:= FIO.RdCard(fich);
			timer.seg:= FIO.RdCard(fich);
		END;	
	END;


END CargarJuego;





END juego.
