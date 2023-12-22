#ifndef IEVENEMENTOBSERVATEUR_H
#define IEVENEMENTOBSERVATEUR_H

#include <Arduino.h>

class IEvenementObservateur {
public:
    virtual ~IEvenementObservateur() {}
    virtual void onEvenement(const String& typeEvenement, bool estEnDessousSeuil) = 0;
};

#endif // IEVENEMENTOBSERVATEUR_H
