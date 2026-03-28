import random

def guess_number():
    secret_number = random.randint(1, 100)
    attempts = 5

    print("Вгадайте число від 1 до 100. У вас є 5 спроб.")

    for i in range(attempts):
        try:
            user_input = int(input(f"Спроба {i+1}: Введіть число: "))
        except ValueError:
            print("Будь ласка, введіть ціле число.")
            continue

        if user_input == secret_number:
            print("Вітаємо! Ви вгадали правильне число.")
            return
        elif user_input > secret_number:
            print("Занадто високо")
        else:
            print("Занадто низько")

    print(f"Вибачте, у вас закінчилися спроби. Правильний номер був {secret_number}")

# запуск функції
guess_number()