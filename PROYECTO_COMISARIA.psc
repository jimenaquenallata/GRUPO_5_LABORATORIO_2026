Algoritmo 	PROYECTO_COMISARIA
	Definir op, cantidad, i Como Entero
	Definir continuar Como Caracter
	Dimension id[100]
	Dimension nombre[100]
	Dimension dni[100]
	Dimension telefono[100]
	Dimension tipo[100]
	Dimension descripcion[100]
	Dimension fecha[100]
	Dimension estado[100]
	Dimension tipoFraude[100]
	cantidad<-0
	Repetir
		Limpiar Pantalla
		
		Escribir "==========================================================="
		Escribir "             SISTEMA DE GESTION DE DENUNCIAS"
		Escribir "==========================================================="
		Escribir "1. Registrar denuncia"
		Escribir "2. Consultar denuncia"
		Escribir "3. Modificar estado"
		Escribir "4. Fraudes bancarios virtuales"
		Escribir "5. Ver listado de denuncias"
		Escribir "0. Salir"
		Escribir ""
		Escribir "Seleccione una opcion"
		Leer op
		Segun op Hacer
			0:
				Escribir ""
                Escribir "=============================================="
                Escribir "Gracias por utilizar el sistema."
                Escribir "=============================================="
			1:
				RegistrarDenuncia(id, nombre, dni,telefono, tipo, descripcion, fecha, estado, tipoFraude, cantidad)
			2:
				ConsultarDenuncia(id, nombre, dni,telefono, tipo, descripcion, fecha, estado, tipoFraude, cantidad)
			3:
				ListarDenuncias(id, nombre, dni, tipo, fecha, estado, cantidad)
			4:
				FraudeBancario(tipo, tipoFraude, descripcion, cantidad)
			5: 
				MostrarListadoDenuncias(tipo, estado, cantidad)
			De Otro Modo:
				escribir "Opcion no valida "
		Fin Segun
		Si opcion <> 7 Entonces
            Escribir ""
            Escribir "Presione una tecla para continuar..."
            Esperar Tecla
        FinSi
	Hasta Que op=0
FinAlgoritmo

SubProceso RegistrarDenuncia(id, nombre, dni,telefono, tipo, descripcion, fecha, estado, tipoFraude, cantidad)
	
FinSubProceso

SubProceso ConsultarDenuncia(id, nombre, dni,telefono, tipo, descripcion, fecha, estado, tipoFraude, cantidad)
FinSubProceso
SubProceso ListarDenuncias(id, nombre, dni, tipo, fecha, estado, cantidad)
FinSubProceso

SubProceso FraudeBancario(tipo, tipoFraude, descripcion, cantidad)
	
FinSubProceso
SubProceso MostrarListadoDenuncias(tipo, estado, cantidad)
FinSubProceso

