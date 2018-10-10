.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C

.code   
   
;;Macros que guarden y recuperen de la pila els registres de proposit general de la arquitectura de 32 bits de Intel  
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, mineField: BYTE, taulell: BYTE, indexMat: SDWORD
extern C rowCur: SDWORD, colCur: BYTE, rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD
extern C neighbours: SDWORD, marks: SDWORD, endGame: SDWORD

;****************************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funci� de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci� gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gotoxy:
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funci� gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par�metres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un car�cter, guardat a la variable carac
; en la pantalla en la posici� on est� el cursor,  
; cridant a la funci� printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est� emmagatzemat el caracter a treure per pantalla
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;printch:
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqu�
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funci�  printch_C(char c) des d'assemblador, 
   ; el par�metre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all
   
   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la funci� getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getch:
getch proc
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [carac2],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funci� de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 7 
; i convertir el char de la columna (A..H) a un n�mero entre 0 i 7.
; Per calcular la posici� del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f�rmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField/taulell
; col       : columna per a accedir a la matriu mineField/taulell
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;posCurScreenP1:
posCurScreenP1 proc
	push ebp
	mov  ebp, esp

	;Filas
    mov edx, 0
	mov ebx,0
	mov eax, [row]
	imul eax,2
	mov ecx, [rowScreenIni]
	add ecx,eax
	mov [rowScreen],ecx

	;Columnas
	mov bl, [col]
	dec eax
	sub bl, 'A'

	imul ebx,4

	mov edx, [colScreenIni]
	add edx,ebx
	mov [colScreen],edx
	
	call gotoxy

	mov esp, ebp
	pop ebp
	ret
posCurScreenP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai ' ', 'm' o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el car�cter llegit
; op: Variable que indica en quina opci� del men� principal estem
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; El car�cter llegit s'emmagatzema a la variable carac2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getMoveP1:
getMoveP1 proc
   push ebp
   mov  ebp, esp
    
	mov eax, 0


    call getch
	mov al,[carac2]

	iftecla: CMP AL,'i'
			 JNE continue1
			 ;sumar fila arr
			 mov eax, [row]
			 dec eax
		     mov [rowCur],eax
			 JMP fin
	continue1:  CMP AL, 'j'
				JNE continue2
				;sumar col izq
				mov al, [col]
				dec al
				;add eax,al
				mov [colCur],al
				JMP fin
	continue2:  CMP AL, 'k'
				JNE continue3
				;sumar fil ab
				 mov eax, [row]
				 inc eax
				 mov [rowCur],eax
				JMP fin
	continue3:  CMP AL, 'l'
				JNE continue4
				;sumar col der
				mov al, [col]
				inc al
				;add eax,al
				mov [colCur],al
				JMP fin
	continue4:
	fin:

	

   mov esp, ebp
   pop ebp
   ret
getMoveP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (rowCur) i (colCur) en funci� de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del taulell, (rowCur) i (colCur) nom�s poden 
; prendre els valors [1..8] i [0..7]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : car�cter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; rowCur : fila del cursor a la matriu mineField.
; colCur : columna del cursor a la matriu mineField.
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveCursorP1: proc endp
moveCursorP1 proc
   push ebp
   mov  ebp, esp 


   mov esp, ebp
   pop ebp
   ret
moveCursorP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;		carac2   : variable on s�emmagatzema el car�cter llegit
;		rowCur   : Fila del cursor a la matriu mineField
;		colCur   : Columna del cursor a la matriu mineField
;		row      : Fila per a accedir a la matriu mineField
;		col      : Columna per a accedir a la matriu mineField
; 
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;movContinuoP1: proc endp
movContinuoP1 proc
	push ebp
	mov  ebp, esp


	mov esp, ebp
	pop ebp
	ret
movContinuoP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'�ndex per a accedir a les matrius en assemblador.
; mineField[row][col] en C, �s [mineField+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a n�mero).
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField
; col       : columna per a accedir a la matriu mineField
; indexMat  : �ndex per a accedir a la matriu mineField
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calcIndexP1: proc endp
calcIndexP1 proc
	push ebp
	mov  ebp, esp
	


	mov esp, ebp
	pop ebp
	ret
calcIndexP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obrim una casella de la matriu mineField
; En primer lloc calcular la posici� de la matriu corresponent a la
; posici� que ocupa el cursor a la pantalla, cridant a la 
; subrutina calcIndexP1.
; En cas de que la casella no estigui oberta ni marcada mostrar:
;	- 'X' si hi ha una mina
;	- 'm' si volem marcar la casella
;	- el numero de ve�ns si obrim una casella sense mina (crida a la subrutina sumNeighbours)
; En cas de que la casella estigui marcada mostrar:
;	- ' ' si volem desmarcar la casella
; Mostrarem el contingut de la casella criant a la subrutina printch. L'�ndex per
; a accedir a la matriu mineField, el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta o marcada.
; Cada vegada que marquem/desmarquem una casella, actualitzar el n�mero de marques restants 
; cridant a la subrutina updateMarks.
; Si obrim una casella amb mina actualitzar el valor endGame a -1.
; Finalment, per al nivell avan�at, si obrim una casella sense mina y amb 
; 0 mines al voltant, cridarem a la subrutina openBorders del nivell avan�at.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField
; rowCur    : fila actual del cursor a la matriu
; col       : columna per a accedir a la matriu mineField
; colCur    : columna actual del cursor a la matriu 
; indexMat  : �ndex per a accedir a la matriu mineField
; mineField : Matriu 8x8 on tenim les posicions de les mines. 
; carac	    : car�cter per a escriure a pantalla.
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; endGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;openP1: proc endp
openP1 proc
	push ebp
	mov  ebp, esp


	mov esp, ebp
	pop ebp
	ret
openP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l�obertura continua de caselles. S�ha d�utilitzar
; la tecla espai per a obrir una casella i la 's' per a sortir. 
; Per a cada moviment introdu�t comprovar si hem guanyat el joc cridant a 
; la subrutina checkWin, o b� si hem perdut el joc (endGame!=0).
;
; Variables utilitzades: 
; carac2   : Car�cter introdu�t per l�usuari
; rowCur   : Fila del cursor a la matriu mineField
; colCur   : Columna del cursor a la matriu mineField
; row      : Fila per a accedir a la matriu mineField
; col      : Columna per a accedir a la matriu mineField
; endGame  : flag per indicar si hem perdut (0=no hem perdut, 1=hem perdut)
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;openContinuousP1:proc endp
openContinuousP1 proc
	push ebp
	mov  ebp, esp


	mov esp, ebp
	pop ebp
	ret
openContinuousP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que actualitza el n�mero de marques restants. Moure el cursor a
; la posici� (row=-1, col=8), printar el n�mero de marques y retornar
; el cursor a la posici� original (rowCur, colCur).
;
; Variables utilitzades: 
; marks	   : N�mero de marques restants
; rowCur   : Fila del cursor a la matriu mineField
; colCur   : Columna del cursor a la matriu mineField
; row      : Fila per a accedir a la matriu mineField
; col      : Columna per a accedir a la matriu mineField
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;updateMarks: proc endp
updateMarks proc
	push ebp
	mov  ebp, esp


	mov esp, ebp
	pop ebp
	ret
updateMarks endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que suma les mines dels 8 ve�ns adjacents a la casella actual,
; les caselles cantonades nom�s tenen 3 ve�ns v�lids i les caselles laterals 5.
; Comprovar que no estem accedint a posicions invalides de memoria 
; del mineField (laterals i cantonades).
;
; Variables utilitzades: 
; rowCur		: Fila del cursor a la matriu mineField
; colCur		: Columna del cursor a la matriu mineField
; row			: Fila per a accedir a la matriu mineField
; col			: Columna per a accedir a la matriz mineField
; mineField		: Matriu en la que tenim emmagatzemats la posici� de les mines
; indexMat		: Variable que indica la posici� de la matriu mineField a la que volem accedir
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; La suma de mines del ve�ns s'emmagatzema en neighbours
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;sumNeighbours: proc endp
sumNeighbours proc
	push ebp
	mov  ebp, esp



	mov esp, ebp
	pop ebp
	ret
sumNeighbours endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que comprova si hem guanyant la partida.
; O b� totes les marques estan sobre les mines, o b� totes les caselles
; de mines han estat obertes.
; Recorrer matrius taulell y mineField per comprovar correspond�ncies 
; (taulell='m', mineField=1) o (taulell= not ' ', mineField = 0).
; En cas de que guanyem partida actualitzar el valor d'endGame a 1.
;
; Variables utilitzades: 
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades
; mineField	: Matriu 8x8 on tenim les posicions de les mines. 
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; endGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;checkWin: proc endp
checkWin proc
	push ebp
	mov  ebp, esp

	

	mov esp, ebp
	pop ebp
	ret
checkWin endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que obre tots el ve�ns v�lids de la casella actual.
; Aquesta funci� nom�s es cridar� quan el nombre de mines al voltant 
; de la casella actual sigui 0.
; Per a cada ve� v�lid: actualitzar les variables (rowCur/row, colCur/col), en
; cas de que la casella no estigui oberta o marcada en el taulell, cridar a 
; la subrutina OpenP1 i recuperar el valor original de (rowCur, colCur).
;
; Variables utilitzades: 
; rowCur   : Fila del cursor per a la subrutina OpenP1
; colCur   : Columna del cursor per a la subrutina OpenP1
; row      : Fila per a accedir a la matriu taulell
; col      : Columna per a accedir a la matriu taulell
; indexMat : Variable que indica la posici� de la matriu taulell a la que volem accedir
; taulell  : Matriu en la que anem indicant els valors de les nostres tirades 
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;openBorders: proc endp
openBorders proc
	push ebp
	mov  ebp, esp



	mov esp, ebp
	pop ebp
	ret
openBorders endp


;****************************************************************************************

END
