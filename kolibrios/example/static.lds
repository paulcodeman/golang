SECTIONS
{
    . = 0x0; /* Устанавливаем начальный адрес для KolibriOS */
    .text :
    {
        /* Заголовок для KolibriOS */
        LONG(0x554e454D); /* Signature "MENU" */
        LONG(0x31305445); /* Signature "ET01" */
        LONG(1);          /* Версия */
        LONG(go_0example.Main); /* Точка входа программы */
        LONG(__end);      /* Конец образа */
        LONG(0x10000);    /* Размер стека */
        LONG(0x10000);    /* Размер стека */
        LONG(0);          /* Зарезервировано */
        LONG(0);          /* Зарезервировано */
        *(.text)
    }
    .rodata :
    {
        *(.rodata)
        *(.rodata.*)
    }
    .data :
    {
        *(.data)
    }
    .bss :
    {
        *(COMMON)
        *(.bss)
    }
    .eh_frame :
    {
        *(.eh_frame)
    }
    .group :
    {
        *(.group)
    }
    __end = .; /* Определяем конец образа */
}
