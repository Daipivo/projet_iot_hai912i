#ifndef IEventObserver_H
#define IEventObserver_H

#include <Arduino.h>

class IEventObserver {
public:
    virtual ~IEventObserver() {}
    virtual void onEvenement(const String& typeEvenement, bool estEnDessousSeuil) = 0;
};

#endif // IEventObserver_H
