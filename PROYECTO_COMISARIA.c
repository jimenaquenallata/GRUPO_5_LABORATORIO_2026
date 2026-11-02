
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_DEN 100
#define MAX_USR 20

#define CANT_CATEGORIAS 9
#define CAT_FRAUDE 8
#define EST_REGISTRADA 1
#define EST_CERRADA 5
#define ROL_ADMIN 1
#define ROL_RECEP 2

#define ARCH_DENUNCIAS "denuncias.dat"
#define ARCH_USUARIOS "usuarios.dat"

/* ----- Estructuras ----- */

typedef struct {
    int tipo;            /* 0 = no aplica, 1..3 segun tipo de fraude */
    char entidad[50];    /* banco o billetera virtual */
    float monto;
} Fraude;

typedef struct {
    int id;
    char nombre[60];
    char dni[10];
    char telefono[20];
    char fecha[12];
    char lugar[80];
    char descripcion[200];
    int categoria;
    int estado;
    Fraude fraude;
} Denuncia;

typedef struct {
    char nombre[30];
    char clave[30];
    int rol;
    int activo;          /* bandera: 1 = activo, 0 = inactivo */
} Usuario;

/* ----- Prototipos ----- */

/* Utilidades de lectura y validacion */
void LeerTexto(const char *mensaje, char *destino, int tam);
int LeerEnteroEnRango(const char *mensaje, int minimo, int maximo);
void LeerTextoNoVacio(const char *mensaje, char *destino, int tam);
void LeerDni(char *dni);
float LeerMontoNoNegativo(const char *mensaje);
int LeerSiNo(const char *mensaje);

/* Archivos binarios */
int CargarDenuncias(Denuncia denuncias[]);
void GuardarDenuncias(Denuncia denuncias[], int cantDen);
int CargarUsuarios(Usuario usuarios[]);
void GuardarUsuarios(Usuario usuarios[], int cantUsr);

/* Usuarios y sesion */
int InicializarUsuarios(Usuario usuarios[]);
int IniciarSesion(Usuario usuarios[], int cantUsr);
int BuscarUsuario(const char *nombre, Usuario usuarios[], int cantUsr);
const char *NombreRol(int rol);
void ListarUsuarios(Usuario usuarios[], int cantUsr);
void AltaUsuario(Usuario usuarios[], int *cantUsr);
void ActivarDesactivarUsuario(int posActual, Usuario usuarios[], int cantUsr);
void CambiarClaveUsuario(Usuario usuarios[], int cantUsr);
void GestionarUsuarios(int posActual, Usuario usuarios[], int *cantUsr);

/* Catalogos */
const char *NombreCategoria(int cat);
const char *NombreEstado(int est);
const char *NombreTipoFraude(int tipo);
void MostrarCategorias(void);
void MostrarEstados(int maximo);
void MostrarTiposFraude(void);

/* Registro de denuncias */
int IdDeDenuncia(int pos);
int BuscarPorId(int id, Denuncia denuncias[], int cantDen);
void RegistrarDenuncia(Denuncia denuncias[], int *cantDen);

/* Fraudes bancarios virtuales */
void RegistrarDatosFraude(Fraude *f);
void MostrarOrientacionFraude(int tipo);
void ConsultarOrientacion(void);

/* Consulta de denuncias */
void MostrarResumen(const Denuncia *d);
void MostrarDetalle(const Denuncia *d);
void ConsultarPorId(Denuncia denuncias[], int cantDen);
void ConsultarPorDni(Denuncia denuncias[], int cantDen);
void ListarPorEstado(Denuncia denuncias[], int cantDen);
void ListarPorCategoria(Denuncia denuncias[], int cantDen);
void ListarTodas(Denuncia denuncias[], int cantDen);
void MenuConsultas(Denuncia denuncias[], int cantDen);

/* Seguimiento */
void CambiarEstado(int rol, Denuncia denuncias[], int cantDen);

/* Estadisticas */
float Porcentaje(int parte, int total);
void MostrarEstadisticas(Denuncia denuncias[], int cantDen);

/* Menus por rol */
void MenuRecepcionista(const char *nombreUsuario, Denuncia denuncias[], int *cantDen);
void MenuAdministrador(int posUsr, Usuario usuarios[], int *cantUsr, Denuncia denuncias[], int cantDen);


/* =====================================================================
 *  PROGRAMA PRINCIPAL
 * ===================================================================== */

int main(void) {
    Denuncia denuncias[MAX_DEN];
    Usuario usuarios[MAX_USR];
    int cantDen, cantUsr, op, posUsr;

    cantDen = CargarDenuncias(denuncias);
    cantUsr = CargarUsuarios(usuarios);
    if (cantUsr == 0) {
        cantUsr = InicializarUsuarios(usuarios);
        GuardarUsuarios(usuarios, cantUsr);
    }

    do {
        printf("\n");
        printf("==============================================\n");
        printf("   COMISARIA - SISTEMA DE GESTION DE DENUNCIAS\n");
        printf("==============================================\n");
        printf("1. Iniciar sesion\n");
        printf("0. Salir\n");
        op = LeerEnteroEnRango("Opcion: ", 0, 1);
        switch (op) {
            case 1:
                posUsr = IniciarSesion(usuarios, cantUsr);
                if (posUsr >= 0) {
                    if (usuarios[posUsr].rol == ROL_ADMIN) {
                        MenuAdministrador(posUsr, usuarios, &cantUsr, denuncias, cantDen);
                    } else {
                        MenuRecepcionista(usuarios[posUsr].nombre, denuncias, &cantDen);
                    }
                }
                break;
            case 0:
                printf("Fin del programa.\n");
                break;
        }
    } while (op != 0);

    return 0;
}


/* =====================================================================
 *  MODULO: UTILIDADES DE LECTURA Y VALIDACION
 * ===================================================================== */

/* Lee una linea completa (con espacios) y le quita el salto de linea */
void LeerTexto(const char *mensaje, char *destino, int tam) {
    int largo;
    printf("%s", mensaje);
    if (fgets(destino, tam, stdin) == NULL) {
        /* se termino la entrada (por ejemplo Ctrl+Z / Ctrl+D): salir */
        printf("\nFin de la entrada. Saliendo del programa.\n");
        exit(0);
    }
    largo = strlen(destino);
    if (largo > 0 && destino[largo - 1] == '\n') {
        destino[largo - 1] = '\0';
    } else {
        /* la linea era mas larga que el vector: descartar el resto */
        int c;
        while ((c = getchar()) != '\n' && c != EOF) { }
    }
}

int LeerEnteroEnRango(const char *mensaje, int minimo, int maximo) {
    char linea[50];
    int valor, valido;
    do {
        LeerTexto(mensaje, linea, sizeof(linea));
        valido = (sscanf(linea, "%d", &valor) == 1 && valor >= minimo && valor <= maximo);
        if (!valido) {
            printf("Valor invalido. Debe estar entre %d y %d.\n", minimo, maximo);
        }
    } while (!valido);
    return valor;
}

void LeerTextoNoVacio(const char *mensaje, char *destino, int tam) {
    do {
        LeerTexto(mensaje, destino, tam);
        if (strlen(destino) == 0) {
            printf("El dato no puede quedar vacio.\n");
        }
    } while (strlen(destino) == 0);
}

void LeerDni(char *dni) {
    int largo, i, soloDigitos;
    do {
        LeerTexto("DNI (7 u 8 digitos, sin puntos): ", dni, 10);
        largo = strlen(dni);
        soloDigitos = 1;
        for (i = 0; i < largo; i++) {
            if (!isdigit((unsigned char)dni[i])) {
                soloDigitos = 0;
            }
        }
        if (largo < 7 || largo > 8 || !soloDigitos) {
            printf("DNI invalido.\n");
        }
    } while (largo < 7 || largo > 8 || !soloDigitos);
}

float LeerMontoNoNegativo(const char *mensaje) {
    char linea[50];
    float monto;
    int valido;
    do {
        LeerTexto(mensaje, linea, sizeof(linea));
        valido = (sscanf(linea, "%f", &monto) == 1 && monto >= 0);
        if (!valido) {
            printf("Monto invalido. Debe ser un numero mayor o igual a 0.\n");
        }
    } while (!valido);
    return monto;
}

/* Devuelve 1 si la respuesta es S y 0 si es N */
int LeerSiNo(const char *mensaje) {
    char r[10];
    char c;
    int valido;
    do {
        printf("%s (S/N): ", mensaje);
        LeerTexto("", r, sizeof(r));
        c = toupper((unsigned char)r[0]);
        valido = (strlen(r) == 1 && (c == 'S' || c == 'N'));
    } while (!valido);
    return c == 'S';
}


/* =====================================================================
 *  MODULO: ARCHIVOS BINARIOS
 * ===================================================================== */

/* Lee todas las denuncias guardadas y devuelve cuantas se cargaron */
int CargarDenuncias(Denuncia denuncias[]) {
    FILE *arch;
    int cant = 0;
    arch = fopen(ARCH_DENUNCIAS, "rb");
    if (arch != NULL) {
        while (cant < MAX_DEN && fread(&denuncias[cant], sizeof(Denuncia), 1, arch) == 1) {
            cant++;
        }
        fclose(arch);
    }
    return cant;
}

/* Reescribe el archivo con todas las denuncias del vector */
void GuardarDenuncias(Denuncia denuncias[], int cantDen) {
    FILE *arch;
    arch = fopen(ARCH_DENUNCIAS, "wb");
    if (arch == NULL) {
        printf("ERROR: no se pudo guardar el archivo %s.\n", ARCH_DENUNCIAS);
    } else {
        fwrite(denuncias, sizeof(Denuncia), cantDen, arch);
        fclose(arch);
    }
}

int CargarUsuarios(Usuario usuarios[]) {
    FILE *arch;
    int cant = 0;
    arch = fopen(ARCH_USUARIOS, "rb");
    if (arch != NULL) {
        while (cant < MAX_USR && fread(&usuarios[cant], sizeof(Usuario), 1, arch) == 1) {
            cant++;
        }
        fclose(arch);
    }
    return cant;
}

void GuardarUsuarios(Usuario usuarios[], int cantUsr) {
    FILE *arch;
    arch = fopen(ARCH_USUARIOS, "wb");
    if (arch == NULL) {
        printf("ERROR: no se pudo guardar el archivo %s.\n", ARCH_USUARIOS);
    } else {
        fwrite(usuarios, sizeof(Usuario), cantUsr, arch);
        fclose(arch);
    }
}


/* =====================================================================
 *  MODULO: USUARIOS Y SESION
 * ===================================================================== */

/* Carga los usuarios de prueba y devuelve cuantos quedaron cargados */
int InicializarUsuarios(Usuario usuarios[]) {
    strcpy(usuarios[0].nombre, "admin");
    strcpy(usuarios[0].clave, "admin123");
    usuarios[0].rol = ROL_ADMIN;
    usuarios[0].activo = 1;
    strcpy(usuarios[1].nombre, "recep");
    strcpy(usuarios[1].clave, "recep123");
    usuarios[1].rol = ROL_RECEP;
    usuarios[1].activo = 1;
    return 2;
}

/* Devuelve la posicion del usuario que ingreso, o -1 si fallo 3 veces */
int IniciarSesion(Usuario usuarios[], int cantUsr) {
    char nombre[30], clave[30];
    int pos = -1, i, intentos = 0, encontrado = 0;
    do {
        LeerTexto("Usuario: ", nombre, sizeof(nombre));
        LeerTexto("Clave: ", clave, sizeof(clave));
        i = 0;
        while (i < cantUsr && !encontrado) {
            if (strcmp(usuarios[i].nombre, nombre) == 0 &&
                strcmp(usuarios[i].clave, clave) == 0 &&
                usuarios[i].activo) {
                encontrado = 1;
                pos = i;
            }
            i++;
        }
        intentos++;
        if (!encontrado) {
            printf("Usuario o clave incorrectos (intento %d de 3).\n", intentos);
        }
    } while (!encontrado && intentos < 3);
    if (encontrado) {
        printf("Bienvenido/a, %s.\n", usuarios[pos].nombre);
    }
    return pos;
}

/* Devuelve la posicion del usuario con ese nombre, o -1 si no existe */
int BuscarUsuario(const char *nombre, Usuario usuarios[], int cantUsr) {
    int pos = -1, i = 0, encontrado = 0;
    while (i < cantUsr && !encontrado) {
        if (strcmp(usuarios[i].nombre, nombre) == 0) {
            encontrado = 1;
            pos = i;
        }
        i++;
    }
    return pos;
}

const char *NombreRol(int rol) {
    if (rol == ROL_ADMIN) {
        return "Administrador";
    }
    return "Recepcionista";
}

void ListarUsuarios(Usuario usuarios[], int cantUsr) {
    int i;
    printf("--- Usuarios del sistema ---\n");
    for (i = 0; i < cantUsr; i++) {
        printf("%d. %s - %s - %s\n", i + 1, usuarios[i].nombre,
               NombreRol(usuarios[i].rol), usuarios[i].activo ? "Activo" : "Inactivo");
    }
}

void AltaUsuario(Usuario usuarios[], int *cantUsr) {
    char nombre[30];
    Usuario *nuevo;
    if (*cantUsr >= MAX_USR) {
        printf("No se pueden agregar mas usuarios.\n");
    } else {
        LeerTextoNoVacio("Nombre de usuario nuevo: ", nombre, sizeof(nombre));
        if (BuscarUsuario(nombre, usuarios, *cantUsr) >= 0) {
            printf("Ya existe un usuario con ese nombre.\n");
        } else {
            nuevo = &usuarios[*cantUsr];
            strcpy(nuevo->nombre, nombre);
            LeerTextoNoVacio("Clave: ", nuevo->clave, sizeof(nuevo->clave));
            printf("1. Administrador\n");
            printf("2. Recepcionista\n");
            nuevo->rol = LeerEnteroEnRango("Rol: ", 1, 2);
            nuevo->activo = 1;
            (*cantUsr)++;
            GuardarUsuarios(usuarios, *cantUsr);
            printf("Usuario creado.\n");
        }
    }
}

void ActivarDesactivarUsuario(int posActual, Usuario usuarios[], int cantUsr) {
    int pos;
    ListarUsuarios(usuarios, cantUsr);
    pos = LeerEnteroEnRango("Numero de usuario: ", 1, cantUsr) - 1;
    if (pos == posActual) {
        printf("No puede desactivar su propio usuario.\n");
    } else {
        usuarios[pos].activo = !usuarios[pos].activo;
        GuardarUsuarios(usuarios, cantUsr);
        if (usuarios[pos].activo) {
            printf("Usuario %s activado.\n", usuarios[pos].nombre);
        } else {
            printf("Usuario %s desactivado.\n", usuarios[pos].nombre);
        }
    }
}

void CambiarClaveUsuario(Usuario usuarios[], int cantUsr) {
    int pos;
    ListarUsuarios(usuarios, cantUsr);
    pos = LeerEnteroEnRango("Numero de usuario: ", 1, cantUsr) - 1;
    LeerTextoNoVacio("Nueva clave: ", usuarios[pos].clave, sizeof(usuarios[pos].clave));
    GuardarUsuarios(usuarios, cantUsr);
    printf("Clave actualizada.\n");
}

void GestionarUsuarios(int posActual, Usuario usuarios[], int *cantUsr) {
    int op;
    do {
        printf("\n");
        printf("--- GESTION DE USUARIOS ---\n");
        printf("1. Listar usuarios\n");
        printf("2. Agregar usuario\n");
        printf("3. Activar / desactivar usuario\n");
        printf("4. Cambiar clave de un usuario\n");
        printf("0. Volver\n");
        op = LeerEnteroEnRango("Opcion: ", 0, 4);
        switch (op) {
            case 1:
                ListarUsuarios(usuarios, *cantUsr);
                break;
            case 2:
                AltaUsuario(usuarios, cantUsr);
                break;
            case 3:
                ActivarDesactivarUsuario(posActual, usuarios, *cantUsr);
                break;
            case 4:
                CambiarClaveUsuario(usuarios, *cantUsr);
                break;
        }
    } while (op != 0);
}


/* =====================================================================
 *  MODULO: CATALOGOS (nombres de categorias, estados y fraudes)
 * ===================================================================== */

const char *NombreCategoria(int cat) {
    switch (cat) {
        case 1: return "Robo";
        case 2: return "Hurto";
        case 3: return "Perdida";
        case 4: return "Danios";
        case 5: return "Amenazas";
        case 6: return "Accidente";
        case 7: return "Documentacion perdida";
        case 8: return "Fraude bancario virtual";
        default: return "Otro";
    }
}

const char *NombreEstado(int est) {
    switch (est) {
        case 1: return "Registrada";
        case 2: return "En gestion";
        case 3: return "Derivada";
        case 4: return "Resuelta";
        default: return "Cerrada";
    }
}

const char *NombreTipoFraude(int tipo) {
    switch (tipo) {
        case 1: return "Ingenieria social";
        case 2: return "Phishing";
        case 3: return "Malware";
        default: return "No aplica";
    }
}

void MostrarCategorias(void) {
    int i;
    for (i = 1; i <= CANT_CATEGORIAS; i++) {
        printf("%d. %s\n", i, NombreCategoria(i));
    }
}

void MostrarEstados(int maximo) {
    int i;
    for (i = 1; i <= maximo; i++) {
        printf("%d. %s\n", i, NombreEstado(i));
    }
}

void MostrarTiposFraude(void) {
    printf("1. Ingenieria social (llamadas o mensajes haciendose pasar por el banco u otra persona)\n");
    printf("2. Phishing (correos, SMS o paginas falsas que piden datos)\n");
    printf("3. Malware (programa o aplicacion maliciosa en el dispositivo)\n");
}


/* =====================================================================
 *  MODULO: REGISTRO DE DENUNCIAS
 * ===================================================================== */

/* Unico lugar donde se define como se arma el ID (facil de cambiar) */
int IdDeDenuncia(int pos) {
    return 1001 + pos;
}

/* Devuelve la posicion de la denuncia con ese ID, o -1 si no existe */
int BuscarPorId(int id, Denuncia denuncias[], int cantDen) {
    int pos = -1, i = 0, encontrado = 0;
    while (i < cantDen && !encontrado) {
        if (denuncias[i].id == id) {
            encontrado = 1;
            pos = i;
        }
        i++;
    }
    return pos;
}

void RegistrarDenuncia(Denuncia denuncias[], int *cantDen) {
    Denuncia *d;
    if (*cantDen >= MAX_DEN) {
        printf("No hay espacio para registrar nuevas denuncias.\n");
    } else {
        d = &denuncias[*cantDen];
        printf("\n--- Datos del denunciante ---\n");
        LeerTextoNoVacio("Nombre y apellido: ", d->nombre, sizeof(d->nombre));
        LeerDni(d->dni);
        LeerTextoNoVacio("Telefono de contacto: ", d->telefono, sizeof(d->telefono));
        printf("--- Datos del hecho ---\n");
        MostrarCategorias();
        d->categoria = LeerEnteroEnRango("Categoria: ", 1, CANT_CATEGORIAS);
        LeerTextoNoVacio("Fecha del hecho (DD/MM/AAAA): ", d->fecha, sizeof(d->fecha));
        LeerTextoNoVacio("Lugar del hecho: ", d->lugar, sizeof(d->lugar));
        LeerTextoNoVacio("Descripcion breve: ", d->descripcion, sizeof(d->descripcion));
        d->estado = EST_REGISTRADA;
        d->fraude.tipo = 0;
        strcpy(d->fraude.entidad, "-");
        d->fraude.monto = 0;
        if (d->categoria == CAT_FRAUDE) {
            RegistrarDatosFraude(&d->fraude);
        }
        d->id = IdDeDenuncia(*cantDen);
        (*cantDen)++;
        GuardarDenuncias(denuncias, *cantDen);
        printf("\nDenuncia registrada con ID %d (estado: %s).\n", d->id, NombreEstado(d->estado));
    }
}


/* =====================================================================
 *  MODULO: FRAUDES BANCARIOS VIRTUALES
 * ===================================================================== */

void RegistrarDatosFraude(Fraude *f) {
    printf("--- Datos adicionales: fraude bancario virtual ---\n");
    MostrarTiposFraude();
    f->tipo = LeerEnteroEnRango("Tipo de fraude: ", 1, 3);
    LeerTextoNoVacio("Banco o billetera virtual afectada: ", f->entidad, sizeof(f->entidad));
    f->monto = LeerMontoNoNegativo("Monto perdido (0 si no hubo perdida): $");
    if (LeerSiNo("Mostrar la orientacion para el denunciante?")) {
        MostrarOrientacionFraude(f->tipo);
    }
}

void MostrarOrientacionFraude(int tipo) {
    char titulo[30];
    int i;
    strcpy(titulo, NombreTipoFraude(tipo));
    for (i = 0; titulo[i] != '\0'; i++) {
        titulo[i] = toupper((unsigned char)titulo[i]);
    }
    printf("\n===== ORIENTACION BASICA: %s =====\n", titulo);
    printf("Pasos generales:\n");
    printf(" - Comunicarse YA con el banco por sus canales oficiales y pedir el bloqueo de tarjetas y cuentas.\n");
    printf(" - Guardar toda la evidencia: capturas, numeros, correos, comprobantes. No borrar mensajes.\n");
    printf(" - Nunca compartir claves, token, codigos de verificacion ni datos de tarjeta.\n");
    printf("Pasos especificos:\n");
    switch (tipo) {
        case 1:
            printf(" - El banco nunca pide claves ni codigos por telefono, WhatsApp o redes sociales.\n");
            printf(" - Cortar la comunicacion y llamar al numero oficial que figura en la tarjeta.\n");
            printf(" - Si se hicieron pasar por un conocido, avisar a sus contactos.\n");
            break;
        case 2:
            printf(" - No volver a ingresar al enlace recibido; verificar siempre la direccion del sitio.\n");
            printf(" - Si ingreso datos, cambiar las claves de inmediato y activar la verificacion en dos pasos.\n");
            printf(" - Reenviar el correo o SMS sospechoso al area de seguridad del banco.\n");
            break;
        case 3:
            printf(" - Desconectar el dispositivo de internet y no usar el homebanking desde el.\n");
            printf(" - Desinstalar aplicaciones desconocidas y analizar el equipo con un antivirus.\n");
            printf(" - Cambiar las claves desde OTRO dispositivo seguro.\n");
            break;
    }
}

void ConsultarOrientacion(void) {
    int tipo;
    printf("\n--- Orientacion sobre fraudes bancarios virtuales ---\n");
    MostrarTiposFraude();
    tipo = LeerEnteroEnRango("Tipo de fraude: ", 1, 3);
    MostrarOrientacionFraude(tipo);
}


/* =====================================================================
 *  MODULO: CONSULTA DE DENUNCIAS
 * ===================================================================== */

void MostrarResumen(const Denuncia *d) {
    printf("ID %d | %s | %s | %s\n", d->id, d->nombre,
           NombreCategoria(d->categoria), NombreEstado(d->estado));
}

void MostrarDetalle(const Denuncia *d) {
    printf("\n========== DENUNCIA ID %d ==========\n", d->id);
    printf("Estado:       %s\n", NombreEstado(d->estado));
    printf("Denunciante:  %s\n", d->nombre);
    printf("DNI:          %s\n", d->dni);
    printf("Telefono:     %s\n", d->telefono);
    printf("Categoria:    %s\n", NombreCategoria(d->categoria));
    printf("Fecha:        %s\n", d->fecha);
    printf("Lugar:        %s\n", d->lugar);
    printf("Descripcion:  %s\n", d->descripcion);
    if (d->categoria == CAT_FRAUDE) {
        printf("Tipo fraude:  %s\n", NombreTipoFraude(d->fraude.tipo));
        printf("Entidad:      %s\n", d->fraude.entidad);
        printf("Monto:        $%.2f\n", d->fraude.monto);
        if (LeerSiNo("Ver orientacion para este tipo de fraude?")) {
            MostrarOrientacionFraude(d->fraude.tipo);
        }
    }
}

void ConsultarPorId(Denuncia denuncias[], int cantDen) {
    int id, pos;
    id = LeerEnteroEnRango("ID de la denuncia: ", 0, 999999);
    pos = BuscarPorId(id, denuncias, cantDen);
    if (pos < 0) {
        printf("No existe una denuncia con ese ID.\n");
    } else {
        MostrarDetalle(&denuncias[pos]);
    }
}

void ConsultarPorDni(Denuncia denuncias[], int cantDen) {
    char dni[10];
    int i, encontradas = 0;
    LeerDni(dni);
    for (i = 0; i < cantDen; i++) {
        if (strcmp(denuncias[i].dni, dni) == 0) {
            MostrarResumen(&denuncias[i]);
            encontradas++;
        }
    }
    printf("Denuncias encontradas: %d\n", encontradas);
}

void ListarPorEstado(Denuncia denuncias[], int cantDen) {
    int est, i, encontradas = 0;
    MostrarEstados(5);
    est = LeerEnteroEnRango("Estado a listar: ", 1, 5);
    for (i = 0; i < cantDen; i++) {
        if (denuncias[i].estado == est) {
            MostrarResumen(&denuncias[i]);
            encontradas++;
        }
    }
    printf("Denuncias en estado %s: %d\n", NombreEstado(est), encontradas);
}

void ListarPorCategoria(Denuncia denuncias[], int cantDen) {
    int cat, i, encontradas = 0;
    MostrarCategorias();
    cat = LeerEnteroEnRango("Categoria a listar: ", 1, CANT_CATEGORIAS);
    for (i = 0; i < cantDen; i++) {
        if (denuncias[i].categoria == cat) {
            MostrarResumen(&denuncias[i]);
            encontradas++;
        }
    }
    printf("Denuncias de %s: %d\n", NombreCategoria(cat), encontradas);
}

void ListarTodas(Denuncia denuncias[], int cantDen) {
    int i;
    for (i = 0; i < cantDen; i++) {
        MostrarResumen(&denuncias[i]);
    }
    printf("Total de denuncias: %d\n", cantDen);
}

void MenuConsultas(Denuncia denuncias[], int cantDen) {
    int op;
    if (cantDen == 0) {
        printf("Todavia no hay denuncias registradas.\n");
        return;
    }
    do {
        printf("\n");
        printf("--- CONSULTAR DENUNCIAS ---\n");
        printf("1. Buscar por ID (ver detalle)\n");
        printf("2. Buscar por DNI del denunciante\n");
        printf("3. Listar por estado\n");
        printf("4. Listar por categoria\n");
        printf("5. Listar todas\n");
        printf("0. Volver\n");
        op = LeerEnteroEnRango("Opcion: ", 0, 5);
        switch (op) {
            case 1: ConsultarPorId(denuncias, cantDen); break;
            case 2: ConsultarPorDni(denuncias, cantDen); break;
            case 3: ListarPorEstado(denuncias, cantDen); break;
            case 4: ListarPorCategoria(denuncias, cantDen); break;
            case 5: ListarTodas(denuncias, cantDen); break;
        }
    } while (op != 0);
}


/* =====================================================================
 *  MODULO: SEGUIMIENTO (CAMBIO DE ESTADO)
 * ===================================================================== */

/* El recepcionista puede pasar a Registrada, En gestion, Derivada o Resuelta.
 * Solo el administrador puede Cerrar. Una denuncia cerrada no se modifica. */
void CambiarEstado(int rol, Denuncia denuncias[], int cantDen) {
    int id, pos, nuevo, maxEstado;
    Denuncia *d;
    id = LeerEnteroEnRango("ID de la denuncia: ", 0, 999999);
    pos = BuscarPorId(id, denuncias, cantDen);
    if (pos < 0) {
        printf("No existe una denuncia con ese ID.\n");
        return;
    }
    d = &denuncias[pos];
    if (d->estado == EST_CERRADA) {
        printf("La denuncia esta cerrada y no puede modificarse.\n");
        return;
    }
    MostrarResumen(d);
    maxEstado = (rol == ROL_ADMIN) ? 5 : 4;
    MostrarEstados(maxEstado);
    nuevo = LeerEnteroEnRango("Nuevo estado: ", 1, maxEstado);
    if (nuevo == d->estado) {
        printf("La denuncia ya se encuentra en ese estado.\n");
    } else {
        d->estado = nuevo;
        GuardarDenuncias(denuncias, cantDen);
        printf("Estado actualizado a: %s\n", NombreEstado(nuevo));
    }
}


/* =====================================================================
 *  MODULO: ESTADISTICAS
 * ===================================================================== */

float Porcentaje(int parte, int total) {
    if (total == 0) {
        return 0;
    }
    return parte * 100.0f / total;
}

void MostrarEstadisticas(Denuncia denuncias[], int cantDen) {
    int i, k, cont, abiertas = 0;
    float montoTotal = 0;
    printf("\n========== ESTADISTICAS ==========\n");
    printf("Total de denuncias: %d\n", cantDen);
    if (cantDen == 0) {
        return;
    }

    printf("\nPor estado:\n");
    for (k = 1; k <= 5; k++) {
        cont = 0;
        for (i = 0; i < cantDen; i++) {
            if (denuncias[i].estado == k) {
                cont++;
            }
        }
        printf("  %s: %d (%.1f%%)\n", NombreEstado(k), cont, Porcentaje(cont, cantDen));
    }

    for (i = 0; i < cantDen; i++) {
        if (denuncias[i].estado <= 3) {
            abiertas++;
        }
    }
    printf("  Casos abiertos: %d | Resueltos o cerrados: %d\n", abiertas, cantDen - abiertas);

    printf("\nPor categoria:\n");
    for (k = 1; k <= CANT_CATEGORIAS; k++) {
        cont = 0;
        for (i = 0; i < cantDen; i++) {
            if (denuncias[i].categoria == k) {
                cont++;
            }
        }
        printf("  %s: %d (%.1f%%)\n", NombreCategoria(k), cont, Porcentaje(cont, cantDen));
    }

    printf("\nFraudes bancarios virtuales por tipo:\n");
    for (k = 1; k <= 3; k++) {
        cont = 0;
        for (i = 0; i < cantDen; i++) {
            if (denuncias[i].categoria == CAT_FRAUDE && denuncias[i].fraude.tipo == k) {
                cont++;
                montoTotal += denuncias[i].fraude.monto;
            }
        }
        printf("  %s: %d\n", NombreTipoFraude(k), cont);
    }
    printf("  Monto total denunciado por fraudes: $%.2f\n", montoTotal);
}


/* =====================================================================
 *  MODULO: MENUS POR ROL
 * ===================================================================== */

void MenuRecepcionista(const char *nombreUsuario, Denuncia denuncias[], int *cantDen) {
    int op;
    do {
        printf("\n===== MENU RECEPCIONISTA (%s) =====\n", nombreUsuario);
        printf("1. Registrar denuncia\n");
        printf("2. Consultar denuncias\n");
        printf("3. Actualizar estado de una denuncia\n");
        printf("4. Orientacion sobre fraudes bancarios virtuales\n");
        printf("0. Cerrar sesion\n");
        op = LeerEnteroEnRango("Opcion: ", 0, 4);
        switch (op) {
            case 1: RegistrarDenuncia(denuncias, cantDen); break;
            case 2: MenuConsultas(denuncias, *cantDen); break;
            case 3: CambiarEstado(ROL_RECEP, denuncias, *cantDen); break;
            case 4: ConsultarOrientacion(); break;
        }
    } while (op != 0);
}

void MenuAdministrador(int posUsr, Usuario usuarios[], int *cantUsr, Denuncia denuncias[], int cantDen) {
    int op;
    do {
        printf("\n===== MENU ADMINISTRADOR (%s) =====\n", usuarios[posUsr].nombre);
        printf("1. Consultar denuncias\n");
        printf("2. Controlar casos (cambiar estado / cerrar)\n");
        printf("3. Estadisticas\n");
        printf("4. Gestionar usuarios\n");
        printf("0. Cerrar sesion\n");
        op = LeerEnteroEnRango("Opcion: ", 0, 4);
        switch (op) {
            case 1: MenuConsultas(denuncias, cantDen); break;
            case 2: CambiarEstado(ROL_ADMIN, denuncias, cantDen); break;
            case 3: MostrarEstadisticas(denuncias, cantDen); break;
            case 4: GestionarUsuarios(posUsr, usuarios, cantUsr); break;
        }
    } while (op != 0);
}
