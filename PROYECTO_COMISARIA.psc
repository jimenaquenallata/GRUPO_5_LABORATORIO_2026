Definir usrNombre, usrClave Como Caracter;
	Definir usrRol Como Entero;
	Definir usrActivo Como Logico;
	Dimension usrNombre[20], usrClave[20], usrRol[20], usrActivo[20];
	cantUsr <- InicializarUsuarios(usrNombre, usrClave, usrRol, usrActivo);
	
	Repetir
		Escribir "";
		Escribir "==============================================";
		Escribir "   COMISARIA - SISTEMA DE GESTION DE DENUNCIAS";
		Escribir "==============================================";
		Escribir "1. Iniciar sesion";
		Escribir "0. Salir";
		op <- LeerEnteroEnRango("Opcion: ", 0, 1);
		Segun op Hacer
			1:
				posUsr <- IniciarSesion(usrNombre, usrClave, usrActivo, cantUsr);
				Si posUsr > 0 Entonces
					Si usrRol[posUsr] = 1 Entonces
						cantUsr <- MenuAdministrador(posUsr, usrNombre, usrClave, usrRol, usrActivo, cantUsr, MAX_USR, denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen);
					SiNo
						cantDen <- MenuRecepcionista(usrNombre[posUsr], denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen, MAX_DEN);
					FinSi
				FinSi
			0:
				Escribir "Fin del programa.";
		FinSegun
	Hasta Que op = 0
FinAlgoritmo


// =====================================================================
//  MODULO: UTILIDADES DE LECTURA Y VALIDACION
// =====================================================================

SubProceso valor <- LeerEnteroEnRango(mensaje, minimo, maximo)
	Definir valor Como Entero;
	Repetir
		Escribir Sin Saltar mensaje;
		Leer valor;
		Si valor < minimo O valor > maximo Entonces
			Escribir "Valor invalido. Debe estar entre ", minimo, " y ", maximo, ".";
		FinSi
	Hasta Que valor >= minimo Y valor <= maximo
FinSubProceso

SubProceso texto <- LeerTextoNoVacio(mensaje)
	Definir texto Como Caracter;
	Repetir
		Escribir Sin Saltar mensaje;
		Leer texto;
		Si Longitud(texto) = 0 Entonces
			Escribir "El dato no puede quedar vacio.";
		FinSi
	Hasta Que Longitud(texto) > 0
FinSubProceso

SubProceso dni <- LeerDni
	Definir dni Como Caracter;
	Repetir
		Escribir Sin Saltar "DNI (7 u 8 digitos, sin puntos): ";
		Leer dni;
		Si Longitud(dni) < 7 O Longitud(dni) > 8 Entonces
			Escribir "DNI invalido.";
		FinSi
	Hasta Que Longitud(dni) >= 7 Y Longitud(dni) <= 8
FinSubProceso

SubProceso monto <- LeerMontoNoNegativo(mensaje)
	Definir monto Como Real;
	Repetir
		Escribir Sin Saltar mensaje;
		Leer monto;
		Si monto < 0 Entonces
			Escribir "El monto no puede ser negativo.";
		FinSi
	Hasta Que monto >= 0
FinSubProceso

SubProceso respuesta <- LeerSiNo(mensaje)
	Definir respuesta Como Logico;
	Definir r Como Caracter;
	Repetir
		Escribir Sin Saltar mensaje, " (S/N): ";
		Leer r;
		r <- Mayusculas(r);
	Hasta Que r = "S" O r = "N"
	respuesta <- (r = "S");
FinSubProceso
