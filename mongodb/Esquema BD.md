# Base de dados 'hospital' - MongoDB

## Esquema de cada coleção

```python
from datetime import date, datetime
from bson import ObjectId

# Coleção 'patients'
patients = [
  {
    '_id': ObjectId, # Unique Index
    'id_patient': int, # Unique Index (descending order)
    'patient_fname': str,
    'patient_lname': str,
    'blood_type': str,
    'phone': str,
    'email': str,
    'gender': str,
    'birthday': date,
    'insurance': {
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
        'record_id': int, # Unique and Sparse Index (descending order)
        'condition': str,
        'record_date': date
      }
    ],
    'emergency_contacts': [
      {
        'contact_name': str,
        'phone': str, # Unique and Sparse Compound Index [('_id', descending order), 'phone']
        'relation': str
      }
    ]
  }
]


# Coleção 'staff'
staff = [
  {
    '_id': ObjectId, # Unique Index
    'emp_id': int,  # Unique Index (descending order)
    'emp_fname': str,
    'emp_lname': str,
    'date_joining': date,
    'date_seperation': date,
    'email': str,
    'address': str,
    'ssn': int,
    'is_active_status': bool,
    'department': {
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
    'id_episode': int,  # Unique Index (descending order)
    'id_patient': ObjectId,  # $lookup: { from: 'patients', foreignField: '_id' }
    'appointment': {
      'scheduled_on' : date,
      'appointment_date' : date,
      'appointment_time' : str,
      'id_doctor' : ObjectId   # $lookup: { from: 'staff', foreignField: '_id' }
    },
    'hospitalization': {
      'admission_date': date,
      'discharge_date': date,
      'responsible_nurse': ObjectId,   # $lookup: { from: 'staff', foreignField: '_id' }
      'room': {
        'id_room': int,
        'room_type': str,
        'room_cost': float
      }
    },
    'prescriptions': [
      {
        'id_prescription': int,  # Unique and Sparse Index (descending order)
        'prescription_date': date,
        'dosage': int,
        'medicine': {
          'id_medicine': int,
          'm_name': str,
          'm_quantity': int,
          'm_cost': float
        }
      }
    ],
    'bills': [
      {
        'id_bill': int,  # Unique and Sparse Index (descending order)
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
        'lab_id': int,  # Unique and Sparse Index (descending order)
        'test_cost': float,
        'test_date': date,
        'id_technician': ObjectId  # $lookup: { from: 'staff', foreignField: '_id' }
      }
    ]
  }
]


# Coleção 'counters'
counters = [
  {
    '_id': ObjectId,
    'field': str, # Unique Compound Index ['field', 'col']
    'col': str,
    'seq': int
  }
]
```
