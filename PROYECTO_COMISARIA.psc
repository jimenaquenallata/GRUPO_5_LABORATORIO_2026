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

// =====================================================================
//  MODULO: USUARIOS Y SESION
// =====================================================================

// Carga los usuarios de prueba y devuelve cuantos quedaron cargados
SubProceso cant <- InicializarUsuarios(usrNombre, usrClave, usrRol, usrActivo)
	Definir cant Como Entero;
	usrNombre[1] <- "admin";
	usrClave[1] <- "admin123";
	usrRol[1] <- 1;
	usrActivo[1] <- Verdadero;
	usrNombre[2] <- "recep";
	usrClave[2] <- "recep123";
	usrRol[2] <- 2;
	usrActivo[2] <- Verdadero;
	cant <- 2;
FinSubProceso

// Devuelve la posicion del usuario que ingreso, o 0 si fallo 3 veces
SubProceso pos <- IniciarSesion(usrNombre, usrClave, usrActivo, cantUsr)
	Definir pos, i, intentos Como Entero;
	Definir nombre, clave Como Caracter;
	Definir encontrado Como Logico;
	pos <- 0;
	intentos <- 0;
	encontrado <- Falso;
	Repetir
		Escribir Sin Saltar "Usuario: ";
		Leer nombre;
		Escribir Sin Saltar "Clave: ";
		Leer clave;
		i <- 1;
		Mientras i <= cantUsr Y NO encontrado Hacer
			Si usrNombre[i] = nombre Y usrClave[i] = clave Y usrActivo[i] = Verdadero Entonces
				encontrado <- Verdadero;
				pos <- i;
			FinSi
			i <- i + 1;
		FinMientras
		intentos <- intentos + 1;
		Si NO encontrado Entonces
			Escribir "Usuario o clave incorrectos (intento ", intentos, " de 3).";
		FinSi
	Hasta Que encontrado O intentos = 3
	Si encontrado Entonces
		Escribir "Bienvenido/a, ", usrNombre[pos], ".";
	FinSi
FinSubProceso

