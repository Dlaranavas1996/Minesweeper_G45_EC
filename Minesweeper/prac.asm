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
; en la pantalla en la posici� on est�  el cursor,  
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
	;push tot reg
	push_all


	;Filas
    mov edx, 0
	mov ebx,0
	mov eax, [row]
	dec eax
	imul eax,2
	mov ecx, [rowScreenIni]
	add ecx,eax
	mov [rowScreen],ecx

	;Columnas
	mov bl, [col]
	sub bl, 'A'

	imul ebx,4

	mov edx, [colScreenIni]
	add edx,ebx
	mov [colScreen],edx
	
	call gotoxy


	;pop tot reg
	pop_all
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
; opc: Variable que indica en quina opci� del men� principal estem
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
    	;Comprovacion caracter
	mov eax, 0


	inici:	call getch
	mov al,[carac2]

	iftecla:	CMP AL,'i'
				JNE continue1
				JMP fin
	continue1:  CMP AL, 'j'
				JNE continue2
				JMP fin
	continue2:  CMP AL, 'k'
				JNE continue3
				JMP fin
	continue3:  CMP AL, 'l'
				JNE continue4
				JMP fin
	continue4:	CMP AL, ' '
				JNE continue5
				JMP fin
	continue5:	CMP AL, 'm'
				JNE continue6
				JMP fin
	continue6:	CMP AL, 's'
				JNE inici
				JMP fin				
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
   push_all

	mov al,[carac2]

	iftecla:	CMP AL,'i'
				JNE continue1
				;check que no se salga del tablero
				mov eax, [row]
				dec eax
				CMP eax, 1
				JL FIN
			 
				;sumar fila arr
				mov [rowCur],eax
				JMP fin

	continue1:  CMP AL, 'j'
				JNE continue2
				;check que no se salga del tablero
				mov al, [col]
				dec al
				CMP al, 'A'
				JL FIN

				;sumar col izq
				;add eax,al
				mov [colCur],al
				JMP fin

	continue2:  CMP AL, 'k'
				JNE continue3
				;check que no se salga del tablero
				mov eax, [row]
				inc eax
				CMP eax, 8
				JG FIN

				;sumar fil ab
				 mov [rowCur],eax
				JMP fin

	continue3:  CMP AL, 'l'
				JNE continue4
				;check que no se salga del tablero
				mov al, [col]
				inc al
				CMP al, 'H'
				JG FIN

				;sumar col der
				;add eax,al
				mov [colCur],al
				JMP fin
	continue4:
	fin:
	pop_all
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

	inici: call getch
	mov al,[carac2]

	iftecla: CMP AL,'i'
			 JNE continue1
			 JMP setVars
			 JMP inici

	continue1:  CMP AL, 'j'
				JNE continue2

				JMP setVars

				JMP inici
	continue2:  CMP AL, 'k'
				JNE continue3
				JMP setVars

				JMP inici
	continue3:  CMP AL, 'l'
				JNE continue4
				JMP setVars

	continue4:	CMP AL, 'm'
				JNE continue5
				
				;call openP1
				JMP fin
			
	continue5:	CMP AL, ' '
				JNE continue6
				;call openP1
			
				JMP fin
	continue6:	CMP AL, 's'
				JE fin
			
	

	setVars: 	call moveCursorP1
				;col=colCur,row=rowCur
				mov eax, [rowCur]
				mov [row],eax
				mov al, [colCur]
				mov [col],al
				call posCurScreenP1
				JMP inici

	fin:


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
	
	;row * 8
	Push_all
	
	mov eax,[row]
	dec eax
	imul eax, 8

	;col/'A', eax+col
	mov ebx, 0
	mov bl, [col]
	sub bl, 'A'
	add eax,ebx
	mov [indexMat], eax


	

	;mov cl, [edx+eax]
	Pop_all

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

	Push_all

	call calcIndexP1
	mov ecx, 0
	mov eax, [indexMat]
	mov cl , [mineField+eax]
	mov dl, [taulell+eax]
	mov bl, [carac2]
	CMP bl, ' '
		JNE continue1
		;Comparar si es bomba
			CMP cl, 1
			JNE continue2
				;Marcar X
			mov [carac], 'X'
			mov edx, [endgame]
			dec edx
			mov [endgame], edx
			JMP fin
			
			continue2:
			;Marcar ag�ita
			;mov [carac], '~'
			call sumNeighbours

			;mov edi, 0
			;mov dh, [carac]
			CMP dl, 'm'
			JNE compareSpace
			call updateMarks
			JMP fin
			compareSpace:
			;CMP dl, ' '
			;JE fin
			;call updateMarks			
			JMP fin
	continue1:
		CMP bl, 'm'
		JNE fin
			;Marcar
			CMP dl, '8'
			JNLE continueSpace
			
			CMP dl, '0'
			JNGE continueSpace

			mov [carac], dl
			JMP fin

			continueSpace:
			mov edi, [marks]
			CMP dl , 'm'
			JNE continueM
			mov [carac], ' '
			call updateMarks
			JMP fin

			continueM:
			mov [carac], 'm'
			CMP edi, 0
			JE resetVars
			call updateMarks
			JMP fin

	resetVars:
	mov [carac], ' '

	fin:
	mov dl, [carac]
	mov [taulell+eax], dl
	;mov [mineField+eax], bl
	call posCurScreenP1
	call printch

	CMP [carac], '0'
	JNE final
	mov eax, [rowCur]
	mov bl, [colCur]
	call openBorders
	mov [rowCur], eax
	mov [row], eax
	mov [colCur], bl
	mov [col], bl
	JMP final

	final:
	call checkWin
	call posCurScreenP1
	Pop_all

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

	Push_all

	inici: 
	mov cl, [carac2]
	mov ebx, [endgame]
	CMP cl,'s'
	JNE continue1
	JMP fin
	continue1:
	CMP ebx, 0
	JNE fin

	call movContinuoP1
	call openP1
	JMP inici
	fin:
	Pop_all
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

	Push_all
	mov edx, 0
	mov dl, [carac]

	mov edi, 0
	mov dh, [carac2]

	mov esi, 0
	mov bl, [col]
	mov ecx, [row]
	mov eax, [marks]
	mov edi, [indexMat]
	mov dh, [taulell+edi]

 	CMP dh, ' '
		JNE continue
		CMP dl, 'm'
		JNE continue1
		dec eax
		JMP continue2

	continue1:
		CMP dl, ' '
		JE continue2
		inc eax
		JMP continue2

	continue:
	CMP dh, 'm'
		JNE continue2
		CMP dl, ' '
		JNE compara0
		inc eax
		JMP continue2
		compara0:
		cmp dl, 'm'
		JE continue2
		inc eax
		JMP continue2


		;mov edi, 0
		;mov bh, [carac2]
		;CMP bh, 'm'
		;JNE continue2
		;dec eax


	continue2:
	;No tocar plsx
	mov [col], 'H'
	mov [row], -1
	call posCurScreenP1
	add eax, 48
	mov [carac], al
	call printch 
	mov [carac], dl
	mov [col], bl
	mov [row], ecx
	sub eax, 48
	mov [marks], eax
	fin:

	Pop_all
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

	Push_all

	mov eax, [rowCur]
	inc eax
	mov [rowCur], eax
	mov bl, [colCur]
	inc bl
	mov [colCur], bl
	sub eax, 2
	sub bl, 2
	
	mov cl, '0'

	bucle:
	CMP eax, 0
	JL incRow
	CMP bl, 0
	JL incCol
	CMP eax, 8
	JG incRow
	CMP bl, 'H'
	JG incCol
	mov [row], eax
	mov [col], bl
	call calcIndexP1
	mov edx, [indexMat]
	mov ch, [mineField+edx]
	CMP ch, 1
	JNE incCol
	inc cl
	JMP incCol

	incRow:
	;mov [colCur], bl
	sub bl, 2
	CMP eax, [rowCur]
	JE fiBucle
	inc al
	JMP bucle

	incCol:
	CMP bl, [colCur]
	JE incRow
	inc bl
	JMP bucle

	fiBucle:
	mov [carac],cl
	mov eax, [rowCur]
	dec eax
	mov [rowCur], eax
	mov [row], eax
	mov bl, [colCur]
	dec bl
	mov [colCur], bl
	mov [col], bl


	Pop_all

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

	Push_all

	mov eax, 0
	
	bucle:
	mov bl, [taulell+eax]
	CMP bl, ' '
	JE final2
	inc eax
	CMP eax, 63
	JE final1
	JMP bucle


	final1:
	mov [endGame], 1
	JMP final2

	final2:

	Pop_all

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

	Push_all

	mov eax, [rowCur]
	mov ebx, eax
	dec eax
	inc ebx
	mov cl, [colCur]
	mov ch, cl
	dec cl
	inc ch

	bucle:
	CMP cl, 'A'
	JL incCol
	CMP cl, 'H'
	JG incRow
	CMP eax, 1
	JL incRow
	CMP eax, 8
	JG incRow
	mov [rowCur], eax
	mov [colCur], cl
	mov [row], eax
	mov [col], cl
	call calcIndexP1
	mov edx, [indexMat]
	mov dl, [taulell+edx]
	cmp dl, '0'
	JE incCol
	call openP1
	JMP incCol

	incRow:
	mov cl, ch
	sub cl, 2
	cmp eax, ebx
	JE final
	inc eax
	JMP bucle

	incCol:
	CMP cl, ch
	JE incRow
	inc cl
	JMP bucle

	final:


	Pop_all

	mov esp, ebp
	pop ebp
	ret
openBorders endp


;****************************************************************************************

END