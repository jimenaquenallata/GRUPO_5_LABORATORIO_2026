# Sistema de Gestión de Denuncias para una Comisaría

**Informe técnico y documentación del Proyecto Final – Versión 1.0**

Este repositorio contiene el desarrollo del **Sistema de Gestión de Denuncias para una Comisaría**, un proyecto académico que busca organizar, registrar, consultar y realizar el seguimiento de denuncias mediante una aplicación de consola con control de acceso por roles.

El proyecto se desarrolla en dos entornos: pseudocódigo utilizando PSeInt para Laboratorio I y lenguaje C para Programación I.

---

## 👥 Integrantes y materias

- **Institución:** INSPT - UTN
- **Carrera:** Tecnicatura Superior en Informática Aplicada
- **Comisión / Grupo:** 1604
- **Año:** 2026
- **Docentes:** Alejandro Behringer, Juan Carlos Capia y Franco Spinelli.

### 📚 Asignaturas

- **Laboratorio I:** desarrollo en PSeInt.
- **Programación I:** desarrollo en lenguaje C.

### 🧑‍💻 Integrantes

- Jimena Chavez
- Joaquin Luna
- Jimena Quenallata

---

## 📂 Archivos y carpetas del repositorio

A continuación se describe la organización de los principales componentes del proyecto:

- `/pseint/`: contiene el desarrollo algorítmico en pseudocódigo.
  - `gestion_denuncias.psc`: código fuente principal desarrollado en PSeInt.
- `/src/`: contiene el código fuente correspondiente a la implementación en lenguaje C.
  - `main.c`: programa principal desarrollado en C, utilizando estructuras, funciones y archivos binarios.
- `README.md`: documentación general del proyecto.

---

## ⚙️ Requisitos para ejecutar el proyecto

### Versión PSeInt – Laboratorio I

- Tener instalado el programa **PSeInt**.
- Configurar el perfil del lenguaje de acuerdo con las opciones utilizadas en el código.
- Abrir el archivo `gestion_denuncias.psc` desde la aplicación.

### Versión C – Programación I

- Contar con un compilador de C, como **GCC**.
- Se puede utilizar un entorno de desarrollo como Code::Blocks, Dev-C++ o Visual Studio Code.
- Disponer de una terminal para compilar y ejecutar el programa.
- Sistema operativo compatible con Windows, Linux o macOS.

---

## 🚀 Instrucciones de ejecución

### Cómo abrir el proyecto en PSeInt

1. Abrir la aplicación PSeInt.
2. Seleccionar **Archivo > Abrir**.
3. Buscar el archivo `gestion_denuncias.psc` dentro de la carpeta `/pseint/`.
4. Presionar el botón **Ejecutar** o la tecla `F9`.

### Cómo compilar y ejecutar el programa en C

Desde una terminal, ubicarse en la carpeta principal del repositorio y ejecutar:

**Compilación:**

```bash
gcc src/main.c -o sistema_denuncias
```

**Ejecución en Linux o macOS:**

```bash
./sistema_denuncias
```

**Ejecución en Windows:**

```bash
sistema_denuncias.exe
```

Al ejecutar el programa, se crearán los archivos binarios necesarios para conservar la información registrada.

---

## 🔑 Control de acceso y usuarios de prueba

El sistema cuenta con un módulo de inicio de sesión que valida las credenciales de los usuarios y limita los intentos de acceso a tres.

Se definen dos roles con diferentes permisos y opciones de menú:

- **Rol 1 – Administrador:** permite consultar denuncias, modificar sus estados, cerrar casos, visualizar estadísticas y gestionar usuarios.
- **Rol 2 – Recepcionista:** permite registrar denuncias, realizar consultas, actualizar estados dentro de sus permisos y acceder a la orientación preventiva sobre fraudes.

### 👤 Credenciales de prueba

El sistema inicializa los siguientes usuarios cuando todavía no existe el archivo de usuarios:

| Usuario | Contraseña | Rol |
|---|---|---|
| `admin` | `admin123` | Administrador |
| `recep` | `recep123` | Recepcionista |

**Importante:** se trata de credenciales de prueba para el entorno académico. No deben utilizarse contraseñas reales.

---

## 🛠️ Funcionalidades disponibles

### Módulo de seguridad

- Inicio de sesión mediante usuario y contraseña.
- Validación de credenciales.
- Límite de tres intentos de acceso.
- Administración de usuarios.
- Activación y desactivación de cuentas.
- Cambio de contraseñas.
- Diferenciación de permisos según el rol.

### Registro de denuncias

Permite registrar los siguientes datos:

- Nombre y apellido del denunciante.
- DNI.
- Teléfono.
- Fecha del hecho.
- Lugar del hecho.
- Descripción.
- Categoría.
- Estado de la denuncia.

Cada denuncia recibe un identificador generado automáticamente.

### Clasificación de denuncias

El sistema contempla nueve categorías:

1. Robo.
2. Hurto.
3. Pérdida.
4. Daños.
5. Amenazas.
6. Accidente.
7. Documentación perdida.
8. Fraude bancario virtual.
9. Otro.

### Sección especializada en fraudes virtuales

Cuando se registra una denuncia por fraude bancario virtual, el sistema permite especificar:

- Tipo de fraude: ingeniería social, phishing o malware.
- Entidad bancaria o billetera virtual involucrada.
- Monto económico informado.

También incorpora información de orientación preventiva sobre estas modalidades de fraude.

### Gestión de estados

Las denuncias pueden tener los siguientes estados:

1. Registrada.
2. En gestión.
3. Derivada.
4. Resuelta.
5. Cerrada.

El sistema aplica restricciones según el rol del usuario. El administrador cuenta con permisos adicionales para cerrar denuncias.

### Consultas y estadísticas

- Consulta de denuncias por identificador.
- Consulta por DNI.
- Consulta por categoría.
- Consulta por estado.
- Visualización del listado general.
- Estadísticas por estado y categoría.
- Información sobre fraudes y montos registrados.

---

## 💾 Persistencia de datos

La versión desarrollada en C utiliza archivos binarios para conservar la información entre ejecuciones.

- `denuncias.dat`: almacena los registros de las denuncias.
- `usuarios.dat`: almacena los usuarios, sus credenciales, roles y estados.

Al iniciar el programa, se recupera la información guardada previamente. De esta manera, los datos no se pierden al cerrar la aplicación.

---

## 📊 Modelo de datos

El programa utiliza tres estructuras principales:

### Estructura `Denuncia`

Almacena la información principal de cada denuncia:

- `id`: identificador.
- `nombre`: nombre del denunciante.
- `dni`: documento.
- `telefono`: teléfono de contacto.
- `fecha`: fecha del hecho.
- `lugar`: ubicación del hecho.
- `descripcion`: descripción.
- `categoria`: categoría de la denuncia.
- `estado`: estado actual.
- `fraude`: estructura anidada con información específica del fraude.

### Estructura `Fraude`

Almacena información adicional cuando corresponde:

- `tipo`: modalidad de fraude.
- `entidad`: banco o billetera virtual involucrada.
- `monto`: monto económico informado.

### Estructura `Usuario`

Almacena los datos de acceso:

- `nombre`: nombre de usuario.
- `clave`: contraseña.
- `rol`: tipo de usuario.
- `activo`: indica si la cuenta está habilitada.

---

## ⚠️ Limitaciones actuales

La versión actual contempla las operaciones principales de registro, consulta y actualización de estados. Sin embargo, algunas funcionalidades previstas para completar el CRUD todavía se encuentran pendientes:

- Baja o eliminación de denuncias.
- Modificación general de los datos de una denuncia.

Estas funcionalidades podrán incorporarse en futuras versiones del proyecto.

Además, el sistema constituye un prototipo académico y no reemplaza las plataformas oficiales de gestión policial. No está destinado al almacenamiento de denuncias ni de datos personales reales.

---

## 🛠️ Herramientas utilizadas

- **PSeInt:** desarrollo del algoritmo en pseudocódigo.
- **Lenguaje C:** implementación del programa.
- **GCC:** compilación del código fuente.
- **Git:** control de versiones.
- **GitHub:** alojamiento del repositorio y trabajo colaborativo.
- **Visual Studio Code u otro editor:** escritura y revisión del código.

---

## 📌 Repositorio y control de versiones

El proyecto se encuentra alojado en GitHub:

[GRUPO_5_LABORATORIO_2026](https://github.com/jimenaquenallata/GRUPO_5_LABORATORIO_2026)

Se utiliza Git para registrar los cambios realizados durante el desarrollo, mantener un historial de versiones y facilitar el trabajo colaborativo entre los integrantes.

---

**Proyecto académico – INSPT UTN – 2026**