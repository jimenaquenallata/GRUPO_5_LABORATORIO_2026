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

// =====================================================================
//  MODULO: CONSULTA DE DENUNCIAS
// =====================================================================

SubProceso MostrarResumen(i, denNombre, denCategoria, denEstado)
	Escribir "ID ", IdDeDenuncia(i), " | ", denNombre[i], " | ", NombreCategoria(denCategoria[i]), " | ", NombreEstado(denEstado[i]);
FinSubProceso

SubProceso MostrarDetalle(i, denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto)
	Escribir "";
	Escribir "========== DENUNCIA ID ", IdDeDenuncia(i), " ==========";
	Escribir "Estado:       ", NombreEstado(denEstado[i]);
	Escribir "Denunciante:  ", denNombre[i];
	Escribir "DNI:          ", denDni[i];
	Escribir "Telefono:     ", denTelefono[i];
	Escribir "Categoria:    ", NombreCategoria(denCategoria[i]);
	Escribir "Fecha:        ", denFecha[i];
	Escribir "Lugar:        ", denLugar[i];
	Escribir "Descripcion:  ", denDescripcion[i];
	Si denCategoria[i] = 8 Entonces
		Escribir "Tipo fraude:  ", NombreTipoFraude(fraTipo[i]);
		Escribir "Entidad:      ", fraEntidad[i];
		Escribir "Monto:        $", fraMonto[i];
		Si LeerSiNo("Ver orientacion para este tipo de fraude?") Entonces
			MostrarOrientacionFraude(fraTipo[i]);
		FinSi
	FinSi
FinSubProceso

SubProceso ConsultarPorId(denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen)
	Definir id, pos Como Entero;
	Escribir Sin Saltar "ID de la denuncia: ";
	Leer id;
	pos <- BuscarPorId(id, cantDen);
	Si pos = 0 Entonces
		Escribir "No existe una denuncia con ese ID.";
	SiNo
		MostrarDetalle(pos, denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto);
	FinSi
FinSubProceso

SubProceso ConsultarPorDni(denNombre, denDni, denCategoria, denEstado, cantDen)
	Definir dni Como Caracter;
	Definir i, encontradas Como Entero;
	dni <- LeerDni();
	encontradas <- 0;
	Para i <- 1 Hasta cantDen Con Paso 1 Hacer
		Si denDni[i] = dni Entonces
			MostrarResumen(i, denNombre, denCategoria, denEstado);
			encontradas <- encontradas + 1;
		FinSi
	FinPara
	Escribir "Denuncias encontradas: ", encontradas;
FinSubProceso

SubProceso ListarPorEstado(denNombre, denCategoria, denEstado, cantDen)
	Definir est, i, encontradas Como Entero;
	MostrarEstados(5);
	est <- LeerEnteroEnRango("Estado a listar: ", 1, 5);
	encontradas <- 0;
	Para i <- 1 Hasta cantDen Con Paso 1 Hacer
		Si denEstado[i] = est Entonces
			MostrarResumen(i, denNombre, denCategoria, denEstado);
			encontradas <- encontradas + 1;
		FinSi
	FinPara
	Escribir "Denuncias en estado ", NombreEstado(est), ": ", encontradas;
FinSubProceso

SubProceso ListarPorCategoria(denNombre, denCategoria, denEstado, cantDen)
	Definir cat, i, encontradas Como Entero;
	MostrarCategorias();
	cat <- LeerEnteroEnRango("Categoria a listar: ", 1, 9);
	encontradas <- 0;
	Para i <- 1 Hasta cantDen Con Paso 1 Hacer
		Si denCategoria[i] = cat Entonces
			MostrarResumen(i, denNombre, denCategoria, denEstado);
			encontradas <- encontradas + 1;
		FinSi
	FinPara
	Escribir "Denuncias de ", NombreCategoria(cat), ": ", encontradas;
FinSubProceso

SubProceso ListarTodas(denNombre, denCategoria, denEstado, cantDen)
	Definir i Como Entero;
	Para i <- 1 Hasta cantDen Con Paso 1 Hacer
		MostrarResumen(i, denNombre, denCategoria, denEstado);
	FinPara
	Escribir "Total de denuncias: ", cantDen;
FinSubProceso

SubProceso MenuConsultas(denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen)
	Definir op Como Entero;
	Si cantDen = 0 Entonces
		Escribir "Todavia no hay denuncias registradas.";
	SiNo
		Repetir
			Escribir "";
			Escribir "--- CONSULTAR DENUNCIAS ---";
			Escribir "1. Buscar por ID (ver detalle)";
			Escribir "2. Buscar por DNI del denunciante";
			Escribir "3. Listar por estado";
			Escribir "4. Listar por categoria";
			Escribir "5. Listar todas";
			Escribir "0. Volver";
			op <- LeerEnteroEnRango("Opcion: ", 0, 5);
			Segun op Hacer
				1:
					ConsultarPorId(denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen);
				2:
					ConsultarPorDni(denNombre, denDni, denCategoria, denEstado, cantDen);
				3:
					ListarPorEstado(denNombre, denCategoria, denEstado, cantDen);
				4:
					ListarPorCategoria(denNombre, denCategoria, denEstado, cantDen);
				5:
					ListarTodas(denNombre, denCategoria, denEstado, cantDen);
			FinSegun
		Hasta Que op = 0
	FinSi
FinSubProceso


// =====================================================================
//  MODULO: SEGUIMIENTO (CAMBIO DE ESTADO)
// =====================================================================

// El recepcionista puede pasar a Registrada, En gestion, Derivada o Resuelta.
// Solo el administrador puede Cerrar. Una denuncia cerrada no se modifica.
SubProceso CambiarEstado(rol, denNombre, denCategoria, denEstado, cantDen)
	Definir id, pos, nuevo, maxEstado Como Entero;
	Escribir Sin Saltar "ID de la denuncia: ";
	Leer id;
	pos <- BuscarPorId(id, cantDen);
	Si pos = 0 Entonces
		Escribir "No existe una denuncia con ese ID.";
	SiNo
		Si denEstado[pos] = 5 Entonces
			Escribir "La denuncia esta cerrada y no puede modificarse.";
		SiNo
			MostrarResumen(pos, denNombre, denCategoria, denEstado);
			Si rol = 1 Entonces
				maxEstado <- 5;
			SiNo
				maxEstado <- 4;
			FinSi
			MostrarEstados(maxEstado);
			nuevo <- LeerEnteroEnRango("Nuevo estado: ", 1, maxEstado);
			Si nuevo = denEstado[pos] Entonces
				Escribir "La denuncia ya se encuentra en ese estado.";
			SiNo
				denEstado[pos] <- nuevo;
				Escribir "Estado actualizado a: ", NombreEstado(nuevo);
			FinSi
		FinSi
	FinSi
FinSubProceso


// =====================================================================
//  MODULO: ESTADISTICAS
// =====================================================================

SubProceso porc <- Porcentaje(parte, total)
	Definir porc Como Real;
	Si total = 0 Entonces
		porc <- 0;
	SiNo
		porc <- Redon(parte * 1000 / total) / 10;
	FinSi
FinSubProceso

SubProceso MostrarEstadisticas(denCategoria, denEstado, fraTipo, fraMonto, cantDen)
	Definir i, k, cont, abiertas Como Entero;
	Definir montoTotal Como Real;
	Escribir "";
	Escribir "========== ESTADISTICAS ==========";
	Escribir "Total de denuncias: ", cantDen;
	Si cantDen > 0 Entonces
		Escribir "";
		Escribir "Por estado:";
		Para k <- 1 Hasta 5 Con Paso 1 Hacer
			cont <- 0;
			Para i <- 1 Hasta cantDen Con Paso 1 Hacer
				Si denEstado[i] = k Entonces
					cont <- cont + 1;
				FinSi
			FinPara
			Escribir "  ", NombreEstado(k), ": ", cont, " (", Porcentaje(cont, cantDen), "%)";
		FinPara
		
		abiertas <- 0;
		Para i <- 1 Hasta cantDen Con Paso 1 Hacer
			Si denEstado[i] <= 3 Entonces
				abiertas <- abiertas + 1;
			FinSi
		FinPara
		Escribir "  Casos abiertos: ", abiertas, " | Resueltos o cerrados: ", cantDen - abiertas;
		
		Escribir "";
		Escribir "Por categoria:";
		Para k <- 1 Hasta 9 Con Paso 1 Hacer
			cont <- 0;
			Para i <- 1 Hasta cantDen Con Paso 1 Hacer
				Si denCategoria[i] = k Entonces
					cont <- cont + 1;
				FinSi
			FinPara
			Escribir "  ", NombreCategoria(k), ": ", cont, " (", Porcentaje(cont, cantDen), "%)";
		FinPara
		
		Escribir "";
		Escribir "Fraudes bancarios virtuales por tipo:";
		montoTotal <- 0;
		Para k <- 1 Hasta 3 Con Paso 1 Hacer
			cont <- 0;
			Para i <- 1 Hasta cantDen Con Paso 1 Hacer
				Si denCategoria[i] = 8 Y fraTipo[i] = k Entonces
					cont <- cont + 1;
					montoTotal <- montoTotal + fraMonto[i];
				FinSi
			FinPara
			Escribir "  ", NombreTipoFraude(k), ": ", cont;
		FinPara
		Escribir "  Monto total denunciado por fraudes: $", montoTotal;
	FinSi
FinSubProceso


// =====================================================================
//  MODULO: MENUS POR ROL
// =====================================================================

// Devuelve la cantidad de denuncias al cerrar sesion
SubProceso cantFinal <- MenuRecepcionista(nombreUsuario, denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen, MAX_DEN)
	Definir cantFinal, op Como Entero;
	cantFinal <- cantDen;
	Repetir
		Escribir "";
		Escribir "===== MENU RECEPCIONISTA (", nombreUsuario, ") =====";
		Escribir "1. Registrar denuncia";
		Escribir "2. Consultar denuncias";
		Escribir "3. Actualizar estado de una denuncia";
		Escribir "4. Orientacion sobre fraudes bancarios virtuales";
		Escribir "0. Cerrar sesion";
		op <- LeerEnteroEnRango("Opcion: ", 0, 4);
		Segun op Hacer
			1:
				cantFinal <- RegistrarDenuncia(denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantFinal, MAX_DEN);
			2:
				MenuConsultas(denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantFinal);
			3:
				CambiarEstado(2, denNombre, denCategoria, denEstado, cantFinal);
			4:
				ConsultarOrientacion();
		FinSegun
	Hasta Que op = 0
FinSubProceso

// Devuelve la cantidad de usuarios al cerrar sesion (puede haber altas)
SubProceso cantFinal <- MenuAdministrador(posUsr, usrNombre, usrClave, usrRol, usrActivo, cantUsr, MAX_USR, denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen)
	Definir cantFinal, op Como Entero;
	cantFinal <- cantUsr;
	Repetir
		Escribir "";
		Escribir "===== MENU ADMINISTRADOR (", usrNombre[posUsr], ") =====";
		Escribir "1. Consultar denuncias";
		Escribir "2. Controlar casos (cambiar estado / cerrar)";
		Escribir "3. Estadisticas";
		Escribir "4. Gestionar usuarios";
		Escribir "0. Cerrar sesion";
		op <- LeerEnteroEnRango("Opcion: ", 0, 4);
		Segun op Hacer
			1:
				MenuConsultas(denNombre, denDni, denTelefono, denFecha, denLugar, denDescripcion, denCategoria, denEstado, fraTipo, fraEntidad, fraMonto, cantDen);
			2:
				CambiarEstado(1, denNombre, denCategoria, denEstado, cantDen);
			3:
				MostrarEstadisticas(denCategoria, denEstado, fraTipo, fraMonto, cantDen);
			4:
				cantFinal <- GestionarUsuarios(posUsr, usrNombre, usrClave, usrRol, usrActivo, cantFinal, MAX_USR);
		FinSegun
	Hasta Que op = 0
FinSubProceso

