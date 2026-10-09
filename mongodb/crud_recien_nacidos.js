CREATE

db.Recien_Nacidos.insertOne({
    _id: "TEST_CRUD_001",
    fecha_corte: new Date("2025-09-18"),

    afiliado: {
        codigo_anonimizado: "PRUEBA_CRUD_ANONIMIZADO",
        sexo: "FEMENINO",
        edad_dias: 5,
        peso_kg: 3.1
    },

    atencion: {
        fecha_atencion: new Date("2026-09-01"),
        dias_hospitalizacion: 3,
        es_capita: false,

        establecimiento: {
            ubigeo: "130101",
            departamento: "LA LIBERTAD",
            provincia: "TRUJILLO",
            distrito: "TRUJILLO",
            nivel_eess: "3"
        },

        servicio_prestacional: {
            codigo: "051",
            descripcion: "Internamiento del RN con patología no quirurgica"
        }
    },

    diagnosticos: []
})


READ

db.Recien_Nacidos.findOne({ _id: "TEST_CRUD_001" }) 


UPDATE

db.Recien_Nacidos.updateOne( 
 { _id: "TEST_CRUD_001" }, 
 { $set: { "afiliado.sexo": "MASCULINO", "atencion.dias_hospitalizacion": 4 }} 
) 

verificación:
db.Recien_Nacidos.findOne({ _id: "TEST_CRUD_001" }, { afiliado: 1, "atencion.dias_hospitalizacion": 1})

DELETE

db.Recien_Nacidos.deleteOne({ _id: "TEST_CRUD_001" }) 

verificación:
db.Recien_Nacidos.findOne({ _id: "TEST_CRUD_001" }) 
