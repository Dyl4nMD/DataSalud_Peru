# DataSalud Perú

**Sistema integrado de base de datos segura, automatizada e inteligente para la DIRESA La Libertad**

Proyecto académico de **Base de Datos Avanzadas y Big Data**, desarrollado en la **Universidad Privada del Norte (UPN)**, período **2026-2**.

## 1. Descripción

DataSalud Perú plantea una solución integrada para la gestión de datos abiertos del sector salud, considerando la calidad, organización, seguridad, automatización y análisis de la información. Utiliza dos conjuntos de datos publicados por el **Seguro Integral de Salud (SIS)** en la Plataforma Nacional de Datos Abiertos del Perú:

- Afiliados activos con diagnóstico de **Diabetes Mellitus**.
- Consumo de medicamentos en **recién nacidos** atendidos en Hospitalización y Emergencia.

Los conjuntos de datos representan dominios diferentes: **no se establece una relación clínica directa entre ambas poblaciones**. Se integran a nivel de arquitectura mediante mecanismos comunes de carga, validación, almacenamiento, seguridad, auditoría y análisis. El proyecto se plantea en el contexto de la **DIRESA La Libertad**; no implica un despliegue oficial en dicha entidad.

## 2. Conjuntos de datos

| Fuente | Volumen reportado | Contenido |
| --- | ---: | --- |
| Afiliados activos con Diabetes Mellitus — SIS | 850 366 registros; 24 campos | Datos anonimizados, características demográficas y geográficas, comorbilidades, atenciones y hospitalización |
| Consumo de medicamentos en recién nacidos — SIS | 290 469 prestaciones | Cuatro archivos: Prestaciones, Diagnósticos, Medicamentos y Catálogos |

En el conjunto de recién nacidos también se reportan **374 083** registros de diagnósticos, **931 763** de medicamentos, **13 360** del catálogo de diagnósticos y **11 543** del catálogo de medicamentos: **1 621 218 registros** entre sus estructuras.

**Fuentes originales:**

- [Afiliados activos con diagnóstico de Diabetes Mellitus — SIS](https://www.datosabiertos.gob.pe/dataset/afiliados-activos-en-el-seguro-integral-de-salud-con-diagn%C3%B3stico-de-diabetes-mellitus-sis)
- [Consumo de medicamentos en recién nacidos — SIS](https://www.datosabiertos.gob.pe/dataset/consumo-de-medicamentos-en-reci%C3%A9n-nacidos-asegurados-al-seguro-integral-de-salud)

**Fecha de descarga documentada:** 2 de septiembre de 2026. Los archivos originales se distribuyeron en formato Excel (`.xlsx`).

### ¿Dónde están los Excel y CSV?

Los archivos de origen no tienen por qué incluirse en este repositorio si su tamaño dificulta la publicación. Descárgalos desde los enlaces oficiales anteriores y conserva los nombres y formatos esperados por los scripts de importación. Los posibles archivos CSV intermedios son productos de preparación de datos y deben identificarse según el script que los genere; el informe no define un conjunto obligatorio de CSV.

> **Reproducibilidad:** los enlaces permiten recuperar las fuentes, pero si el portal publica versiones nuevas, sus datos pueden diferir de los utilizados en septiembre de 2026. Conserva localmente la versión original empleada en el proyecto.

## 3. Tecnologías

| Tecnología | Uso en el proyecto |
| --- | --- |
| SQL Server / SSMS | Base de datos operacional `DIRESA_PERU`, procedimientos almacenados, transacciones, triggers, funciones, roles, permisos, respaldos e índices |
| Python | Migración y transformación de datos para MongoDB (`openpyxl`, `pymongo`, según el informe) |
| MongoDB / Compass / mongosh | Colección documental `Recien_Nacidos` y pruebas de operaciones CRUD |
| SQL Server — Data Warehouse | `DW_DataSalud`, modelo dimensional Kimball y proceso ETL |
| Power BI Desktop | Visualización de indicadores KPI y análisis OLAP sobre el Data Warehouse |

**Apache Spark / PySpark:** incorpora el notebook y su comparación con SQL Server únicamente si dichos entregables están finalizados. La versión del informe de referencia utilizada para este README no presenta resultados de Spark verificables.

## 4. Arquitectura general

```text
Datos abiertos SIS (.xlsx)
       |
       v
Perfilado, limpieza y validación
       |
       v
SQL Server: DIRESA_PERU
       |                 \
       |                  \--> MongoDB: Recien_Nacidos
       v
ETL / controles de carga
       |
       v
Data Warehouse: DW_DataSalud
       |
       v
Power BI: KPI, dashboards y análisis OLAP
```

El proceso de recién nacidos utiliza las tablas `PRESTACIONES`, `DIAGNOSTICOS`, `MEDICAMENTOS` y sus catálogos; el de diabetes incluye `AFILIADOS` y `ATENCIONES_DIABETES`. MongoDB ofrece una representación documental complementaria del proceso de recién nacidos.

## 5. Funcionalidades implementadas

- Ingesta y validación de datos mediante procedimientos almacenados.
- Control transaccional y manejo de excepciones con `TRY/CATCH`, `COMMIT`, `ROLLBACK` y `SAVE TRANSACTION`.
- Triggers para auditoría e integridad de prestaciones.
- Función escalar `FN_CANTIDAD_DIAGNOSTICOS`.
- Seguridad basada en usuarios, roles y privilegios diferenciados.
- Política de respaldos y prueba de restauración.
- Índice para optimizar consultas por fecha de atención.
- Migración documental y pruebas CRUD en MongoDB.
- Modelo dimensional Kimball, ETL, registro `LogETL` y dashboards Power BI.

## 6. Resultados documentados

- **290 469** registros cargados en `FactPrestacionesRN`.
- **850 366** registros cargados en `FactAtencionDiabetes`.
- **1 140 835** registros validados en el Data Warehouse, con estado `EXITOSO`.
- **290 469** documentos migrados a la colección MongoDB `Recien_Nacidos`.
- Optimización de consulta SQL: tiempo transcurrido de **3 738 ms** a **130 ms** en la prueba documentada.

Estos valores corresponden a las pruebas descritas en el informe académico y no representan métricas de producción en la DIRESA.

## 7. Estructura sugerida del repositorio

> Ajustar las rutas y nombres a los archivos realmente entregados. Esta estructura es una propuesta organizativa, no una lista verificada de archivos existentes.

```text
DataSalud_Peru/
├── README.md
├── datasets/
│   └── README.md                  # Fuentes e instrucciones de descarga
├── sql_server/                    # DDL, procedimientos, triggers y pruebas
├── mongodb/                       # Script de migración y consultas CRUD
├── data_warehouse/                # Modelo dimensional, ETL y validaciones
├── power_bi/                      # Archivo .pbix
├── spark/                         # Notebook .ipynb, si está completado
└── documentacion/                 # Informe y presentación
```

## 8. Cómo reproducir el proyecto

1. **Descargar** las versiones de los datasets SIS indicadas en el apartado 2.
2. **Preparar los datos** aplicando las reglas de limpieza y validación documentadas en el informe.
3. **Crear la base SQL Server `DIRESA_PERU`** y ejecutar los scripts de tablas, relaciones y controles en su orden de dependencia.
4. **Cargar los datos operacionales** y verificar las pruebas de integridad y auditoría.
5. **Ejecutar la migración a MongoDB** para el dataset de recién nacidos y comprobar el conteo documental.
6. **Crear y cargar `DW_DataSalud`** mediante el ETL; validar dimensiones, hechos y `LogETL`.
7. **Abrir el archivo Power BI (`.pbix`)**, configurar la conexión o actualizar credenciales/rutas si corresponde y comprobar los indicadores y jerarquías OLAP.

> Los comandos exactos de ejecución, rutas de archivos y dependencias del entorno deberán detallarse junto a los scripts finales. No se incluyen credenciales ni cadenas de conexión privadas.

## 9. Seguridad y tratamiento de datos

El proyecto utiliza datos públicos anonimizados. No se debe intentar reidentificar personas ni incorporar credenciales, claves de acceso o copias de seguridad con información sensible al repositorio. El diseño incluye roles de acceso, auditoría, validaciones y mecanismos de recuperación.

## 10. Equipo

- Chávez Rojas, Leonardo Josué
- Jimenez Montes, Samantha Luciana
- Medina Manrique, Dylan Daniel
- Parra Huatuco, Britanny Karolin

**Universidad:** Universidad Privada del Norte — Sede San Juan de Lurigancho  
**Período:** 2026-2

## 11. Documentación

La descripción técnica detallada, las pruebas y las evidencias se encuentran en el informe académico del proyecto. Para comprobar los resultados, consultar especialmente los capítulos sobre SQL Server, seguridad, MongoDB, Data Warehouse y Power BI.
