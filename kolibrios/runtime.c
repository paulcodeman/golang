#include <stdint.h>
#include <stddef.h>

// Псевдоним для линковщика с точным именем
__attribute__((visibility("default"))) 

// Функция для сравнения двух блоков памяти по 4 байта (32 бита)
int memequal32(const void *block1, const void *block2, size_t size) {
    // Преобразуем указатели в тип uint32_t*
    const uint32_t *b1 = (const uint32_t *)block1;
    const uint32_t *b2 = (const uint32_t *)block2;

    // Проверяем, что размер блока кратен 4
    if (size % 4 != 0) {
        return 0;  // Невозможность сравнения
    }

    // Сравниваем блоки по 4 байта (32 бита)
    for (size_t i = 0; i < size / 4; ++i) {
        if (b1[i] != b2[i]) {
            return 0;  // Блоки разные
        }
    }

    // Если всё одинаково
    return 1;  // Блоки равны
}

// Местоположение ассемблерной метки
__asm__(".global runtime.memequal32..f");  // Указываем имя функции для линковщика
__asm__(".set runtime.memequal32..f, memequal32");