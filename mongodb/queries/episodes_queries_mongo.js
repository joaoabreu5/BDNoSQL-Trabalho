// EPISODES

// 1) All info about an id_episode
function getAllInfoByEpisodeId(episodeId) {
    return db.episodes.find({
      id_episode: episodeId
    }).toArray();
  }
  
getAllInfoByEpisodeId(89);

function getAllInfoByEpisodeId_withNames(episodeId) {
    return db.episodes.aggregate([
        {
            $match: { id_episode: episodeId }
        },
        {
            $lookup: {
                from: "patients",
                localField: "id_patient",
                foreignField: "_id",
                as: "patient_info"
            }
        },
        {
            $unwind: "$patient_info"
        },
        {
            $project: {
                id_episode: 1,
                prescriptions: 1,
                bills: 1,
                lab_screenings: 1,
                hospitalization: 1,
                room: 1,
                "patient_info.patient_fname": 1,
                "patient_info.patient_lname": 1
            }
        }
    ]).toArray();
}

getAllInfoByEpisodeId_withNames(89);

// 2) All info about Hospital.Prescription
function getAllInfoByPrescriptionId(prescriptionId) {
    return db.episodes.find({
      "prescriptions.id_prescription": prescriptionId
    }).toArray();
  }
  
getAllInfoByPrescriptionId(76);
    
// 3) All info about Hospital.Prescription and just it
function getPrescriptionById(prescriptionId) {
    return db.episodes.aggregate([
      { $match: { "prescriptions.id_prescription": prescriptionId } },
      { $unwind: "$prescriptions" },
      { $match: { "prescriptions.id_prescription": prescriptionId } },
      { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
  }
  
getPrescriptionById(89);

// 4) All info about an patient_id
function getAllInfoByPatientId(id_patient_new) {
    return db.episodes.find({
        id_patient: ObjectId(id_patient_new)
    }).toArray();
}

getAllInfoByPatientId('666325843b1ae18c2cd22c4d');

// 4) Quantos episodios para um dado patient
function getPatientEpisodes(id_patient_new) {
    const patientId = ObjectId(id_patient_new);
  
    // Count the number of episodes for the given patient ID
    const episodeCount = db.episodes.countDocuments({ id_patient: patientId });
  
    return {
      count: episodeCount,
    };
  }
  
getPatientEpisodes('666325843b1ae18c2cd22c4d');
  
// 5) Buscar as presciptions para um dado id_episode
function getPrescriptionsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
      { $match: { id_episode: episodeId } },
      { $unwind: "$prescriptions" },
      { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

getPrescriptionsByEpisodeId(89);

// 6) Bills para um dado id_episode
function getBillsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
      { $match: { id_episode: episodeId } },
      { $unwind: "$bills" },
      { $project: { _id: 0, bill: "$bills" } }
    ]).toArray();
}

getBillsByEpisodeId(95);

// 7) Bill para um dado id_bill
function getBillById(billId) {
    return db.episodes.aggregate([
        { $unwind: "$bills" },
        { $match: { "bills.id_bill": billId } },
        { $project: { _id: 0, bill: "$bills" } }
    ]).toArray();
}

getBillById(29);

// 8) Labs para um dado id de episode
function getLabScreeningsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $project: { _id: 0, lab_screenings: 1 } }
    ]).toArray();
}

getLabScreeningsByEpisodeId(95);

// 9) Lab para o ID Lab
function getLabScreeningByLabId(labId) {
    return db.episodes.aggregate([
        { $unwind: "$lab_screenings" },
        { $match: { "lab_screenings.lab_id": labId } },
        { $project: { _id: 0, lab_screening: "$lab_screenings" } }
    ]).toArray();
}

getLabScreeningByLabId(16);

// 10) Hospitalization para um dado id_episode
function getHospitalizationByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $project: { _id: 0, hospitalization: 1 } }
    ]).toArray();
}

getHospitalizationByEpisodeId(95);

// 11) Buscar room por ID_Room
function getRoomById(roomId) {
    return db.episodes.aggregate([
        { $unwind: "$hospitalization.room" },
        { $match: { "hospitalization.room.id_room": roomId } },
        { $project: { _id: 0, room: "$hospitalization.room" } }
    ]).toArray();
}

getRoomById(30);

// 12) Buscar Prescriptions por id_patient
function getPrescriptionsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$prescriptions" },
        { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

getPrescriptionsByPatientId(ObjectId("666325843b1ae18c2cd22c4d"));

function getAllPrescriptionsForPatient(patientId) {
    return db.episodes.aggregate([
        {
            $match: { id_patient: ObjectId(patientId) }
        },
        {
            $unwind: "$prescriptions"
        },
        {
            $lookup: {
                from: "patients",
                localField: "id_patient",
                foreignField: "_id",
                as: "patient_info"
            }
        },
        {
            $unwind: "$patient_info"
        },
        {
            $project: {
                _id: 0,
                patient_id: "$id_patient",
                patient_fname: "$patient_info.patient_fname",
                patient_lname: "$patient_info.patient_lname",
                prescription: "$prescriptions"
            }
        }
    ]).toArray();
}

// Chamada da função
getAllPrescriptionsForPatient("666325843b1ae18c2cd22c52")

// 13) Buscar Bills por id_patient
function getBillsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$bills" },
        { $project: { _id: 0, bill: "$bills" } }
    ]).toArray();
}
 
getBillsByPatientId(ObjectId("666325843b1ae18c2cd22c4d"));

// 14) Buscar LabScreening por id_patient
function getLabScreeningsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$lab_screenings" },
        { $project: { _id: 0, lab_screening: "$lab_screenings" } }
    ]).toArray();
}

getLabScreeningsByPatientId(ObjectId("666325843b1ae18c2cd22c4d"));

// 15) Buscar Hospitalizatio por id_patient
function getHospitalizationByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $project: { _id: 0, hospitalization: 1 } }
    ]).toArray();
}

getHospitalizationByPatientId(ObjectId("666325843b1ae18c2cd22c4d"));

// 16) Buscar room por idPatient
function getRoomsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: ObjectId(patientId) } },
        { $unwind: "$hospitalization.room" },
        { $project: { _id: 0, room: "$hospitalization.room" } }
    ]).toArray();
}

getRoomsByPatientId("666325843b1ae18c2cd22c4d");

// 17) Buscar Medicine por idPatient
function getMedicinesByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: ObjectId(patientId) } },
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

getMedicinesByPatientId("666325843b1ae18c2cd22c4d");

// 18) Buscar Medicine por IdEpisode
function getMedicinesByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

getMedicinesByEpisodeId(95);

// 19) Buscar Medicine por IDMedicine
function getMedicineById(medicineId) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $match: { "prescriptions.medicine.id_medicine": medicineId } },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

getMedicineById(5);

// 20) Buscar Medicine por IDPresciption
function getMedicineByPrescriptionId(prescriptionId) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $match: { "prescriptions.id_prescription": prescriptionId } },
        { $unwind: "$prescriptions.medicine" },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

getMedicineByPrescriptionId(817);

// 21) Buscar Medicine per Name
function getMedicineByName(medicineName) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $match: { "prescriptions.medicine.m_name": medicineName } },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

getMedicineByName("Lisinopril");

// 22) Buscar prescrições em uma data específica
function getPrescriptionsByDate(date) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $match: { "prescriptions.prescription_date": new ISODate(date) } },
        { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

getPrescriptionsByDate("2022-09-29T00:00:00.000+00:00");

// 23) Buscar prescrições entre duas datas
function getPrescriptionsBetweenDates(startDate, endDate) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $match: { "prescriptions.prescription_date": { $gte: new ISODate(startDate), $lte: new ISODate(endDate) } } },
        { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

getPrescriptionsBetweenDates("2023-06-01T00:00:00Z", "2023-06-30T23:59:59Z");

// 24) Buscar prescrições entre duas dosages
function getPrescriptionsBetweenDosages(minDosage, maxDosage) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $match: { 
            "prescriptions.dosage": { $gte: minDosage, $lte: maxDosage }
        }},
        { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

getPrescriptionsBetweenDosages(10, 50);

// 25) Somar o total das faturas para um dado paciente
function getTotalBillsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: ObjectId(patientId) } },
        { $unwind: "$bills" },
        { $group: {
            _id: "$id_patient",
            totalBills: { $sum: "$bills.total" }
        }},
        { $project: { _id: 0, totalBills: 1 } }
    ]).toArray();
}

getTotalBillsByPatientId("666325843b1ae18c2cd22c4d");

// 26) Soma de todas as bills para um dado paciente
function getTotalCostsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: ObjectId(patientId) } },
        { $unwind: "$bills" },
        { $group: {
            _id: "$id_patient",
            totalRoomCost: { $sum: "$bills.room_cost" },
            totalTestCost: { $sum: "$bills.test_cost" },
            totalOtherCharges: { $sum: "$bills.other_charges" }
        }},
        { $project: {
            _id: 0,
            totalRoomCost: 1,
            totalTestCost: 1,
            totalOtherCharges: 1,
            totalCost: { $sum: ["$totalRoomCost", "$totalTestCost", "$totalOtherCharges"] }
        }}
    ]).toArray();
}

getTotalCostsByPatientId("666325843b1ae18c2cd22c4d");

// 27) LabScreening por intervalo de datas
function getLabScreeningsByDateRange(startDate, endDate) {
    return db.episodes.aggregate([
        { $unwind: "$lab_screenings" },
        { 
            $match: { 
                "lab_screenings.test_date": {
                    $gte: new ISODate(startDate),
                    $lte: new ISODate(endDate)
                }
            }
        },
        { 
            $project: { 
                _id: 0, 
                lab_screening: "$lab_screenings" 
            }
        }
    ]).toArray();
}

var startDate = "2022-09-01T00:00:00.000Z";
var endDate = "2022-09-30T23:59:59.999Z";

getLabScreeningsByDateRange(startDate, endDate);

// 28)  LabScreening por intervalo de custo
function getLabScreeningsByPriceRange(minPrice, maxPrice) {
    return db.episodes.aggregate([
        { $unwind: "$lab_screenings" },
        { 
            $match: { 
                "lab_screenings.test_cost": {
                    $gte: minPrice,
                    $lte: maxPrice
                }
            }
        },
        { 
            $project: { 
                _id: 0, 
                lab_screening: "$lab_screenings" 
            }
        }
    ]).toArray();
}

var minPrice = 150;
var maxPrice = 200;

getLabScreeningsByPriceRange(minPrice, maxPrice);

// 29) Buscar registros de hospitalização com base em um intervalo de datas de admissão e alta
function getHospitalizationsByDateRange(startDate, endDate) {
    return db.episodes.aggregate([
        { 
            $match: { 
                "hospitalization.admission_date": { $gte: new ISODate(startDate) },
                "hospitalization.discharge_date": { $lte: new ISODate(endDate) }
            }
        },
        { 
            $project: { 
                _id: 0, 
                id_episode: 1,
                id_patient: 1,
                hospitalization: 1
            }
        }
    ]).toArray();
}

var startDate = "2022-12-01T00:00:00.000Z";
var endDate = "2023-01-31T23:59:59.999Z";

getHospitalizationsByDateRange(startDate, endDate);

// 30) Buscar appointments por id_patient
function getAppointmentsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$appointment" },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var patientId = ObjectId("666325843b1ae18c2cd22c51");  
getAppointmentsByPatientId(patientId)

// 31) Buscar appointments por id_episode
function getAppointmentsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $unwind: "$appointment" },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

getAppointmentsByEpisodeId(180);

// 32) Buscar todos os appointments agendados (schedule_on) para uma data específica
function getAppointmentsByScheduleOnDate(date) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.schedule_on": new ISODate(date) } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var date = "2023-08-22T00:00:00.000Z";
getAppointmentsByScheduleOnDate(date);

// 33) Buscar todos os appointments para uma appointment_date específica
function getAppointmentsByAppointmentDate(date) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.appointment_date": new ISODate(date) } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var date = "2023-06-08T00:00:00.000Z";
getAppointmentsByAppointmentDate(date)

// 34) Buscar todos os appointments para um horário específico (appointment_time)
function getAppointmentsByAppointmentTime(time) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.appointment_time": time } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var time = "14:00";
getAppointmentsByAppointmentTime(time);

// 35) Buscar Todos os Appointments por id_doctor
function getAppointmentsByDoctorId(doctorId) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.id_doctor": doctorId } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var doctorId = ObjectId("666325853b1ae18c2cd22cae"); 
getAppointmentsByDoctorId(doctorId);

// 36) Contar Appointments por Médico (id_doctor)
db.episodes.aggregate([
        { $unwind: "$appointment" },
        { 
            $group: {
                _id: "$appointment.id_doctor",
                totalAppointments: { $sum: 1 }
            }
        },
        { 
            $project: {
                _id: 0,
                doctorId: "$_id",
                totalAppointments: 1
            }
        }
    ])

// 37) Calcular o Total de Medicamentos e Custo Total
db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $group: {
            _id: null,
            totalQuantity: { $sum: "$prescriptions.medicine.m_quantity" },
            totalCost: { $sum: "$prescriptions.medicine.m_cost" }
        }},
        { $project: {
            _id: 0,
            totalQuantity: 1,
            totalCost: 1
        }}
    ])

// 38) Calcular o Total de Cada Medicamento Usado e o Custo Total
db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $group: {
            _id: "$prescriptions.medicine.m_name",
            totalQuantity: { $sum: "$prescriptions.medicine.m_quantity" },
            totalCost: { $sum: "$prescriptions.medicine.m_cost" }
        }},
        { $sort: { totalQuantity: -1 } }, 
        { $project: {
            _id: 0,
            medicineName: "$_id",
            totalQuantity: 1,
            totalCost: 1
        }}
    ])

// 39) Calcular o Total de test_costs e a Contagem de Testes Realizados
db.episodes.aggregate([
        { $unwind: "$lab_screenings" },
        { $group: {
            _id: null,
            totalCost: { $sum: "$lab_screenings.test_cost" },
            totalCount: { $sum: 1 }
        }},
        { $project: {
            _id: 0,
            totalCost: 1,
            totalCount: 1
        }}
    ])

// 40) Buscar Todas as bills Registradas Entre Duas Datas 
function getBillsByDateRange(startDate, endDate) {
    return db.episodes.aggregate([
        { $unwind: "$bills" },
        { $match: {
            "bills.registered_at": {
                $gte: new ISODate(startDate),
                $lte: new ISODate(endDate)
            }
        }},
        { $project: {
            _id: 0,
            id_episode: 1,
            id_patient: 1,
            bill: "$bills"
        }}
    ]).toArray();
}

var startDate = "2024-04-01T00:00:00.000Z";
var endDate = "2024-04-30T23:59:59.999Z";

getBillsByDateRange(startDate, endDate);

// 41) Buscar Pacientes com um payment_status Específico
function getPatientsByPaymentStatus(status) {
    return db.episodes.aggregate([
        { $unwind: "$bills" },
        { $match: { "bills.payment_status": status } },
        { $group: {
            _id: "$id_patient",
            episodes: { $push: "$$ROOT" }
        }},
        { $lookup: {
            from: "patients", 
            localField: "_id",
            foreignField: "_id",
            as: "patient_info"
        }},
        { $unwind: "$patient_info" },
        { $project: {
            _id: 0,
            patient_id: "$_id",
            patient_fname: "$patient_info.patient_fname",
            patient_lname: "$patient_info.patient_lname",
            episodes: 1
        }}
    ]).toArray();
}

var status_new = "PENDING"; 
getPatientsByPaymentStatus(status_new);

// 42) Buscar Todas as bills com Detalhes dos Pacientes
db.episodes.aggregate([
        { $unwind: "$bills" },
        { $lookup: {
            from: "patients",  
            localField: "id_patient",
            foreignField: "_id",
            as: "patient_info"
        }},
        { $unwind: "$patient_info" },
        { $project: {
            _id: 0,
            bill: "$bills",
            patient_id: "$id_patient",
            patient_name: "$patient_info.patient_fname",  
            patient_age: "$patient_info.patient_lname",    
        }}
    ])

// 43) Calcular o Custo Total das bills Registradas Entre Duas Datas
function getTotalCostByRegisteredDate(startDate, endDate) {
    return db.episodes.aggregate([
        { $unwind: "$bills" },
        { $match: {
            "bills.registered_at": {
                $gte: new ISODate(startDate),
                $lte: new ISODate(endDate)
            }
        }},
        { $group: {
            _id: null,
            totalCost: { $sum: "$bills.total" }
        }},
        { $project: {
            _id: 0,
            totalCost: 1
        }}
    ]).toArray();
}

getTotalCostByRegisteredDate("2022-04-27T00:00:00Z", "2025-04-27T00:00:00Z");

// 44) Todos os episódios que ainda não acabaram
db.episodes.findOne({
    "hospitalization.discharge_date": null
})

// 45) Buscar enfermeira responsável para um episódio específico
function getNurseInfoByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        {
            $match: { id_episode: episodeId }
        },
        {
            $lookup: {
                from: "staff",
                localField: "hospitalization.responsible_nurse",
                foreignField: "_id",
                as: "nurse_info"
            }
        },
        {
            $unwind: "$nurse_info"
        },
        {
            $project: {
                id_episode: 1,
                id_patient: 1,
                "nurse_info.emp_fname": 1,
                "nurse_info.emp_lname": 1,
                "nurse_info.email": 1,
                "nurse_info.role": 1
            }
        }
    ]).toArray();
}

getNurseInfoByEpisodeId(89);

// 46) Obter todas as enfermeiras que já cuidaram de um determinado paciente
function getNursesByPatientId(patientId) {
    return db.episodes.aggregate([
        {
            $match: { id_patient: patientId }
        },
        {
            $lookup: {
                from: "staff",
                localField: "hospitalization.responsible_nurse",
                foreignField: "_id",
                as: "nurse_info"
            }
        },
        {
            $unwind: "$nurse_info"
        },
        {
            $group: {
                _id: "$id_patient",
                nurses: { $addToSet: "$nurse_info" }
            }
        },
        {
            $project: {
                _id: 0,
                patient_id: "$_id",
                nurses: {
                    emp_fname: 1,
                    emp_lname: 1,
                    email: 1,
                    role: 1
                }
            }
        }
    ]).toArray();
}

getNursesByPatientId(ObjectId("666325843b1ae18c2cd22c4d"));

// 47) Obter informações do médico responsável por um episódio específico
function getDoctorInfoByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        {
            $match: { id_episode: episodeId }
        },
        {
            $lookup: {
                from: "staff",
                localField: "appointment.id_doctor",
                foreignField: "_id",
                as: "doctor_info"
            }
        },
        {
            $unwind: "$doctor_info"
        },
        {
            $project: {
                id_episode: 1,
                id_patient: 1,
                "doctor_info.emp_fname": 1,
                "doctor_info.emp_lname": 1,
                "doctor_info.email": 1,
                "doctor_info.role": 1
            }
        }
    ]).toArray();
}

getDoctorInfoByEpisodeId(1);

// 48) Obter todas as informações dos médicos que atenderam um paciente específico
function getDoctorsByPatientId(patientId) {
    return db.episodes.aggregate([
        {
            $match: { id_patient: patientId }
        },
        {
            $lookup: {
                from: "staff",
                localField: "appointment.id_doctor",
                foreignField: "_id",
                as: "doctor_info"
            }
        },
        {
            $unwind: "$doctor_info"
        },
        {
            $group: {
                _id: "$id_patient",
                doctors: { $addToSet: "$doctor_info" }
            }
        },
        {
            $project: {
                _id: 0,
                patient_id: "$_id",
                doctors: {
                    emp_fname: 1,
                    emp_lname: 1,
                    email: 1,
                    role: 1
                }
            }
        }
    ]).toArray();
}

getDoctorsByPatientId(ObjectId("666325843b1ae18c2cd22c4e"));

// 49) Obter informações do técnico responsável por um episódio específico
function getTechnicianInfoByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        {
            $match: { id_episode: episodeId }
        },
        {
            $lookup: {
                from: "staff",
                localField: "lab_screenings.id_technician",
                foreignField: "_id",
                as: "technician_info"
            }
        },
        {
            $unwind: "$technician_info"
        },
        {
            $project: {
                id_episode: 1,
                id_patient: 1,
                "technician_info.emp_fname": 1,
                "technician_info.emp_lname": 1,
                "technician_info.email": 1,
                "technician_info.role": 1
            }
        }
    ]).toArray();
}

getTechnicianInfoByEpisodeId(1);

// 50) Obter todas as informações dos técnicos que atenderam um paciente específico
function getTechniciansByPatientId(patientId) {
    return db.episodes.aggregate([
        {
            $match: { id_patient: patientId }
        },
        {
            $unwind: "$lab_screenings"
        },
        {
            $lookup: {
                from: "staff",
                localField: "lab_screenings.id_technician",
                foreignField: "_id",
                as: "technician_info"
            }
        },
        {
            $unwind: "$technician_info"
        },
        {
            $group: {
                _id: "$id_patient",
                technicians: { $addToSet: "$technician_info" }
            }
        },
        {
            $project: {
                _id: 0,
                patient_id: "$_id",
                technicians: {
                    emp_fname: 1,
                    emp_lname: 1,
                    email: 1,
                    role: 1
                }
            }
        }
    ]).toArray();
}

getTechniciansByPatientId(ObjectId("666325843b1ae18c2cd22c51"));

// 51) Retornar informações de um paciente específico dado um id_patient
function getPatientInfoByIdFromEpisodes(patientId) {
    return db.episodes.aggregate([
        {
            $match: { id_patient: ObjectId(patientId) }
        },
        {
            $lookup: {
                from: "patients",
                localField: "id_patient",
                foreignField: "_id",
                as: "patient_info"
            }
        },
        {
            $unwind: "$patient_info"
        },
        {
            $project: {
                _id: 0,
                patient_id: "$patient_info.id_patient",
                patient_fname: "$patient_info.patient_fname",
                patient_lname: "$patient_info.patient_lname",
                blood_type: "$patient_info.blood_type",
                phone: "$patient_info.phone",
                email: "$patient_info.email",
                gender: "$patient_info.gender",
                birthday: "$patient_info.birthday",
                insurance: "$patient_info.insurance",
                emergency_contact: "$patient_info.emergency_contact",
                medical_history: "$patient_info.medical_history"
            }
        },
        {
            $limit: 1
        }
    ]).toArray();
}

// Chamada da função
getPatientInfoByIdFromEpisodes("666325843b1ae18c2cd22c4d");

// 52) Retornar informações de todos os pacientes 
db.episodes.aggregate([
        {
            $lookup: {
                from: "patients",
                localField: "id_patient",
                foreignField: "_id",
                as: "patient_info"
            }
        },
        {
            $unwind: "$patient_info"
        },
        {
            $group: {
                _id: "$id_patient",
                patient_info: { $first: "$patient_info" }
            }
        },
        {
            $project: {
                _id: 0,
                patient_id: "$patient_info.id_patient",
                patient_fname: "$patient_info.patient_fname",
                patient_lname: "$patient_info.patient_lname",
                // blood_type: "$patient_info.blood_type",
                // phone: "$patient_info.phone",
                // email: "$patient_info.email",
                // gender: "$patient_info.gender",
                // birthday: "$patient_info.birthday",
                // insurance: "$patient_info.insurance",
                // emergency_contact: "$patient_info.emergency_contact",
                // medical_history: "$patient_info.medical_history"
            }
        }
    ])

// 53) Listar os pacientes alocados a um específico quarto
function getPatientsByRoom(roomId) {
    return db.episodes.aggregate([
        {
            $match: { "hospitalization.room.id_room": roomId }
        },
        {
            $lookup: {
                from: "patients",
                localField: "id_patient",
                foreignField: "_id",
                as: "patient_info"
            }
        },
        {
            $unwind: "$patient_info"
        },
        {
            $project: {
                _id: 0,
                patient_id: "$patient_info._id",
                patient_fname: "$patient_info.patient_fname",
                patient_lname: "$patient_info.patient_lname",
                room: "$room"
            }
        }
    ]).toArray();
}
    
getPatientsByRoom(1)
    
// 54) Listar hospitalizações por enfermeira responsável
function getHospitalizationsByNurse(nurseId) {
    return db.episodes.aggregate([
        {
            $match: { "hospitalization.responsible_nurse": ObjectId(nurseId) }
        },
        {
            $lookup: {
                from: "staff",
                localField: "hospitalization.responsible_nurse",
                foreignField: "_id",
                as: "nurse_info"
            }
        },
        {
            $unwind: "$nurse_info"
        },
        {
            $project: {
                _id: 0,
                id_episode: 1,
                id_patient: 1,
                hospitalization: 1,
                nurse_fname: "$nurse_info.emp_fname",
                nurse_lname: "$nurse_info.emp_lname"
            }
        }
    ]).toArray();
}

getHospitalizationsByNurse("666325853b1ae18c2cd22ce9")

// 55) Listar todos os episódios médicos de um paciente específico
function getAllEpisodesForPatient(patientId) {
    return db.episodes.aggregate([
        {
            $match: { id_patient: ObjectId(patientId) }
        },
        {
            $lookup: {
                from: "patients",
                localField: "id_patient",
                foreignField: "_id",
                as: "patient_info"
            }
        },
        {
            $unwind: "$patient_info"
        },
        {
            $project: {
                _id: 0,
                id_episode: 1,
                id_patient: 1,
                patient_fname: "$patient_info.patient_fname",
                patient_lname: "$patient_info.patient_lname",
                // prescriptions: 1,
                // bills: 1,
                // lab_screenings: 1,
                // hospitalization: 1,
                // appointment: 1
            }
        }
    ]).toArray();
}

getAllEpisodesForPatient("666325843b1ae18c2cd22c52")

// 56) Listar todos os episódios médicos de um doctor
function getEpisodesByDoctor(doctorId) {
    return db.episodes.aggregate([
        {
            $match: { "appointment.id_doctor": ObjectId(doctorId) }
        },
        {
            $lookup: {
                from: "staff",
                localField: "appointment.id_doctor",
                foreignField: "_id",
                as: "doctor_info"
            }
        },
        {
            $unwind: "$doctor_info"
        },
        {
            $project: {
                _id: 0,
                id_episode: 1,
                id_patient: 1,
                doctor_fname: "$doctor_info.emp_fname",
                doctor_lname: "$doctor_info.emp_lname",
                // prescriptions: 1,
                // bills: 1,
                // lab_screenings: 1,
                // hospitalization: 1,
                appointment: 1
            }
        }
    ]).toArray();
}

getEpisodesByDoctor("666325853b1ae18c2cd22cae")

// 57) Listar exames baseados no técnico responsável
function getLabScreeningsByTechnician(technicianId) {
    return db.episodes.aggregate([
        {
            $unwind: "$lab_screenings"
        },
        {
            $match: { "lab_screenings.id_technician": ObjectId(technicianId) }
        },
        {
            $lookup: {
                from: "staff",
                localField: "lab_screenings.id_technician",
                foreignField: "_id",
                as: "technician_info"
            }
        },
        {
            $unwind: "$technician_info"
        },
        {
            $project: {
                _id: 0,
                id_episode: 1,
                id_patient: 1,
                lab_id: "$lab_screenings.lab_id",
                test_cost: "$lab_screenings.test_cost",
                test_date: "$lab_screenings.test_date",
                technician_fname: "$technician_info.emp_fname",
                technician_lname: "$technician_info.emp_lname"
            }
        }
    ]).toArray();
}

getLabScreeningsByTechnician("666325853b1ae18c2cd22d07")

// 58) Listar todos os episódios e o respectivo paciente
db.episodes.aggregate([
    {
        $lookup: {
            from: "patients",
            localField: "id_patient",
            foreignField: "_id",
            as: "patient_info"
        }
    },
    {
        $unwind: "$patient_info"
    },
    {
        $project: {
            _id: 0,
            id_episode: 1,
            id_patient: "$patient_info.id_patient$",
            patient_fname: "$patient_info.patient_fname",
            patient_lname: "$patient_info.patient_lname",
            // prescriptions: 1,
            // bills: 1
            // lab_screenings: 1,
            // hospitalization: 1,
            // appointment: 1
        }
    }
])

// 59) Buscar Appointment por data e depois por hora
function getAppointmentsByDateAndTime(date, time) {
    return db.episodes.aggregate([
        {
            $unwind: "$appointment"
        },
        {
            $match: {
                "appointment.appointment_date": new Date(date),
                "appointment.appointment_time": time
            }
        },
        {
            $lookup: {
                from: "patients",
                localField: "id_patient",
                foreignField: "_id",
                as: "patient_info"
            }
        },
        {
            $unwind: "$patient_info"
        },
        {
            $project: {
                _id: 0,
                id_episode: 1,
                id_patient: 1,
                patient_fname: "$patient_info.patient_fname",
                patient_lname: "$patient_info.patient_lname",
                appointment: 1,
            }
        }
    ]).toArray();
}

getAppointmentsByDateAndTime("2023-06-08T00:00:00.000+00:00", "14:00")

// 60) Lista os médicos com mais consultas marcadas
db.episodes.aggregate([
        {
            $unwind: "$appointment"
        },
        {
            $group: {
                _id: "$appointment.id_doctor",
                totalAppointments: { $sum: 1 }
            }
        },
        {
            $sort: { totalAppointments: -1 }
        },
        {
            $lookup: {
                from: "staff",
                localField: "_id",
                foreignField: "_id",
                as: "doctor_info"
            }
        },
        {
            $unwind: "$doctor_info"
        },
        {
            $lookup: {
                from: "episodes",
                localField: "_id",
                foreignField: "appointment.id_doctor",
                as: "appointments"
            }
        },
        {
            $project: {
                _id: 0,
                doctor_id: "$_id",
                doctor_fname: "$doctor_info.emp_fname",
                doctor_lname: "$doctor_info.emp_lname",
                doctor_email: "$doctor_info.email",
                totalAppointments: 1,
            }
        }
    ])

// 61) Lista os médicos com mais consultas marcadas, com informação detalhada do paciente
db.episodes.aggregate([
            {
                $unwind: "$appointment"
            },
            {
                $group: {
                    _id: "$appointment.id_doctor",
                    totalAppointments: { $sum: 1 }
                }
            },
            {
                $sort: { totalAppointments: -1 }
            },
            {
                $lookup: {
                    from: "staff",
                    localField: "_id",
                    foreignField: "_id",
                    as: "doctor_info"
                }
            },
            {
                $unwind: "$doctor_info"
            },
            {
                $lookup: {
                    from: "episodes",
                    localField: "doctor_info._id",
                    foreignField: "appointment.id_doctor",
                    as: "appointments"
                }
            },
            {
                $unwind: "$appointments"
            },
            {
                $lookup: {
                    from: "patients",
                    localField: "appointments.id_patient",
                    foreignField: "_id",
                    as: "patient_info"
                }
            },
            {
                $unwind: "$patient_info"
            },
            {
                $group: {
                    _id: "$_id",
                    doctor_id: { $first: "$doctor_info._id" },
                    doctor_fname: { $first: "$doctor_info.emp_fname" },
                    doctor_lname: { $first: "$doctor_info.emp_lname" },
                    doctor_email: { $first: "$doctor_info.email" },
                    totalAppointments: { $first: "$totalAppointments" },
                    patients: {
                        $push: {
                            patient_id: "$patient_info._id",
                            patient_fname: "$patient_info.patient_fname",
                            patient_lname: "$patient_info.patient_lname",
                            patient_email: "$patient_info.email",
                            appointment_id: "$appointments.appointment.appointment_id",
                            appointment_date: "$appointments.appointment.date"
                        }
                    }
                }
            },
            {
                $project: {
                    _id: 0,
                    doctor_id: 1,
                    doctor_fname: 1,
                    doctor_lname: 1,
                    doctor_email: 1,
                    totalAppointments: 1,
                    patients: 1
                }
            }
        ])

// 62) Listar todas as faturas emitidas por um médico específico
// function getBillsByDoctor(doctorId) {
//     return db.episodes.aggregate([
//         {
//             $unwind: "$appointment"
//         },
//         {
//             $match: { "appointment.id_doctor": ObjectId(doctorId) }
//         },
//         {
//             $lookup: {
//                 from: "patients",
//                 localField: "id_patient",
//                 foreignField: "_id",
//                 as: "patient_info"
//             }
//         },
//         {
//             $unwind: "$patient_info"
//         },
//         {
//             $unwind: "$bills"
//         },
//         {
//             $project: {
//                 _id: 0,
//                 id_episode: 1,
//                 id_patient: 1,
//                 patient_fname: "$patient_info.patient_fname",
//                 patient_lname: "$patient_info.patient_lname",
//                 bill_id: "$bills.bill_id",
//                 amount: "$bills.amount",
//                 date: "$bills.date",
//                 doctor_id: "$appointment.id_doctor"
//             }
//         },
//         {
//             $match: { doctor_id: ObjectId(doctorId) }
//         }
//     ]).toArray();
// }

// getBillsByDoctor("666325853b1ae18c2cd22cab")

// 62) Listar os Appointments para um dado Médico (por dia)
// function getAppointmentsByDoctorByDay(doctorId) {
//     return db.episodes.aggregate([
//         {
//             $unwind: "$appointment"
//         },
//         {
//             $addFields: {
//                 "appointment.dateString": {
//                     $dateToString: { format: "%Y-%m-%d", date: "$appointment.date" }
//                 }
//             }
//         },
//         {
//             $match: { "appointment.id_doctor": ObjectId(doctorId) }
//         },
//         {
//             $lookup: {
//                 from: "patients",
//                 localField: "id_patient",
//                 foreignField: "_id",
//                 as: "patient_info"
//             }
//         },
//         {
//             $unwind: "$patient_info"
//         },
//         {
//             $lookup: {
//                 from: "staff",
//                 localField: "appointment.id_doctor",
//                 foreignField: "_id",
//                 as: "staff_info"
//             }
//         },
//         {
//             $unwind: "$staff_info"
//         },
//         {
//             $group: {
//                 _id: {
//                     date: "$appointment.dateString",
//                     doctor_id: "$staff_info.emp_id"
//                 },
//                 appointments: {
//                     $push: {
//                         appointment_id: "$appointment.appointment_id",
//                         appointment_date: "$appointment.date",
//                         appointment_time: "$appointment.time",
//                         patient_id: "$patient_info._id",
//                         patient_fname: "$patient_info.patient_fname",
//                         patient_lname: "$patient_info.patient_lname"
//                     }
//                 },
//                 total_appointments: { $sum: 1 },
//                 doctor_lname: { $first: "$staff_info.emp_lname" },
//                 doctor_fname: { $first: "$staff_info.emp_fname" }
//             }
//         },
//         {
//             $project: {
//                 _id: 1,
//                 date: "$_id.date",
//                 doctor_id: "$_id.doctor_id",
//                 doctor_lname: 1,
//                 doctor_fname: 1,
//                 total_appointments: 1,
//                 appointments: 1
//             }
//         },
//         {
//             $sort: { date: 1 }
//         }
//     ]).toArray();
// }

// // Example usage
// getAppointmentsByDoctorByDay("666325853b1ae18c2cd22cc0");
