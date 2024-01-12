#include "MemoryManager.h"

void MemoryManager::updateMemoryUsage() {
    // Mise à jour de l'utilisation de la heap
    uint32_t totalHeap = ESP.getHeapSize();
    uint32_t freeHeap = ESP.getFreeHeap();
    uint32_t usedHeap = totalHeap - freeHeap;
    heapUsagePercentage = ((float)usedHeap / totalHeap) * 100;

    // Mise à jour de l'utilisation de la mémoire flash
    const uint32_t totalFlashMemory = ESP.getFlashChipSize();
    const uint32_t usedFlashMemory = ESP.getSketchSize();
    flashMemoryUsagePercentage = ((float)usedFlashMemory / totalFlashMemory) * 100;
}
