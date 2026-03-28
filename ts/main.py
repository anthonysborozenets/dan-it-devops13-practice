from flask import Flask, request, jsonify
import csv
import os

app = Flask(__name__)

FILE_NAME = 'students.csv'
FIELDS = ['id', 'first_name', 'last_name', 'age']


# --- Допоміжні функції ---

def read_students():
    if not os.path.exists(FILE_NAME):
        return []

    with open(FILE_NAME, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        return list(reader)


def write_students(students):
    with open(FILE_NAME, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(students)


def generate_id(students):
    if not students:
        return 1
    return max(int(s['id']) for s in students) + 1


def validate_fields(data, required_fields, allow_partial=False):
    if not data:
        return "Empty body"

    for key in data.keys():
        if key not in required_fields:
            return f"Invalid field: {key}"

    if not allow_partial:
        for field in required_fields:
            if field not in data:
                return f"Missing field: {field}"

    return None


# --- GET ---

@app.route('/students', methods=['GET'])
def get_students():
    students = read_students()

    student_id = request.args.get('id')
    last_name = request.args.get('last_name')

    if student_id:
        for s in students:
            if s['id'] == student_id:
                return jsonify(s)
        return jsonify({'error': 'Student not found'}), 404

    if last_name:
        result = [s for s in students if s['last_name'] == last_name]
        if not result:
            return jsonify({'error': 'Student not found'}), 404
        return jsonify(result)

    return jsonify(students)


# --- POST ---

@app.route('/students', methods=['POST'])
def create_student():
    data = request.get_json()

    error = validate_fields(data, ['first_name', 'last_name', 'age'])
    if error:
        return jsonify({'error': error}), 400

    students = read_students()
    new_id = generate_id(students)

    new_student = {
        'id': str(new_id),
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'age': str(data['age'])
    }

    students.append(new_student)
    write_students(students)

    return jsonify(new_student), 201


# --- PUT ---

@app.route('/students/<id>', methods=['PUT'])
def update_student(id):
    data = request.get_json()

    error = validate_fields(data, ['first_name', 'last_name', 'age'])
    if error:
        return jsonify({'error': error}), 400

    students = read_students()

    for s in students:
        if s['id'] == id:
            s['first_name'] = data['first_name']
            s['last_name'] = data['last_name']
            s['age'] = str(data['age'])

            write_students(students)
            return jsonify(s)

    return jsonify({'error': 'Student not found'}), 404


# --- PATCH ---

@app.route('/students/<id>', methods=['PATCH'])
def patch_student(id):
    data = request.get_json()

    error = validate_fields(data, ['age'], allow_partial=True)
    if error:
        return jsonify({'error': error}), 400

    if 'age' not in data:
        return jsonify({'error': 'Missing field: age'}), 400

    students = read_students()

    for s in students:
        if s['id'] == id:
            s['age'] = str(data['age'])

            write_students(students)
            return jsonify(s)

    return jsonify({'error': 'Student not found'}), 404


# --- DELETE ---

@app.route('/students/<id>', methods=['DELETE'])
def delete_student(id):
    students = read_students()

    for s in students:
        if s['id'] == id:
            students.remove(s)
            write_students(students)
            return jsonify({'message': 'Student deleted successfully'})

    return jsonify({'error': 'Student not found'}), 404


# --- Запуск ---

if __name__ == '__main__':
    app.run(debug=True)