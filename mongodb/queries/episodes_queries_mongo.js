db = db.getSiblingDB('hospital');

// EPISODES VISION

// 1) All info about an id_episode
function getAllInfoByEpisodeId(episodeId) {
    return db.episodes.find({
      id_episode: episodeId
    }).toArray();
}


console.log('\n\nAll info about id_episode 89:');
console.log(getAllInfoByEpisodeId(89));

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

console.log('\n\nAll info about id_episode 89 with patient names:');
console.log(getAllInfoByEpisodeId_withNames(89));


// 2) All info about Hospital.Prescription
function getAllInfoByPrescriptionId(prescriptionId) {
    return db.episodes.find({
      "prescriptions.id_prescription": prescriptionId
    }).toArray();
}

console.log('\n\nAll info about prescription id 76:');
console.log(getAllInfoByPrescriptionId(76));

    
// 3) All info about Hospital.Prescription and just it
function getPrescriptionById(prescriptionId) {
    return db.episodes.aggregate([
      { $match: { "prescriptions.id_prescription": prescriptionId } },
      { $unwind: "$prescriptions" },
      { $match: { "prescriptions.id_prescription": prescriptionId } },
      { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

console.log('\n\nPrescription info for prescription id 89:');
console.log(getPrescriptionById(89));


// 4) All info about an patient_id
function getAllInfoByPatientId(id_patient_new) {
    return db.episodes.find({
        id_patient: ObjectId(id_patient_new)
    }).toArray();
}

console.log('\n\nAll info about patient id 666325843b1ae18c2cd22c4d:');
console.log(getAllInfoByPatientId('666325843b1ae18c2cd22c4d'));


// 4) Quantos episodios para um dado patient
function getPatientEpisodes(id_patient_new) {
    const patientId = ObjectId(id_patient_new);
  
    // Count the number of episodes for the given patient ID
    const episodeCount = db.episodes.countDocuments({ id_patient: patientId });
  
    return {
      count: episodeCount,
    };
}

console.log('\n\nNumber of episodes for patient id 666325843b1ae18c2cd22c4d:');
console.log(getPatientEpisodes('666325843b1ae18c2cd22c4d'));

  
// 5) Buscar as presciptions para um dado id_episode
function getPrescriptionsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
      { $match: { id_episode: episodeId } },
      { $unwind: "$prescriptions" },
      { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

console.log('\n\nPrescriptions for episode id 89:');
console.log(getPrescriptionsByEpisodeId(89));


// 6) Bills para um dado id_episode
function getBillsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
      { $match: { id_episode: episodeId } },
      { $unwind: "$bills" },
      { $project: { _id: 0, bill: "$bills" } }
    ]).toArray();
}

console.log('\n\nBills for episode id 95:');
console.log(getBillsByEpisodeId(95));


// 7) Bill para um dado id_bill
function getBillById(billId) {
    return db.episodes.aggregate([
        { $unwind: "$bills" },
        { $match: { "bills.id_bill": billId } },
        { $project: { _id: 0, bill: "$bills" } }
    ]).toArray();
}

console.log('\n\nBill info for bill id 29:');
console.log(getBillById(29));


// 8) Labs para um dado id de episode
function getLabScreeningsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $project: { _id: 0, lab_screenings: 1 } }
    ]).toArray();
}

console.log('\n\nLab screenings for episode id 95:');
console.log(getLabScreeningsByEpisodeId(95));


// 9) Lab para o ID Lab
function getLabScreeningByLabId(labId) {
    return db.episodes.aggregate([
        { $unwind: "$lab_screenings" },
        { $match: { "lab_screenings.lab_id": labId } },
        { $project: { _id: 0, lab_screening: "$lab_screenings" } }
    ]).toArray();
}

console.log('\n\nLab screening info for lab id 16:');
console.log(getLabScreeningByLabId(16));


// 10) Hospitalization para um dado id_episode
function getHospitalizationByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $project: { _id: 0, hospitalization: 1 } }
    ]).toArray();
}

console.log('\n\nHospitalization info for episode id 95:');
console.log(getHospitalizationByEpisodeId(95));


// 11) Buscar room por ID_Room
function getRoomById(roomId) {
    return db.episodes.aggregate([
        { $unwind: "$hospitalization.room" },
        { $match: { "hospitalization.room.id_room": roomId } },
        { $project: { _id: 0, room: "$hospitalization.room" } }
    ]).toArray();
}

console.log('\n\nRoom info for room id 30:');
console.log(getRoomById(30));


// 12) Buscar Prescriptions por id_patient
function getPrescriptionsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$prescriptions" },
        { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

console.log('\n\nPrescriptions for patient id 666325843b1ae18c2cd22c4d:');
console.log(getPrescriptionsByPatientId(ObjectId("666325843b1ae18c2cd22c4d")));


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

console.log('\n\nAll prescriptions for patient id 666325843b1ae18c2cd22c52:');
console.log(getAllPrescriptionsForPatient("666325843b1ae18c2cd22c52"));


// 13) Buscar Bills por id_patient
function getBillsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$bills" },
        { $project: { _id: 0, bill: "$bills" } }
    ]).toArray();
}

console.log('\n\nBills for patient id 666325843b1ae18c2cd22c4d:');
console.log(getBillsByPatientId(ObjectId("666325843b1ae18c2cd22c4d")));


// 14) Buscar LabScreening por id_patient
function getLabScreeningsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$lab_screenings" },
        { $project: { _id: 0, lab_screening: "$lab_screenings" } }
    ]).toArray();
}

console.log('\n\nLab screenings for patient id 666325843b1ae18c2cd22c4d:');
console.log(getLabScreeningsByPatientId(ObjectId("666325843b1ae18c2cd22c4d")));


// 15) Buscar Hospitalizatio por id_patient
function getHospitalizationByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $project: { _id: 0, hospitalization: 1 } }
    ]).toArray();
}

console.log('\n\nHospitalization info for patient id 666325843b1ae18c2cd22c4d:');
console.log(getHospitalizationByPatientId(ObjectId("666325843b1ae18c2cd22c4d")));


// 16) Buscar room por idPatient
function getRoomsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: ObjectId(patientId) } },
        { $unwind: "$hospitalization.room" },
        { $project: { _id: 0, room: "$hospitalization.room" } }
    ]).toArray();
}

console.log('\n\nRooms for patient id 666325843b1ae18c2cd22c4d:');
console.log(getRoomsByPatientId("666325843b1ae18c2cd22c4d"));


// 17) Buscar Medicine por idPatient
function getMedicinesByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: ObjectId(patientId) } },
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

console.log('\n\nMedicines for patient id 666325843b1ae18c2cd22c4d:');
console.log(getMedicinesByPatientId("666325843b1ae18c2cd22c4d"));


// 18) Buscar Medicine por IdEpisode
function getMedicinesByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

console.log('\n\nMedicines for episode id 95:');
console.log(getMedicinesByEpisodeId(95));


// 19) Buscar Medicine por IDMedicine
function getMedicineById(medicineId) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $match: { "prescriptions.medicine.id_medicine": medicineId } },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

console.log('\n\nMedicine info for medicine id 5:');
console.log(getMedicineById(5));


// 20) Buscar Medicine por IDPresciption
function getMedicineByPrescriptionId(prescriptionId) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $match: { "prescriptions.id_prescription": prescriptionId } },
        { $unwind: "$prescriptions.medicine" },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

console.log('\n\nMedicines for prescription id 817:');
console.log(getMedicineByPrescriptionId(817));


// 21) Buscar Medicine per Name
function getMedicineByName(medicineName) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $unwind: "$prescriptions.medicine" },
        { $match: { "prescriptions.medicine.m_name": medicineName } },
        { $project: { _id: 0, medicine: "$prescriptions.medicine" } }
    ]).toArray();
}

console.log('\n\nMedicine info for name Lisinopril:');
console.log(getMedicineByName("Lisinopril"));


// 22) Buscar prescrições em uma data específica
function getPrescriptionsByDate(date) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $match: { "prescriptions.prescription_date": new ISODate(date) } },
        { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

console.log('\n\nPrescriptions on date 2022-09-29:');
console.log(getPrescriptionsByDate("2022-09-29T00:00:00.000+00:00"));


// 23) Buscar prescrições entre duas datas
function getPrescriptionsBetweenDates(startDate, endDate) {
    return db.episodes.aggregate([
        { $unwind: "$prescriptions" },
        { $match: { "prescriptions.prescription_date": { $gte: new ISODate(startDate), $lte: new ISODate(endDate) } } },
        { $project: { _id: 0, prescription: "$prescriptions" } }
    ]).toArray();
}

console.log('\n\nPrescriptions between dates 2023-06-01 and 2023-06-30:');
console.log(getPrescriptionsBetweenDates("2023-06-01T00:00:00Z", "2023-06-30T23:59:59Z"));


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

console.log('\n\nPrescriptions between dosages 10 and 50:');
console.log(getPrescriptionsBetweenDosages(10, 50));


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

console.log('\n\nTotal bills for patient id 666325843b1ae18c2cd22c4d:');
console.log(getTotalBillsByPatientId("666325843b1ae18c2cd22c4d"));


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

console.log('\n\nTotal costs for patient id 666325843b1ae18c2cd22c4d:');
console.log(getTotalCostsByPatientId("666325843b1ae18c2cd22c4d"));


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

console.log('\n\nLab screenings between dates 2022-09-01 and 2022-09-30:');
console.log(getLabScreeningsByDateRange(startDate, endDate));


// 28) LabScreening por intervalo de custo
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

console.log('\n\nLab screenings between prices 150 and 200:');
console.log(getLabScreeningsByPriceRange(minPrice, maxPrice));


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

console.log('\n\nHospitalizations between dates 2022-12-01 and 2023-01-31:');
console.log(getHospitalizationsByDateRange(startDate, endDate));


// 30) Buscar appointments por id_patient
function getAppointmentsByPatientId(patientId) {
    return db.episodes.aggregate([
        { $match: { id_patient: patientId } },
        { $unwind: "$appointment" },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var patientId = ObjectId("666325843b1ae18c2cd22c51");  

console.log('\n\nAppointments for patient id 666325843b1ae18c2cd22c51:');
console.log(getAppointmentsByPatientId(patientId));


// 31) Buscar appointments por id_episode
function getAppointmentsByEpisodeId(episodeId) {
    return db.episodes.aggregate([
        { $match: { id_episode: episodeId } },
        { $unwind: "$appointment" },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

console.log('\n\nAppointments for episode id 180:');
console.log(getAppointmentsByEpisodeId(180));


// 32) Buscar todos os appointments agendados (schedule_on) para uma data específica
function getAppointmentsByScheduleOnDate(date) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.schedule_on": new ISODate(date) } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var date = "2023-08-22T00:00:00.000Z";

console.log('\n\nAppointments scheduled on date 2023-08-22:');
console.log(getAppointmentsByScheduleOnDate(date));


// 33) Buscar todos os appointments para uma appointment_date específica
function getAppointmentsByAppointmentDate(date) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.appointment_date": new ISODate(date) } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var date = "2023-06-08T00:00:00.000Z";

console.log('\n\nAppointments on appointment date 2023-06-08:');
console.log(getAppointmentsByAppointmentDate(date));


// 34) Buscar todos os appointments para um horário específico (appointment_time)
function getAppointmentsByAppointmentTime(time) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.appointment_time": time } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var time = "14:00";

console.log('\n\nAppointments at time 14:00:');
console.log(getAppointmentsByAppointmentTime(time));


// 35) Buscar Todos os Appointments por id_doctor
function getAppointmentsByDoctorId(doctorId) {
    return db.episodes.aggregate([
        { $unwind: "$appointment" },
        { $match: { "appointment.id_doctor": doctorId } },
        { $project: { _id: 0, appointment: 1 } }
    ]).toArray();
}

var doctorId = ObjectId("666325853b1ae18c2cd22cae"); 

console.log('\n\nAppointments for doctor id 666325853b1ae18c2cd22cae:');
console.log(getAppointmentsByDoctorId(doctorId));


// 36) Contar Appointments por Médico (id_doctor)
const appointmentsByDoctor = db.episodes.aggregate([
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
]).toArray();

console.log('\n\nCount of appointments by doctor:');
console.log(appointmentsByDoctor);


// 37) Calcular o Total de Medicamentos e Custo Total
const totalMedicinesAndCost = db.episodes.aggregate([
    { $unwind: "$prescriptions" },
    { 
        $group: {
            _id: null,
            totalQuantity: { $sum: "$prescriptions.medicine.m_quantity" },
            totalCost: { $sum: "$prescriptions.medicine.m_cost" }
        }
    },
    { 
        $project: {
            _id: 0,
            totalQuantity: 1,
            totalCost: 1
        }
    }
]).toArray();

console.log('\n\nTotal quantity and cost of all medicines:');
console.log(totalMedicinesAndCost);


// 38) Calcular o Total de Cada Medicamento Usado e o Custo Total
const eachMedicineTotalAndCost = db.episodes.aggregate([
    { $unwind: "$prescriptions" },
    { 
        $group: {
            _id: "$prescriptions.medicine.m_name",
            totalQuantity: { $sum: "$prescriptions.medicine.m_quantity" },
            totalCost: { $sum: "$prescriptions.medicine.m_cost" }
        }
    },
    { $sort: { totalQuantity: -1 } }, 
    { 
        $project: {
            _id: 0,
            medicineName: "$_id",
            totalQuantity: 1,
            totalCost: 1
        }
    }
]).toArray();

console.log('\n\nTotal quantity and cost of each medicine used:');
console.log(eachMedicineTotalAndCost);


// 39) Calcular o Total de test_costs e a Contagem de Testes Realizados
const totalTestCostsAndCount = db.episodes.aggregate([
    { $unwind: "$lab_screenings" },
    { 
        $group: {
            _id: null,
            totalCost: { $sum: "$lab_screenings.test_cost" },
            totalCount: { $sum: 1 }
        }
    },
    { 
        $project: {
            _id: 0,
            totalCost: 1,
            totalCount: 1
        }
    }
]).toArray();

console.log('\n\nTotal test costs and count of tests performed:');
console.log(totalTestCostsAndCount);


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

console.log('\n\nBills registered between dates 2024-04-01 and 2024-04-30:');
console.log(getBillsByDateRange(startDate, endDate));


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

console.log('\n\nPatients with payment status PENDING:');
console.log(getPatientsByPaymentStatus(status_new));


// 42) Buscar Todas as bills com Detalhes dos Pacientes
const allBillsWithPatientDetails = db.episodes.aggregate([
    { $unwind: "$bills" },
    { 
        $lookup: {
            from: "patients",
            localField: "id_patient",
            foreignField: "_id",
            as: "patient_info"
        }
    },
    { $unwind: "$patient_info" },
    { 
        $project: {
            _id: 0,
            bill: "$bills",
            patient_id: "$id_patient",
            patient_first_name: "$patient_info.patient_fname",
            patient_last_name: "$patient_info.patient_lname",
        }
    }
]).toArray();

console.log('\n\nAll bills with patient details:');
console.log(allBillsWithPatientDetails);


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

console.log('\n\nTotal cost of bills registered between dates 2022-04-27 and 2025-04-27:');
console.log(getTotalCostByRegisteredDate("2022-04-27T00:00:00Z", "2025-04-27T00:00:00Z"));


// 44) Todos os episódios que ainda não acabaram
const episodesNotEnded = db.episodes.find({
    "hospitalization.discharge_date": null
}).toArray();

console.log('\n\nAll episodes that have not ended:');
console.log(episodesNotEnded);


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

console.log('\n\nNurse info for episode id 89:');
console.log(getNurseInfoByEpisodeId(89));


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

console.log('\n\nNurses for patient id 666325843b1ae18c2cd22c4d:');
console.log(getNursesByPatientId(ObjectId("666325843b1ae18c2cd22c4d")));


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

console.log('\n\nDoctor info for episode id 1:');
console.log(getDoctorInfoByEpisodeId(1));


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

console.log('\n\nDoctors for patient id 666325843b1ae18c2cd22c4e:');
console.log(getDoctorsByPatientId(ObjectId("666325843b1ae18c2cd22c4e")));


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

console.log('\n\nTechnician info for episode id 1:');
console.log(getTechnicianInfoByEpisodeId(1));


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

console.log('\n\nTechnicians for patient id 666325843b1ae18c2cd22c51:');
console.log(getTechniciansByPatientId(ObjectId("666325843b1ae18c2cd22c51")));


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

console.log('\n\nPatient info for patient id 666325843b1ae18c2cd22c4d:');
console.log(getPatientInfoByIdFromEpisodes("666325843b1ae18c2cd22c4d"));


// 52) Retornar informações de todos os pacientes 
const allPatientInfoFromEpisodes = db.episodes.aggregate([
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
            patient_id: "$patient_info._id",
            patient_fname: "$patient_info.patient_fname",
            patient_lname: "$patient_info.patient_lname"
        }
    }
]).toArray();

console.log('\n\nAll patient info from episodes:');
console.log(allPatientInfoFromEpisodes);


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

console.log('\n\nPatients allocated to room id 1:');
console.log(getPatientsByRoom(1));


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

console.log('\n\nHospitalizations by nurse id 666325853b1ae18c2cd22ce9:');
console.log(getHospitalizationsByNurse("666325853b1ae18c2cd22ce9"));


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
                patient_lname: "$patient_info.patient_lname"
            }
        }
    ]).toArray();
}

console.log('\n\nAll episodes for patient id 666325843b1ae18c2cd22c52:');
console.log(getAllEpisodesForPatient("666325843b1ae18c2cd22c52"));


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
                appointment: 1
            }
        }
    ]).toArray();
}

console.log('\n\nEpisodes by doctor id 666325853b1ae18c2cd22cae:');
console.log(getEpisodesByDoctor("666325853b1ae18c2cd22cae"));


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

console.log('\n\nLab screenings by technician id 666325853b1ae18c2cd22d07:');
console.log(getLabScreeningsByTechnician("666325853b1ae18c2cd22d07"));


// 58) Listar todos os episódios e o respectivo paciente
const allEpisodesAndPatients = db.episodes.aggregate([
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
            id_episode: "$_id",
            id_patient: "$patient_info._id",
            patient_fname: "$patient_info.patient_fname",
            patient_lname: "$patient_info.patient_lname"
        }
    }
]).toArray();

console.log('\n\nAll episodes and respective patients:');
console.log(allEpisodesAndPatients);


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

console.log('\n\nAppointments by date 2023-06-08 and time 14:00:');
console.log(getAppointmentsByDateAndTime("2023-06-08T00:00:00.000+00:00", "14:00"));


// 60) Lista os médicos com mais consultas marcadas
const doctorsWithMostAppointments = db.episodes.aggregate([
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
        $project: {
            _id: 0,
            doctor_id: "$_id",
            doctor_fname: "$doctor_info.emp_fname",
            doctor_lname: "$doctor_info.emp_lname",
            doctor_email: "$doctor_info.email",
            totalAppointments: 1,
        }
    }
]).toArray();

console.log('\n\nDoctors with most appointments:');
console.log(doctorsWithMostAppointments);


// 61) Lista os médicos com mais consultas marcadas, com informação detalhada do paciente
const doctorsWithMostAppointmentsDetailed = db.episodes.aggregate([
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
]).toArray();

console.log('\n\nDoctors with most appointments, detailed patient info:');
console.log(doctorsWithMostAppointmentsDetailed);
