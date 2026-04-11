"""
REST API для керування студентами (Flask).
Дані зберігаються у CSV: id, first_name, last_name, age, nationaly, job_role.
"""
from __future__ import annotations

import csv
from pathlib import Path

from flask import Flask, jsonify, request

BASE_DIR = Path(__file__).resolve().parent
CSV_FILE = BASE_DIR / "students.csv"

# Дозволені поля для POST і PUT
POST_PUT_FIELDS = frozenset({"first_name", "last_name", "age"})
# Дозволене поле для PATCH
PATCH_FIELDS = frozenset({"age"})

# Усі колонки у CSV-файлі
CSV_FIELDNAMES = ["id", "first_name", "last_name", "age", "nationaly", "job_role"]

app = Flask(__name__)


# ──────────────────────────────────────────────
# Допоміжні функції
# ──────────────────────────────────────────────

def _ensure_csv() -> None:
    """Якщо students.csv ще немає — створити файл із заголовком."""
    if not CSV_FILE.exists():
        with CSV_FILE.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=CSV_FIELDNAMES)
            writer.writeheader()


def _read_students() -> list[dict]:
    """Прочитати всіх студентів із CSV."""
    _ensure_csv()
    with CSV_FILE.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    out: list[dict] = []
    for row in rows:
        if not row.get("id"):
            continue
        out.append({
            "id": int(row["id"]),
            "first_name": row.get("first_name", ""),
            "last_name": row.get("last_name", ""),
            "age": int(row["age"]) if row.get("age") else 0,
            "nationaly": row.get("nationaly", ""),
            "job_role": row.get("job_role", ""),
        })
    return out


def _write_students(students: list[dict]) -> None:
    """Повністю перезаписати CSV."""
    with CSV_FILE.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=CSV_FIELDNAMES)
        writer.writeheader()
        for s in students:
            writer.writerow({
                "id": s["id"],
                "first_name": s["first_name"],
                "last_name": s["last_name"],
                "age": s["age"],
                "nationaly": s.get("nationaly", ""),
                "job_role": s.get("job_role", ""),
            })


def _next_id(students: list[dict]) -> int:
    """Наступний id = max(id) + 1, або 1 якщо список порожній."""
    if not students:
        return 1
    return max(s["id"] for s in students) + 1


def _parse_json_body() -> dict | None:
    """Повернути тіло запиту як dict або None."""
    if not request.data and not request.is_json:
        return None
    try:
        data = request.get_json(force=False, silent=True)
    except Exception:
        return None
    return data if isinstance(data, dict) else None


def _validate_exact_keys(
    body: dict | None, allowed: frozenset[str]
) -> tuple[dict | None, str | None]:
    """Перевірити, що ключі body збігаються точно з allowed."""
    if body is None:
        return None, "Тіло запиту порожнє або некоректне JSON."
    if len(body) == 0:
        return None, "Не передано жодного поля."
    keys = frozenset(body.keys())
    if keys != allowed:
        unknown = keys - allowed
        missing = allowed - keys
        parts = []
        if unknown:
            parts.append(f"недопустимі поля: {', '.join(sorted(unknown))}")
        if missing:
            parts.append(f"відсутні обов'язкові поля: {', '.join(sorted(missing))}")
        return None, "; ".join(parts) + "."
    return body, None


def _coerce_age(value) -> tuple[int | None, str | None]:
    """Перетворити value на int для поля age."""
    if isinstance(value, bool) or value is None:
        return None, "Поле 'age' має бути числом."
    if isinstance(value, int):
        return value, None
    if isinstance(value, str) and value.strip().isdigit():
        return int(value.strip()), None
    try:
        return int(value), None
    except (TypeError, ValueError):
        return None, "Поле 'age' має бути числом."


# ──────────────────────────────────────────────
# Маршрути
# ──────────────────────────────────────────────

@app.route("/students", methods=["GET"])
def list_or_search_students():
    """GET /students або GET /students?last_name=..."""
    last_name = request.args.get("last_name")
    students = _read_students()

    if last_name is not None:
        last_name = last_name.strip()
        matches = [s for s in students if s["last_name"] == last_name]
        if not matches:
            return jsonify({"error": f"Студента з прізвищем '{last_name}' не знайдено."}), 404
        return jsonify(matches), 200

    return jsonify(students), 200


@app.route("/students/<int:student_id>", methods=["GET"])
def get_student(student_id: int):
    """GET /students/<id>"""
    students = _read_students()
    for s in students:
        if s["id"] == student_id:
            return jsonify(s), 200
    return jsonify({"error": f"Студента з ID {student_id} не знайдено."}), 404


@app.route("/students/nat/<nat>", methods=["GET"])
def get_students_by_nat(nat: str):
    """GET /students/nat/<nationality>"""
    students = _read_students()
    results = [s for s in students if s.get("nationaly") == nat]
    if not results:
        return jsonify({"error": f"Студентів з національністю '{nat}' не знайдено."}), 404
    return jsonify(results), 200


@app.route("/students/name/<name>", methods=["GET"])
def get_student_name(name: str):
    """GET /students/name/<first_name>"""
    students = _read_students()
    for s in students:
        if s["first_name"] == name:
            return jsonify(s), 200
    return jsonify({"error": f"Студента з ім'ям '{name}' не знайдено."}), 404


@app.route("/students", methods=["POST"])
def create_student():
    """POST /students — створити студента; тіло: first_name, last_name, age."""
    body, err = _validate_exact_keys(_parse_json_body(), POST_PUT_FIELDS)
    if err:
        return jsonify({"error": err}), 400

    age, age_err = _coerce_age(body["age"])
    if age_err:
        return jsonify({"error": age_err}), 400

    first_name = body["first_name"]
    last_name = body["last_name"]
    if not isinstance(first_name, str) or not isinstance(last_name, str):
        return jsonify({"error": "Ім'я та прізвище мають бути рядками."}), 400

    students = _read_students()
    new_id = _next_id(students)
    new_student = {
        "id": new_id,
        "first_name": first_name.strip(),
        "last_name": last_name.strip(),
        "age": age,
        "nationaly": "",
        "job_role": "",
    }
    students.append(new_student)
    _write_students(students)
    return jsonify({
        "id": new_student["id"],
        "first_name": new_student["first_name"],
        "last_name": new_student["last_name"],
        "age": new_student["age"],
    }), 201


@app.route("/students/<int:student_id>", methods=["PUT"])
def replace_student(student_id: int):
    """PUT /students/<id> — замінити ім'я, прізвище, вік."""
    body, err = _validate_exact_keys(_parse_json_body(), POST_PUT_FIELDS)
    if err:
        return jsonify({"error": err}), 400

    age, age_err = _coerce_age(body["age"])
    if age_err:
        return jsonify({"error": age_err}), 400

    first_name = body["first_name"]
    last_name = body["last_name"]
    if not isinstance(first_name, str) or not isinstance(last_name, str):
        return jsonify({"error": "Ім'я та прізвище мають бути рядками."}), 400

    students = _read_students()
    for i, s in enumerate(students):
        if s["id"] == student_id:
            updated = {**s, "first_name": first_name.strip(), "last_name": last_name.strip(), "age": age}
            students[i] = updated
            _write_students(students)
            return jsonify({
                "id": updated["id"],
                "first_name": updated["first_name"],
                "last_name": updated["last_name"],
                "age": updated["age"],
            }), 200
    return jsonify({"error": f"Студента з ID {student_id} не знайдено."}), 404


@app.route("/students/<int:student_id>", methods=["PATCH"])
def patch_student_age(student_id: int):
    """PATCH /students/<id> — змінити лише вік."""
    body, err = _validate_exact_keys(_parse_json_body(), PATCH_FIELDS)
    if err:
        return jsonify({"error": err}), 400

    age, age_err = _coerce_age(body["age"])
    if age_err:
        return jsonify({"error": age_err}), 400

    students = _read_students()
    for i, s in enumerate(students):
        if s["id"] == student_id:
            s = {**s, "age": age}
            students[i] = s
            _write_students(students)
            return jsonify({
                "id": s["id"],
                "first_name": s["first_name"],
                "last_name": s["last_name"],
                "age": s["age"],
            }), 200
    return jsonify({"error": f"Студента з ID {student_id} не знайдено."}), 404


@app.route("/students/<int:student_id>", methods=["DELETE"])
def delete_student(student_id: int):
    """DELETE /students/<id>"""
    students = _read_students()
    new_list = [s for s in students if s["id"] != student_id]
    if len(new_list) == len(students):
        return jsonify({"error": f"Студента з ID {student_id} не знайдено."}), 404
    _write_students(new_list)
    return jsonify({"message": f"Студента з ID {student_id} успішно видалено."}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
