import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text("""
Dernière mise à jour : 9 septembre 2025

Bienvenue sur Coconut Agencement. Votre vie privée est importante pour nous.

1. Collecte des informations
Nous collectons des informations lorsque vous vous inscrivez sur notre application, prenez un rendez-vous, ou utilisez nos services. Les informations collectées incluent votre nom, votre adresse e-mail, votre numéro de téléphone.

2. Utilisation des informations
Toutes les informations que nous recueillons auprès de vous peuvent être utilisées pour :
- Personnaliser votre expérience et répondre à vos besoins individuels
- Fournir un contenu publicitaire personnalisé
- Améliorer notre application
- Améliorer le service client et vos besoins de prise en charge
- Vous contacter par e-mail
- Gérer un concours, une promotion, ou une enquête

3. Confidentialité
Nous sommes les seuls propriétaires des informations recueillies sur cette application. Vos informations personnelles ne seront pas vendues, échangées, transférées, ou données à une autre société sans votre consentement, en dehors de ce qui est nécessaire pour répondre à une demande et / ou une transaction, comme par exemple pour expédier une commande.

4. Divulgation à des tiers
Nous ne vendons, n'échangeons et ne transférons pas vos informations personnelles identifiables à des tiers.

5. Protection des informations
Nous mettons en œuvre une variété de mesures de sécurité pour préserver la sécurité de vos informations personnelles.

6. Consentement
En utilisant notre application, vous consentez à notre politique de confidentialité.
"""),
      ),
    );
  }
}
