#ifndef MEMORY_MANAGER_H
#define MEMORY_MANAGER_H

#include <Arduino.h>

class MemoryManager {
public:
    MemoryManager() {}
    void updateMemoryUsage();
    float getHeapUsagePercentage() const { return heapUsagePercentage; }
    float getFlashMemoryUsage() const { return flashMemoryUsagePercentage; }

private:
    float heapUsagePercentage = 0.0;
    float flashMemoryUsagePercentage = 0.0; // Ajout de cette variable
};

#endif // MEMORY_MANAGER_H
