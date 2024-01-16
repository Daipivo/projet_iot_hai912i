#ifndef MEMORY_MANAGER_H
#define MEMORY_MANAGER_H

#include <Arduino.h>

// Init class
class MemoryManager {

// Public methods
public:
    MemoryManager() {}
    void updateMemoryUsage();
    float getHeapUsagePercentage() const { return heapUsagePercentage; }
    float getFlashMemoryUsage() const { return flashMemoryUsagePercentage; }

// Private attributes
private:
    float heapUsagePercentage = 0.0;
    float flashMemoryUsagePercentage = 0.0; 
};

#endif // MEMORY_MANAGER_H
