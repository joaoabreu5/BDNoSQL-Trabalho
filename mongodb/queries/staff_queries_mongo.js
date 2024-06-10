db = db.getSiblingDB('hospital');

// STAFF VISION

// 1) Buscar toda a Informação de um Staff
function getStaffInfo(emp_id) {
    return db.staff.findOne({
      emp_id: emp_id
    });
  }
  
getStaffInfo(19);

// 2) Buscar o Department para um dado ID
function getDepartmentInfo(emp_id) {
    var employee = db.staff.findOne({ emp_id: emp_id });
    if (employee && employee.department) {
      return employee.department;
    } else {
      return null; 
    }
  }

getDepartmentInfo(19);

// 3) Buscar toda a informação das Enfermeiras
db.staff.find({ role: "NURSE" }).toArray();

// 4) Buscar toda a informação dos Médicos
db.staff.find({ role: "DOCTOR" }).toArray();

// 5) Buscar toda a informação dos Técnicos
db.staff.find({ role: "TECHNICIAN" }).toArray();

// 6) Buscar quantos Enfermeiros existem
db.staff.countDocuments({ role: "NURSE" });
  
// 7) Buscar quantos Doutores existem
db.staff.countDocuments({ role: "DOCTOR" });
  
// 8) Buscar quantos Técnicos existem
db.staff.countDocuments({ role: "TECHNICIAN" });
  
// 9) Buscar quantos nurses, doctor e técnicos existem
function countStaffByRole() {
    var nurseCount = db.staff.countDocuments({ role: "NURSE" });
    var doctorCount = db.staff.countDocuments({ role: "DOCTOR" });
    var technicianCount = db.staff.countDocuments({ role: "TECHNICIAN" });
  
    return {
      nurses: nurseCount,
      doctors: doctorCount,
      technicians: technicianCount
    };
  }

// 10) Buscar quantos Departments existem
db.staff.aggregate([
      {
        $group: {
          _id: "$department.id_department"
        }
      },
      {
        $count: "numberOfDepartments"
      }
    ])
  
// 11) Buscar Staff por Date_Joining
function AllInfoStaffByDateJoining(date_joining) {
    // Convert date_joining to ISODate format if necessary
    var date_joining_iso = new Date(date_joining);
  
    return db.staff.find({
      date_joining: date_joining_iso
    }).toArray();
  }
  
AllInfoStaffByDateJoining("2023-05-10T00:00:00Z");
  
// 12) Buscar Staff por Date_Separation
function AllInfoStaffByDateSeparation(date_separation_str) {
    // Convert date_separation_str to ISODate format if necessary
    var date_separation = new Date(date_separation_str);
  
    return db.staff.find({
      date_separation: date_separation
    }).toArray();
  }
  
AllInfoStaffByDateSeparation("2018-10-02T00:00:00.000+00:00");

// 13) Get Staff Members that are active or inactive
function getStaffByActiveStatus(is_active_status) {
    return db.staff.find({
      is_active_status: is_active_status
    }).toArray();
  }
  
getStaffByActiveStatus(true);

getStaffByActiveStatus(false);

// 14) Qualifications de um Doctor por ID
function getQualificationsByDoctor(emp_id) {
    var doctor = db.staff.findOne({
      emp_id: emp_id,
      role: "DOCTOR"
    });
  
    if (doctor && doctor.qualifications) {
      return doctor.qualifications;
    } else {
      return null;
    }
  }
  
  getQualificationsByDoctor(6);

// 15) Todos os tipos de Qualifications
db.staff.aggregate([
      { $match: { role: "DOCTOR" } },
      { $unwind: "$qualifications" },
      { $group: { _id: "$qualifications" } }
    ])

// 16) Get the number of Employers per Department
db.staff.aggregate([
      {
        $group: {
          _id: "$department.id_department",
          numberOfEmployees: { $sum: 1 }
        }
      },
      {
        $project: {
          _id: 0,
          department: "$_id",
          numberOfEmployees: 1
        }
      }
    ])

// 17) Nurses per Department
db.staff.aggregate([
      {
        $match: { role: "NURSE" } 
      },
      {
        $group: {
          _id: "$department.id_department",
          numberOfNurses: { $sum: 1 }
        }
      },
      {
        $project: {
          _id: 0,
          department: "$_id",
          numberOfNurses: 1
        }
      }
    ])
  
// 18) Number os Doctors per Department
db.staff.aggregate([
    {
      $match: { role: "DOCTOR" }  
    },
    {
      $group: {
        _id: "$department.id_department",
        numberOfDoctors: { $sum: 1 }
      }
    },
    {
      $project: {
        _id: 0,
        department: "$_id",
        numberOfDoctors: 1
      }
    }
  ])

// 19) Number os Technicians per Department
db.staff.aggregate([
    {
      $match: { role: "TECHNICIAN" }  
    },
    {
      $group: {
        _id: "$department.id_department",
        numberOfTechnicians: { $sum: 1 }
      }
    },
    {
      $project: {
        _id: 0,
        department: "$_id",
        numberOfTechnicians: 1
      }
    }
  ])

// 20) Buscar Todos os Staff que Estão Ativos
db.staff.find({ is_active_status: true }).toArray();

// 21) Buscar Todos os Staff que não estão Ativos
db.staff.find({ is_active_status: false }).toArray();

// 22) Contar Quantos Staff Estão Ativos
db.staff.countDocuments({ is_active_status: true });

// 23) Contar Quantos Staff não estão Ativos
db.staff.countDocuments({ is_active_status: false });

// 24) Buscar Staff pelo Primeiro Nome (emp_fname) e Sobrenome (emp_lname)
function getStaffByName(firstName, lastName) {
  return db.staff.findOne({ emp_fname: firstName, emp_lname: lastName });
}

var firstName = "Lisa";
var lastName = "Hayes";

getStaffByName(firstName, lastName);

// 25) Buscar Staff pelo Email
function getStaffByEmail(email) {
  return db.staff.findOne({ email: email });
}

var email = "mprice@example.com";

getStaffByEmail(email);

// 26) Contar o Número Total de Staff
db.staff.countDocuments();

// 27) Buscar Staff pelo SSN
function getStaffBySSN(ssn_new) {
  return db.staff.findOne({ ssn: ssn_new });
}

var ssn_new2 = 105899430;  
getStaffBySSN(ssn_new2);