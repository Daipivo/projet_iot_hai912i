#include "MemoryManager.h"

// Update memory usage
void MemoryManager::updateMemoryUsage() {

    // Heap usage
    uint32_t totalHeap = ESP.getHeapSize();
    uint32_t freeHeap = ESP.getFreeHeap();
    uint32_t usedHeap = totalHeap - freeHeap;
    heapUsagePercentage = ((float)usedHeap / totalHeap) * 100;

    // Flash memory usage
    const uint32_t totalFlashMemory = ESP.getFlashChipSize();
    const uint32_t usedFlashMemory = ESP.getSketchSize();
    flashMemoryUsagePercentage = ((float)usedFlashMemory / totalFlashMemory) * 100;
}
