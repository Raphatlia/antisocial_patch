#import <Foundation/Foundation.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#include "IL2CPP_Resolver.hpp"

// Нужно определить BINARY_NAME — смотри Config.h в Resolver
#define BINARY_NAME "UnityFramework"

// Время ожидания загрузки модуля (в секундах)
#define WAIT_TIME_SEC 30

// Имена классов-кандидатов (перебираем все варианты)
static const char* CLASS_NAMES[] = {
    "BunnyHopController",
    "BunnyHop",
    "Aimbot",
    "AimbotController",
    "Cheat",
    "CheatMenu",
    "Menu",
    "MainMenu",
    "UIManager",
    "Panel",
    NULL
};

// Имена методов-кандидатов для показа меню
static const char* METHOD_NAMES[] = {
    "ShowMenu",
    "Show",
    "Open",
    "Init",
    "Awake",
    "Start",
    "OnGUI",
    "Update",
    NULL
};

// Функция инициализации
__attribute__((constructor))
static void initPatch(void) {
    NSLog(@"[antisocial_patch] Initializing IL2CPP Resolver...");
    
    // Инициализация Resolver — ждём загрузки UnityFramework
    IL2CPP::Initialize(true, WAIT_TIME_SEC, IL2CPP_FRAMEWORK(BINARY_NAME));
    
    if (!IL2CPP::Initialize) {
        NSLog(@"[antisocial_patch] Resolver init returned void/unknown");
    }
    
    NSLog(@"[antisocial_patch] IL2CPP initialized, searching for classes...");
    
    // Перебираем классы
    for (int i = 0; CLASS_NAMES[i] != NULL; i++) {
        void* pClass = IL2CPP::Class::Find(CLASS_NAMES[i]);
        
        if (pClass == NULL) {
            NSLog(@"[antisocial_patch] Class not found: %s", CLASS_NAMES[i]);
            continue;
        }
        
        NSLog(@"[antisocial_patch] Found class: %s", CLASS_NAMES[i]);
        
        // Перебираем методы
        for (int j = 0; METHOD_NAMES[j] != NULL; j++) {
            void* pMethod = IL2CPP::Class::Utils::GetMethodPointer(pClass, METHOD_NAMES[j]);
            
            if (pMethod == NULL) {
                continue;
            }
            
            NSLog(@"[antisocial_patch] Found method: %s::%s @ %p", 
                  CLASS_NAMES[i], METHOD_NAMES[j], pMethod);
            
            // Пробуем вызвать метод
            // Для IL2CPP-методов нужен объект экземпляра, но если метод статический — вызываем напрямую
            typedef void (*FuncPtr)(void*);
            FuncPtr func = (FuncPtr)pMethod;
            
            // Вызываем с NULL (если метод статический)
            // Если метод не статический — упадёт, но мы попробуем
            @try {
                func(NULL);
                NSLog(@"[antisocial_patch] Called %s::%s(NULL)", CLASS_NAMES[i], METHOD_NAMES[j]);
            } @catch (NSException *e) {
                NSLog(@"[antisocial_patch] Exception calling %s::%s: %@", 
                      CLASS_NAMES[i], METHOD_NAMES[j], e);
            }
            
            // После первого успешного вызова можно выйти
            // return;
        }
    }
    
    NSLog(@"[antisocial_patch] Search complete.");
}
