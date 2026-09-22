#import <Foundation/Foundation.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// Новый адрес функции проверки токена (из Ghidra, StandLeo 3.5)
#define TOKEN_CHECK_OFFSET 0x204a54

// Оригинальная функция
static BOOL (*orig_tokenCheck)(void);

// Наша подмена — всегда возвращает YES (успех)
static BOOL hooked_tokenCheck(void) {
    NSLog(@"[antisocial_patch] Token check bypassed!");
    return YES;
}

// Функция инициализации — находит базовый адрес бинарника и ставит хук
__attribute__((constructor))
static void initPatch(void) {
    NSLog(@"[antisocial_patch] Initializing...");
    
    // Получаем базовый адрес главного бинарника (STANDLEO)
    const char *mainImage = _dyld_get_image_name(0);
    intptr_t baseAddr = _dyld_get_image_vmaddr_slide(0);
    
    NSLog(@"[antisocial_patch] Main image: %s, slide: 0x%lx", mainImage, baseAddr);
    
    // Вычисляем реальный адрес функции проверки токена
    void *targetAddr = (void *)(baseAddr + TOKEN_CHECK_OFFSET);
    
    NSLog(@"[antisocial_patch] Target address: %p", targetAddr);
    
    // Ставим хук
    MSHookFunction(targetAddr, (void *)hooked_tokenCheck, (void **)&orig_tokenCheck);
    
    NSLog(@"[antisocial_patch] Hook installed!");
}
