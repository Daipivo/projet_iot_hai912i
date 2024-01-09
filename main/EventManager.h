#ifndef EventManager_H
#define EventManager_H

#include "IEventObserver.h"
#include <Arduino.h>
#include <map>
#include <vector>

class EventManager {
private:
    std::map<String, std::vector<IEventObserver*>> observers;

public:
    void saveObserver(const String& typeEvenement, IEventObserver* observer) {
        observers[typeEvenement].push_back(observer);
    }

    void notifyObserver(const String& typeEvenement, bool estEnDessousSeuil) {
        auto iter = observers.find(typeEvenement);
        if (iter != observers.end()) {
            for (IEventObserver* observer : iter->second) {
                observer->onEvenement(typeEvenement, estEnDessousSeuil);
            }
        }
    }
};

#endif // EventManager_H
