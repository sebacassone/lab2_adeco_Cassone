.data
	fin: .asciiz "Fin del programa"
	random_msg1: .asciiz "Primer número aleatorio entre 0 y 100 generado: "
	random_msg2: .asciiz "Segundo número aleatorio entre 0 y 100 generado: "
	mensaje_bienvenida: .asciiz "Ingrese la cantidad de puntos aleatorios: "
	distancia: .asciiz "La distancia es: "
	salto_linea: .asciiz "\n"
	radio_limite: .float 100.0
	multiplicador_ecuacion: .float 4.0

.text
	main:
		jal entrada
		jal bucle
		
	entrada:
		# En la entrada, se le pedirá al usuario la cantidad de
		# puntos aleatorios que requiera el usuario para hacer la medida
		# de pi mucho más exacta.
		la $a0, mensaje_bienvenida
		li $v0, 4
		syscall
		
		# Captura el número que introduzca el usuario.
		li $v0, 5
		syscall
		move $s1, $v0 # En $s1 se va a guardar la cantidad de repeticiones.
		
		jr $ra
		
	bucle:
		# Se inicializa el acumulador de puntos dentro del círculo en 0.
		beq $t9, $s1, calcularPi
			jal GenerarPuntoAleatorio
			jal calcularDistancia
			jal puntoDentroDelCirculo
			add $t9, $t9, 1
			j bucle


	calcularPi:
		# Divide la cantidad de puntos en el circulo
		# y lo divide por el total.
		# Transforma el registro $s0 y $s1 en flotante
		mtc1 $s0, $f13
		mtc1 $s1, $f14
		
		cvt.s.w $f13, $f13
		cvt.s.w $f14, $f14
		
		div.s $f15, $f13, $f14
		
		# Obtiene un 4 en flotante y lo multiplica por el resultado
		# de la división $f14.
		lwc1 $f16, multiplicador_ecuacion
		mul.s $f17, $f16, $f15
		
		# Muestra el resultado $f16, en pantalla
		li $v0, 2
		add.s $f12, $f17, $f31
		syscall
		
		jal exit
			
	
	GenerarPuntoAleatorio:
		# Se imprime mensaje de número aleatorio
		la $a0, random_msg1
		li $v0, 4
		syscall
		
		# Genera número aleatorio entre 0 y 100
		li $a1, 100
		li $v0, 42
		syscall
		
		# Se guarda el número aleatorio en $t0
		move $t0, $a0
		
		# Se imrpime por consola el número generado
		li $v0, 1
		syscall
		
		# Salto de linea
		li $v0, 4
		la $a0, salto_linea
		syscall
		
		# Se imprime mensaje de número aleatorio
		la $a0, random_msg2
		li $v0, 4
		syscall
		
		# Genera número aleatorio entre 0 y 100
		li $a1, 100
		li $v0, 42
		syscall
		
		# Se guarda el número generado en $t0
		move $t1, $a0
		
		# Se imrpime por consola el número generado
		li $v0, 1
		syscall
		
		# Salto de linea
		li $v0, 4
		la $a0, salto_linea
		syscall
		
		# Devuelve el control a la función original
		jr $ra
		
	calcularDistancia:
		# Obtenemos los cuadrados de número
		mul $t3, $t0, $t0
		mul $t4, $t1, $t1
		# Sumamos ambos números y luego le sacamos la raíz
		add $t5, $t3, $t4
		
		# Para la raiz debemos pasar el valor de la suma
		# a entero para de esta manera poder utilizar sqrt.s
		
		# "MTC1" en ensamblador se utiliza para transferir datos
		# desde un registro de propósito general a un registro de
		# coprocesador de coma flotante en una arquitectura que admite
		# coprocesadores de coma flotante
		# El valor se interpreta como un número de punto flotante de 
		# 32 bits en formato IEEE 754 y se almacena en el registro de coma flotante 
		mtc1 $t5, $f1
		
		#  Esta instrucción convierte un valor entero del registro de coma flotante $f1 
		# a un número de punto flotante de 32 bits en formato IEEE 754. El valor entero 
		# se interpreta como un número entero de 32 bits y se convierte a su representación 
		# en punto flotante, que se almacena nuevamente en el registro de coma flotante $f1
		cvt.s.w $f1, $f1
		
		# Se utiliza sqrt.s, admite flotantes de 32 bits.
		sqrt.s $f1, $f1
		
		# Imprime mensaje del resultado
		la $a0, distancia
		li $v0, 4
		syscall
		
		# Imprime en console el flotante
		li $v0, 2 # Para cargar en memoria un flotante
		add.s $f12, $f1, $f31
		syscall
		
		# Salto de linea
		li $v0, 4
		la $a0, salto_linea
		syscall
		
		jr $ra
	
	puntoDentroDelCirculo:
		# Se carga en memoria en el registro $f0 un 1.0
		lwc1  $f0, radio_limite
		
		# Recibe una distancia y devuelve 1 si es verdadera y 0 si es falsa.
		c.le.s $f1, $f0  # Compare $f1 with the value 1.0

		# La instrucción "bc1t" se utiliza para realizar un salto
		# condicional basado en la condición de punto flotante establecida
		# en el registro de estado del coprocesador de coma flotante (FCSR).
		# El FCSR almacena información sobre el resultado de las instrucciones
		# de comparación de punto flotante anteriores.
		bc1t suma
	
		# Si la comparación es falsa, salta al final de la función y retorna 0
		li $v0, 0
		jr $ra

		suma:
			# Suma una unidad a $s0, donde estará el acumulador de los números.
			addi $s0, $s0, 1
	
			# Retorna 1 para indicar que la distancia está dentro del círculo.
			li $v0, 1
			jr $ra
		
			
	exit:
		li $v0, 4
		la $a0, fin
		syscall
		
		li $v0, 10
		syscall
