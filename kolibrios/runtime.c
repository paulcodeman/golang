#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <string.h>
// #include <stdlib.h> не надо добавлять!

extern void* malloc(size_t size);

// Псевдоним для линковщика с точным именем
__attribute__((visibility("default"))) 

// Функция для сравнения блоков памяти по 4 байта
bool memequal32(const unsigned char* block1, const unsigned char* block2, size_t size) {
    if (size % 4 != 0 || block1 == NULL || block2 == NULL) {
        return false;
    }

    const uint32_t* p1 = (const uint32_t*)block1;
    const uint32_t* p2 = (const uint32_t*)block2;
    size_t words = size / 4;

    for (size_t i = 0; i < words; i++) {
        if (p1[i] != p2[i]) {
            return false;
        }
    }

    return true;
}

// Функция для сравнения блоков памяти по 1 байту
bool memequal8(const unsigned char* block1, const unsigned char* block2, size_t size) {
    if (block1 == NULL || block2 == NULL) {
        return false;  // Проверка на NULL
    }

    // Сравниваем блоки по 1 байту
    for (size_t i = 0; i < size; i++) {
        if (block1[i] != block2[i]) {
            return false;
        }
    }

    return true;  // Если всё одинаково
}

// Функция для объединения среза строк в одну строку
char* concatstrings(const char** strs, size_t count) {
    if (strs == NULL || count == 0) {
        return NULL;  // Проверка на NULL или пустой входной массив
    }

    size_t total_length = 0;

    // Сначала вычисляем общую длину всех строк
    for (size_t i = 0; i < count; i++) {
        if (strs[i] == NULL) {
            continue;  // Пропускаем NULL-строки
        }
        total_length += strlen(strs[i]);
    }

    char* result = (char*)malloc(total_length + 1);  // +1 для завершающего нулевого символа
    if (!result) {
        return NULL;  // Ошибка выделения памяти
    }

    size_t pos = 0;
    for (size_t i = 0; i < count; i++) {
        if (strs[i] != NULL) {
            strcpy(result + pos, strs[i]);
            pos += strlen(strs[i]);
        }
    }

    result[total_length] = '\0';  // Завершающий нулевой символ
    return result;
}

// Функция для установки байтовой строки
void SetByteString(unsigned char* dest, const unsigned char* src, size_t size) {
    if (dest == NULL || src == NULL) {
        return;  // Проверка на NULL
    }
    memcpy(dest, src, size);  // Копируем содержимое строки
}

// Барьер записи для поддержания корректности работы сборщика мусора
void writeBarrier(void** slot, void* ptr) {
    if (slot == NULL) {
        return;  // Проверка на NULL
    }
    *slot = ptr;  // Обновляем значение указателя
    // В реальном Go runtime здесь бы был вызов к сборщику мусора
}

// Симуляция барьера записи для сборщика мусора
void gcWriteBarrier(void** slot, void* ptr) {
    if (slot == NULL) {
        return;  // Проверка на NULL
    }
    // Вставить логику барьера записи для GC, если необходимо
    *slot = ptr;  // Обновляем значение указателя
}

// Функция для сравнения строк
bool strequal(const char* str1, const char* str2) {
    if (str1 == NULL || str2 == NULL) {
        return false;  // Проверка на NULL
    }
    return strcmp(str1, str2) == 0;  // Сравнение строк
}

// Реализация функции strcpy
char* strcpy(char *dest, const char *src) {
    char *dest_start = dest;
    while (*src) {
        *dest++ = *src++;
    }
    *dest = '\0';
    return dest_start;  // Возвращаем указатель на начало строки
}

// Реализация функции strlen
size_t strlen(const char *str) {
    const char *s = str;
    while (*s) {
        s++;
    }
    return s - str;  // Возвращаем разницу указателей
}

int strcmp(const char *str1, const char *str2) {
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return *(unsigned char *)str1 - *(unsigned char *)str2;
}

void *memcpy(void *dest, const void *src, size_t n) {
    char *d = (char *)dest;
    const char *s = (const char *)src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

int memcmp(const void *s1, const void *s2, size_t n) {
    const unsigned char *p1 = (const unsigned char *)s1;
    const unsigned char *p2 = (const unsigned char *)s2;
    while (n--) {
        if (*p1 != *p2) {
            return *p1 - *p2;
        }
        p1++;
        p2++;
    }
    return 0;
}

// Небезопасное получение адреса переменной
void* __unsafe_get_addr(void* base, size_t offset) {
    if (base == NULL) {
        return NULL;  // Проверка на NULL
    }

    // Получаем адрес с учетом смещения
    return (void*)((unsigned char*)base + offset);
}

// Местоположение ассемблерной метки
__asm__(".global runtime.memequal32..f");
__asm__(".set runtime.memequal32..f, memequal32");

__asm__(".global runtime.memequal8..f");
__asm__(".set runtime.memequal8..f, memequal8");

__asm__(".global runtime.memequal");
__asm__(".set runtime.memequal, memequal8");

__asm__(".global runtime.concatstrings");
__asm__(".set runtime.concatstrings, concatstrings");

__asm__(".global runtime.SetByteString");
__asm__(".set runtime.SetByteString, SetByteString");

__asm__(".global runtime.writeBarrier");
__asm__(".set runtime.writeBarrier, writeBarrier");

__asm__(".global runtime.gcWriteBarrier");
__asm__(".set runtime.gcWriteBarrier, gcWriteBarrier");

__asm__(".global runtime.strequal..f");
__asm__(".set runtime.strequal..f, strequal");