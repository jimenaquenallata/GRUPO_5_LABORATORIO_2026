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

// Devuelve la posicion del usuario con ese nombre, o 0 si no existe
SubProceso pos <- BuscarUsuario(nombre, usrNombre, cantUsr)
	Definir pos, i Como Entero;
	Definir encontrado Como Logico;
	pos <- 0;
	encontrado <- Falso;
	i <- 1;
	Mientras i <= cantUsr Y NO encontrado Hacer
		Si usrNombre[i] = nombre Entonces
			encontrado <- Verdadero;
			pos <- i;
		FinSi
		i <- i + 1;
	FinMientras
FinSubProceso

SubProceso nombre <- NombreRol(rol)
	Definir nombre Como Caracter;
	Si rol = 1 Entonces
		nombre <- "Administrador";
	SiNo
		nombre <- "Recepcionista";
	FinSi
FinSubProceso

SubProceso ListarUsuarios(usrNombre, usrRol, usrActivo, cantUsr)
	Definir i Como Entero;
	Escribir "--- Usuarios del sistema ---";
	Para i <- 1 Hasta cantUsr Con Paso 1 Hacer
		Si usrActivo[i] Entonces
			Escribir i, ". ", usrNombre[i], " - ", NombreRol(usrRol[i]), " - Activo";
		SiNo
			Escribir i, ". ", usrNombre[i], " - ", NombreRol(usrRol[i]), " - Inactivo";
		FinSi
	FinPara
FinSubProceso

// Devuelve la nueva cantidad de usuarios (igual a la anterior si no se pudo agregar)
SubProceso nuevaCant <- AltaUsuario(usrNombre, usrClave, usrRol, usrActivo, cantUsr, MAX_USR)
	Definir nuevaCant Como Entero;
	Definir nombre Como Caracter;
	nuevaCant <- cantUsr;
	Si cantUsr >= MAX_USR Entonces
		Escribir "No se pueden agregar mas usuarios.";
	SiNo
		nombre <- LeerTextoNoVacio("Nombre de usuario nuevo: ");
		Si BuscarUsuario(nombre, usrNombre, cantUsr) > 0 Entonces
			Escribir "Ya existe un usuario con ese nombre.";
		SiNo
			nuevaCant <- cantUsr + 1;
			usrNombre[nuevaCant] <- nombre;
			usrClave[nuevaCant] <- LeerTextoNoVacio("Clave: ");
			Escribir "1. Administrador";
			Escribir "2. Recepcionista";
			usrRol[nuevaCant] <- LeerEnteroEnRango("Rol: ", 1, 2);
			usrActivo[nuevaCant] <- Verdadero;
			Escribir "Usuario creado.";
		FinSi
	FinSi
FinSubProceso

SubProceso ActivarDesactivarUsuario(posActual, usrNombre, usrRol, usrActivo, cantUsr)
	Definir pos Como Entero;
	Si cantUsr = 0 Entonces
		Escribir "No hay usuarios cargados.";
	SiNo
		ListarUsuarios(usrNombre, usrRol, usrActivo, cantUsr);
		pos <- LeerEnteroEnRango("Numero de usuario: ", 1, cantUsr);
		Si pos = posActual Entonces
			Escribir "No puede desactivar su propio usuario.";
		SiNo
			usrActivo[pos] <- NO usrActivo[pos];
			Si usrActivo[pos] Entonces
				Escribir "Usuario ", usrNombre[pos], " activado.";
			SiNo
				Escribir "Usuario ", usrNombre[pos], " desactivado.";
			FinSi
		FinSi
	FinSi
FinSubProceso

SubProceso CambiarClaveUsuario(usrNombre, usrClave, usrRol, usrActivo, cantUsr)
	Definir pos Como Entero;
	ListarUsuarios(usrNombre, usrRol, usrActivo, cantUsr);
	pos <- LeerEnteroEnRango("Numero de usuario: ", 1, cantUsr);
	usrClave[pos] <- LeerTextoNoVacio("Nueva clave: ");
	Escribir "Clave actualizada.";
FinSubProceso

// Devuelve la cantidad de usuarios al salir (puede haber aumentado)
SubProceso cantFinal <- GestionarUsuarios(posActual, usrNombre, usrClave, usrRol, usrActivo, cantUsr, MAX_USR)
	Definir cantFinal, op Como Entero;
	cantFinal <- cantUsr;
	Repetir
		Escribir "";
		Escribir "--- GESTION DE USUARIOS ---";
		Escribir "1. Listar usuarios";
		Escribir "2. Agregar usuario";
		Escribir "3. Activar / desactivar usuario";
		Escribir "4. Cambiar clave de un usuario";
		Escribir "0. Volver";
		op <- LeerEnteroEnRango("Opcion: ", 0, 4);
		Segun op Hacer
			1:
				ListarUsuarios(usrNombre, usrRol, usrActivo, cantFinal);
			2:
				cantFinal <- AltaUsuario(usrNombre, usrClave, usrRol, usrActivo, cantFinal, MAX_USR);
			3:
				ActivarDesactivarUsuario(posActual, usrNombre, usrRol, usrActivo, cantFinal);
			4:
				CambiarClaveUsuario(usrNombre, usrClave, usrRol, usrActivo, cantFinal);
		FinSegun
	Hasta Que op = 0
FinSubProceso


// =====================================================================
//  MODULO: CATALOGOS (nombres de categorias, estados y fraudes)
// =====================================================================

SubProceso nombre <- NombreCategoria(cat)
	Definir nombre Como Caracter;
	Segun cat Hacer
		1: nombre <- "Robo";
		2: nombre <- "Hurto";
		3: nombre <- "Perdida";
		4: nombre <- "Danios";
		5: nombre <- "Amenazas";
		6: nombre <- "Accidente";
		7: nombre <- "Documentacion perdida";
		8: nombre <- "Fraude bancario virtual";
		De Otro Modo: nombre <- "Otro";
	FinSegun
FinSubProceso

SubProceso nombre <- NombreEstado(est)
	Definir nombre Como Caracter;
	Segun est Hacer
		1: nombre <- "Registrada";
		2: nombre <- "En gestion";
		3: nombre <- "Derivada";
		4: nombre <- "Resuelta";
		De Otro Modo: nombre <- "Cerrada";
	FinSegun
FinSubProceso

SubProceso nombre <- NombreTipoFraude(tipo)
	Definir nombre Como Caracter;
	Segun tipo Hacer
		1: nombre <- "Ingenieria social";
		2: nombre <- "Phishing";
		3: nombre <- "Malware";
		De Otro Modo: nombre <- "No aplica";
	FinSegun
FinSubProceso

SubProceso MostrarCategorias
	Definir i Como Entero;
	Para i <- 1 Hasta 9 Con Paso 1 Hacer
		Escribir i, ". ", NombreCategoria(i);
	FinPara
FinSubProceso

SubProceso MostrarEstados(maximo)
	Definir i Como Entero;
	Para i <- 1 Hasta maximo Con Paso 1 Hacer
		Escribir i, ". ", NombreEstado(i);
	FinPara
FinSubProceso

SubProceso MostrarTiposFraude
	Escribir "1. Ingenieria social (llamadas o mensajes haciendose pasar por el banco u otra persona)";
	Escribir "2. Phishing (correos, SMS o paginas falsas que piden datos)";
	Escribir "3. Malware (programa o aplicacion maliciosa en el dispositivo)";
FinSubProceso

// =====================================================================
//  MODULO: REGISTRO DE DENUNCIAS
// =====================================================================

// Unico lugar donde se define como se arma el ID (facil de cambiar)
SubProceso id <- IdDeDenuncia(pos)
	Definir id Como Entero;
	id <- 1000 + pos;
FinSubProceso

// Devuelve la posicion de la denuncia con ese ID, o 0 si no existe
SubProceso pos <- BuscarPorId(id, cantDen)
	Definir pos Como Entero;
	pos <- id - 1000;
	Si pos < 1 O pos > cantDen Entonces
		pos <- 0;
	FinSi
FinSubProceso

// Devuelve la nueva cantidad de denuncias (igual a la anterior si no habia lugar)
SubProceso nuevaCant <- RegistrarDenuncia(denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen, MAX_DEN)
	Definir nuevaCant, i Como Entero;
	nuevaCant <- cantDen;
	Si cantDen >= MAX_DEN Entonces
		Escribir "No hay espacio para registrar nuevas denuncias.";
	SiNo
		i <- cantDen + 1;
		Escribir "";
		Escribir "--- Datos del denunciante ---";
		denNombre[i] <- LeerTextoNoVacio("Nombre y apellido: ");
		denDni[i] <- LeerDni();
		denTelefono[i] <- LeerTextoNoVacio("Telefono de contacto: ");
		Escribir "--- Datos del hecho ---";
		MostrarCategorias();
		denCategoria[i] <- LeerEnteroEnRango("Categoria: ", 1, 9);
		denFecha[i] <- LeerTextoNoVacio("Fecha del hecho (DD/MM/AAAA): ");
		denLugar[i] <- LeerTextoNoVacio("Lugar del hecho: ");
		denDescripcion[i] <- LeerTextoNoVacio("Descripcion breve: ");
		denEstado[i] <- 1;
		fraTipo[i] <- 0;
		fraEntidad[i] <- "-";
		fraMonto[i] <- 0;
		Si denCategoria[i] = 8 Entonces
			RegistrarDatosFraude(i, fraTipo, fraEntidad, fraMonto);
		FinSi
		nuevaCant <- i;
		Escribir "";
		Escribir "Denuncia registrada con ID ", IdDeDenuncia(i), " (estado: ", NombreEstado(1), ").";
	FinSi
FinSubProceso


// =====================================================================
//  MODULO: FRAUDES BANCARIOS VIRTUALES
// =====================================================================

SubProceso RegistrarDatosFraude(i, fraTipo, fraEntidad, fraMonto)
	Escribir "--- Datos adicionales: fraude bancario virtual ---";
	MostrarTiposFraude();
	fraTipo[i] <- LeerEnteroEnRango("Tipo de fraude: ", 1, 3);
	fraEntidad[i] <- LeerTextoNoVacio("Banco o billetera virtual afectada: ");
	fraMonto[i] <- LeerMontoNoNegativo("Monto perdido (0 si no hubo perdida): $");
	Si LeerSiNo("Mostrar la orientacion para el denunciante?") Entonces
		MostrarOrientacionFraude(fraTipo[i]);
	FinSi
FinSubProceso

SubProceso MostrarOrientacionFraude(tipo)
	Escribir "";
	Escribir "===== ORIENTACION BASICA: ", Mayusculas(NombreTipoFraude(tipo)), " =====";
	Escribir "Pasos generales:";
	Escribir " - Comunicarse YA con el banco por sus canales oficiales y pedir el bloqueo de tarjetas y cuentas.";
	Escribir " - Guardar toda la evidencia: capturas, numeros, correos, comprobantes. No borrar mensajes.";
	Escribir " - Nunca compartir claves, token, codigos de verificacion ni datos de tarjeta.";
	Escribir "Pasos especificos:";
	Segun tipo Hacer
		1:
			Escribir " - El banco nunca pide claves ni codigos por telefono, WhatsApp o redes sociales.";
			Escribir " - Cortar la comunicacion y llamar al numero oficial que figura en la tarjeta.";
			Escribir " - Si se hicieron pasar por un conocido, avisar a sus contactos.";
		2:
			Escribir " - No volver a ingresar al enlace recibido; verificar siempre la direccion del sitio.";
			Escribir " - Si ingreso datos, cambiar las claves de inmediato y activar la verificacion en dos pasos.";
			Escribir " - Reenviar el correo o SMS sospechoso al area de seguridad del banco.";
		3:
			Escribir " - Desconectar el dispositivo de internet y no usar el homebanking desde el.";
			Escribir " - Desinstalar aplicaciones desconocidas y analizar el equipo con un antivirus.";
			Escribir " - Cambiar las claves desde OTRO dispositivo seguro.";
	FinSegun
FinSubProceso

SubProceso ConsultarOrientacion
	Definir tipo Como Entero;
	Escribir "";
	Escribir "--- Orientacion sobre fraudes bancarios virtuales ---";
	MostrarTiposFraude();
	tipo <- LeerEnteroEnRango("Tipo de fraude: ", 1, 3);
	MostrarOrientacionFraude(tipo);
FinSubProceso


