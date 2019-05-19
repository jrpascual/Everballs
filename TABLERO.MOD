IMPLEMENTATION MODULE tablero;

IMPORT FIO;
IMPORT ver;
IMPORT Graph;
IMPORT Storage;

PROCEDURE ImprimeTab(tab,fase : tabler; bola,maskbola,huecos,maskhue: ADDRESS);
VAR
  x, y : CARDINAL;
  image: FIO.File;
  existe : BOOLEAN;
  time, imagen: ADDRESS;

BEGIN
    (* Graph.Rectangle(0,0,320,200,10,TRUE); *)
    image:= ver.OpenBMP("everball",existe);
    IF existe THEN
       ver.muestra(image);
       FIO.Close(image);
    END;
    Storage.ALLOCATE(imagen,CARDINAL(Graph.ImageSize(100,100,125,123)));
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
	

    Storage.ALLOCATE(time,CARDINAL(Graph.ImageSize(224,0,320,22)));
	Graph.GetImage(80,50,176,72,time);
	Graph.PutImage(222,0,time,3);
	Graph.Rectangle(222,0,320,22,0,FALSE);

    FOR x:= 0 TO 162  BY 27 DO
        FOR y:= 0 TO 150  BY 25 DO
            IF tab[y DIV 25][x DIV 27] THEN
				Graph.GetImage(x+h,y+v,x+h+22,y+v+20,imagen);
				Graph.PutImage(x+h,y+v,maskbola,Graph._GAND);
				Graph.PutImage(x+h,y+v,bola,Graph._GOR);
            ELSIF fase[y DIV 25][x DIV 27] THEN
                   Graph.PutImage((x+h),(y+v),maskhue,Graph._GAND);
	           	   Graph.PutImage((x+h),(y+v),huecos,Graph._GOR);
                  (* ver.muestraXY(hueco,LONGINT(x+h),LONGINT(y+v)); *)
            END;
        END;
    END;


END ImprimeTab;


PROCEDURE IniciarTab(VAR inicio : tabler);
VAR
  x, y : CARDINAL;
BEGIN
     FOR y:= 0 TO 6 DO
        FOR x:= 0 TO 6 DO
            IF ((x < 2) OR (x > 4)) AND ((y < 2) OR (y > 4)) OR ((x = 3)
               AND (y = 3)) THEN
                  inicio[x][y]:= FALSE;
            ELSE
                  inicio[x][y]:= TRUE;
            END;
        END;
      END;
END IniciarTab;


PROCEDURE numBolas(tabl : tabler): INTEGER;
VAR
  x,y : CARDINAL;
  contador : INTEGER;
BEGIN
    contador:= 0;
    FOR x:= 0 TO 6 DO
        FOR y:= 0 TO 6 DO
            IF tabl[x][y] THEN
               contador:= contador + 1;
            END;
        END;
    END;
    RETURN contador;
END numBolas;

PROCEDURE BorrarTablero(VAR tab : tabler);
VAR
  x,y : CARDINAL;
BEGIN
    FOR x:= 0 TO 6 DO
        FOR y:= 0 TO 6 DO
            tab[x][y]:= FALSE;
        END;
    END;
END BorrarTablero;



END tablero.