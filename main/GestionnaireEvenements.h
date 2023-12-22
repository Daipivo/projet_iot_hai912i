#ifndef GESTIONNAIREEVENEMENTS_H
#define GESTIONNAIREEVENEMENTS_H

#include "IEvenementObservateur.h"
#include <Arduino.h>
#include <map>
#include <vector>

class GestionnaireEvenements {
private:
    std::map<String, std::vector<IEvenementObservateur*>> observateurs;

public:
    void enregistrerObservateur(const String& typeEvenement, IEvenementObservateur* observateur) {
        observateurs[typeEvenement].push_back(observateur);
    }

    void notifierObservateurs(const String& typeEvenement, bool estEnDessousSeuil) {
        auto iter = observateurs.find(typeEvenement);
        if (iter != observateurs.end()) {
            for (IEvenementObservateur* observateur : iter->second) {
                observateur->onEvenement(typeEvenement, estEnDessousSeuil);
            }
        }
    }
};

#endif // GESTIONNAIREEVENEMENTS_H
