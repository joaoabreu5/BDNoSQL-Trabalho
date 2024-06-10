db = db.getSiblingDB('hospital');

// STAFF VISION

// 1) Buscar toda a Informação de um Staff
function getStaffInfo(emp_id) {
  return db.staff.findOne({
      emp_id: emp_id
  });
}

console.log('\n\nAll info about staff id 19:');
console.log(getStaffInfo(19));


// 2) Buscar o Department para um dado ID
function getDepartmentInfo(emp_id) {
  var employee = db.staff.findOne({ emp_id: emp_id });
  if (employee && employee.department) {
      return employee.department;
  } else {
      return null;
  }
}

console.log('\n\nDepartment info for staff id 19:');
console.log(getDepartmentInfo(19));


// 3) Buscar toda a informação das Enfermeiras
const allNursesInfo = db.staff.find({ role: "NURSE" }).toArray();

console.log('\n\nAll info about nurses:');
console.log(allNursesInfo);


// 4) Buscar toda a informação dos Médicos
const allDoctorsInfo = db.staff.find({ role: "DOCTOR" }).toArray();

console.log('\n\nAll info about doctors:');
console.log(allDoctorsInfo);


// 5) Buscar toda a informação dos Técnicos
const allTechniciansInfo = db.staff.find({ role: "TECHNICIAN" }).toArray();

console.log('\n\nAll info about technicians:');
console.log(allTechniciansInfo);


// 6) Buscar quantos Enfermeiros existem
const numberOfNurses = db.staff.countDocuments({ role: "NURSE" });

console.log('\n\nNumber of nurses:');
console.log(numberOfNurses);


// 7) Buscar quantos Doutores existem
const numberOfDoctors = db.staff.countDocuments({ role: "DOCTOR" });

console.log('\n\nNumber of doctors:');
console.log(numberOfDoctors);


// 8) Buscar quantos Técnicos existem
const numberOfTechnicians = db.staff.countDocuments({ role: "TECHNICIAN" });

console.log('\n\nNumber of technicians:');
console.log(numberOfTechnicians);


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

console.log('\n\nCount of nurses, doctors, and technicians:');
console.log(countStaffByRole());


// 10) Buscar quantos Departments existem
const numberOfDepartments = db.staff.aggregate([
  {
      $group: {
          _id: "$department.id_department"
      }
  },
  {
      $count: "numberOfDepartments"
  }
]).toArray();

console.log('\n\nNumber of departments:');
console.log(numberOfDepartments);


// 11) Buscar Staff por Date_Joining
function AllInfoStaffByDateJoining(date_joining) {
  // Convert date_joining to ISODate format if necessary
  var date_joining_iso = new Date(date_joining);

  return db.staff.find({
      date_joining: date_joining_iso
  }).toArray();
}

console.log('\n\nStaff info by joining date 2023-05-10:');
console.log(AllInfoStaffByDateJoining("2023-05-10T00:00:00Z"));


// 12) Buscar Staff por Date_Separation
function AllInfoStaffByDateSeparation(date_separation_str) {
  // Convert date_separation_str to ISODate format if necessary
  var date_separation = new Date(date_separation_str);

  return db.staff.find({
      date_separation: date_separation
  }).toArray();
}

console.log('\n\nStaff info by separation date 2018-10-02:');
console.log(AllInfoStaffByDateSeparation("2018-10-02T00:00:00.000+00:00"));


// 13) Get Staff Members that are active or inactive
function getStaffByActiveStatus(is_active_status) {
  return db.staff.find({
      is_active_status: is_active_status
  }).toArray();
}

console.log('\n\nActive staff members:');
console.log(getStaffByActiveStatus(true));

console.log('\n\nInactive staff members:');
console.log(getStaffByActiveStatus(false));


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

console.log('\n\nQualifications of doctor with id 6:');
console.log(getQualificationsByDoctor(6));


// 15) Todos os tipos de Qualifications
const doctorQualifications = db.staff.aggregate([
  { $match: { role: "DOCTOR" } },
  { $unwind: "$qualifications" },
  { $group: { _id: "$qualifications" } }
]).toArray();

console.log('\n\nAll types of doctor qualifications:');
console.log(doctorQualifications);


// 16) Get the number of Employers per Department
const employeesPerDepartment = db.staff.aggregate([
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
]).toArray();

console.log('\n\nNumber of employees per department:');
console.log(employeesPerDepartment);


// 17) Nurses per Department
const nursesPerDepartment = db.staff.aggregate([
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
]).toArray();

console.log('\n\nNumber of nurses per department:');
console.log(nursesPerDepartment);


// 18) Number of Doctors per Department
const doctorsPerDepartment = db.staff.aggregate([
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
]).toArray();

console.log('\n\nNumber of doctors per department:');
console.log(doctorsPerDepartment);


// 19) Number of Technicians per Department
const techniciansPerDepartment = db.staff.aggregate([
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
]).toArray();

console.log('\n\nNumber of technicians per department:');
console.log(techniciansPerDepartment);


// 20) Buscar Todos os Staff que Estão Ativos
const activeStaffMembers = db.staff.find({ is_active_status: true }).toArray();

console.log('\n\nAll active staff members:');
console.log(activeStaffMembers);


// 21) Buscar Todos os Staff que não estão Ativos
const inactiveStaffMembers = db.staff.find({ is_active_status: false }).toArray();

console.log('\n\nAll inactive staff members:');
console.log(inactiveStaffMembers);


// 22) Contar Quantos Staff Estão Ativos
const activeStaffCount = db.staff.countDocuments({ is_active_status: true });

console.log('\n\nCount of active staff members:');
console.log(activeStaffCount);


// 23) Contar Quantos Staff não estão Ativos
const inactiveStaffCount = db.staff.countDocuments({ is_active_status: false });

console.log('\n\nCount of inactive staff members:');
console.log(inactiveStaffCount);


// 24) Buscar Staff pelo Primeiro Nome (emp_fname) e Sobrenome (emp_lname)
function getStaffByName(firstName, lastName) {
  return db.staff.findOne({ emp_fname: firstName, emp_lname: lastName });
}

var firstName = "Lisa";
var lastName = "Hayes";

console.log(`\n\nStaff with name ${firstName} ${lastName}:`);
console.log(getStaffByName(firstName, lastName));


// 25) Buscar Staff pelo Email
function getStaffByEmail(email) {
  return db.staff.findOne({ email: email });
}

var email = "mprice@example.com";

console.log(`\n\nStaff with email ${email}:`);
console.log(getStaffByEmail(email));


// 26) Contar o Número Total de Staff
console.log('\n\nTotal number of staff members:');
console.log(db.staff.countDocuments());


// 27) Buscar Staff pelo SSN
function getStaffBySSN(ssn_new) {
  return db.staff.findOne({ ssn: ssn_new });
}

var ssn_new2 = 105899430;

console.log(`\n\nStaff with SSN ${ssn_new2}:`);
console.log(getStaffBySSN(ssn_new2));
