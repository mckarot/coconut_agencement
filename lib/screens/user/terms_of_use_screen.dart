import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text("""
Dernière mise à jour : 9 septembre 2025

Veuillez lire attentivement ces conditions d'utilisation avant d'utiliser l'application Coconut Agencement.

1. Conditions
En accédant à l'application, vous acceptez d'être lié par les présentes conditions d'utilisation, toutes les lois et réglementations applicables, et convenez que vous êtes responsable du respect de toutes les lois locales applicables.

2. Licence d'utilisation
La permission est accordée de télécharger temporairement une copie du matériel (information ou logiciel) sur l'application Coconut Agencement pour une visualisation transitoire personnelle et non commerciale uniquement.

3. Clause de non-responsabilité
Le matériel sur l'application Coconut Agencement est fourni «tel quel». Coconut Agencement ne donne aucune garantie, expresse ou implicite, et décline et annule par la présente toutes les autres garanties.

4. Limitations
En aucun cas, Coconut Agencement ou ses fournisseurs ne seront responsables de tout dommage (y compris, sans limitation, les dommages pour perte de données ou de profit, ou en raison d'une interruption d'activité) découlant de l'utilisation ou de l'impossibilité d'utiliser le matériel sur l'application Coconut Agencement.

5. Modifications
Coconut Agencement peut réviser ces conditions d'utilisation pour son application à tout moment et sans préavis. En utilisant cette application, vous acceptez d'être lié par la version alors en vigueur de ces conditions d'utilisation.

6. Droit applicable
Toute réclamation relative à l'application Coconut Agencement sera régie par les lois de la France sans égard à ses dispositions relatives aux conflits de lois.
"""),
      ),
    );
  }
}
