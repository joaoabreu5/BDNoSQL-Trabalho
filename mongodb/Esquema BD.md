# Base de dados 'hospital' - MongoDB

## Esquema de cada coleção

```python
from datetime import date, datetime
from bson import ObjectId

# Coleção 'patients'
patients = [
  {
    '_id': ObjectId, # Unique Index
    'id_patient': int, # Unique Index
    'patient_fname': str,
    'patient_lname': str,
    'blood_type': str,
    'phone': str,
    'email': str,
    'gender': str,
    'birthday': date,
    'insurance': {
      '_id': ObjectId,
      'policy_number': str,
      'provider': str,
      'insurance_plan': str,
      'co_pay': float,
      'coverage': str,
      'maternity': bool,
      'dental': bool,
      'optical': bool
    },
    'medical_history': [
      {
        '_id': ObjectId,
        'record_id': int, # Unique and Sparse Index
        'condition': str,
        'record_date': date
      }
    ],
    'emergency_contacts': [
      {
        '_id': ObjectId,
        'contact_name': str,
        'phone': str, # Unique and Sparse Index ('_id', 'phone')
        'relation': str
      }
    ]
  }
]


# Coleção 'staff'
staff = [
  {
    '_id': ObjectId, # Unique Index
    'emp_id': int,  # Unique Index
    'emp_fname': str,
    'emp_lname': str,
    'date_joining': date,
    'date_seperation': date,
    'email': str,
    'address': str,
    'ssn': int,
    'is_active_status': bool,
    'department': {
      '_id': ObjectId,
      'id_department': int,
      'dept_head': str,
      'dept_name': str
    },
    'role': 'DOCTOR' or 'NURSE' or 'TECHNICIAN',
    'qualifications': str   # Campo só existe quando role='doctor'
  }
]


# Coleção 'episodes'
episodes = [
  {
    '_id': ObjectId, # Unique Index
    'id_episode': int,  # Unique Index
    'id_patient': ObjectId,  # $lookup: { from: 'patients', foreignField: '_id' }
    'appointment': {
      '_id': ObjectId,
      'scheduled_on' : date,
      'appointment_date' : date,
      'appointment_time' : str,
      'id_doctor' : ObjectId   # $lookup: { from: 'staff', foreignField: '_id' }
    },
    'hospitalization': {
      '_id': ObjectId,
      'admission_date': date,
      'discharge_date': date,
      'responsible_nurse': ObjectId,   # $lookup: { from: 'staff', foreignField: '_id' }
      'room': {
        '_id': ObjectId,
        'id_room': int,
        'room_type': str,
        'room_cost': float
      }
    },
    'prescriptions': [
      {
        '_id': ObjectId,
        'id_prescription': int,  # Unique and Sparse Index
        'prescription_date': date,
        'dosage': int,
        'medicine': {
          '_id': ObjectId,
          'id_medicine': int,
          'm_name': str,
          'm_quantity': int,
          'm_cost': float
        }
      }
    ],
    'bills': [
      {
        '_id': ObjectId,
        'id_bill': int,  # Unique and Sparse Index
        'room_cost': float,
        'test_cost': float, 
        'other_charges': float,
        'total': float,
        'registered_at': datetime,
        'payment_status': 'PROCESSED' or 'PENDING' or 'FAILURE'
      }
    ],
    'lab_screenings': [
      {
        '_id': ObjectId,
        'lab_id': int,  # Unique and Sparse Index
        'test_cost': float,
        'test_date': date,
        'id_technician': ObjectId  # $lookup: { from: 'staff', foreignField: '_id' }
      }
    ]
  }
]
```
