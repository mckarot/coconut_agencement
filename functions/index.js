const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();

// Configuration de SendGrid - à définir avec firebase functions:config:set
const SENDGRID_API_KEY = functions.config().sendgrid?.key;
if (SENDGRID_API_KEY) {
  sgMail.setApiKey(SENDGRID_API_KEY);
}

// Fonction pour envoyer un email de demande de rendez-vous à l'artisan
exports.sendAppointmentRequestEmail = functions.https.onCall(async (data, context) => {
  // Vérifier que l'utilisateur est authentifié
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'The function must be called while authenticated.'
    );
  }

  try {
    const { 
      artisanEmail, 
      clientName, 
      appointmentDate, 
      serviceName,
      clientEmail,
      artisanName
    } = data;

    // Validation des données
    if (!artisanEmail || !clientName || !appointmentDate || !serviceName) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required parameters'
      );
    }

    // Formatage de la date
    const formattedDate = new Date(appointmentDate).toLocaleDateString('fr-FR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });

    const msg = {
      to: artisanEmail,
      from: 'romain.cuisine.972@gmail.com', // Email vérifié SendGrid
      replyTo: clientEmail || 'romain.cuisine.972@gmail.com',
      subject: `Nouvelle demande de rendez-vous - ${clientName}`,
      text: `
        Bonjour ${artisanName || 'Artisan'},
        
        ${clientName} a demandé un rendez-vous pour le service "${serviceName}".
        
        Détails du rendez-vous :
        - Date et heure : ${formattedDate}
        - Service : ${serviceName}
        
        Veuillez vous connecter à votre application Coconut Agencement pour confirmer ou refuser cette demande.
        
        Cordialement,
        L'équipe Coconut Agencement
      `,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #6F3322;">Nouvelle demande de rendez-vous</h2>
          
          <p>Bonjour ${artisanName || 'Artisan'},</p>
          
          <p><strong>${clientName}</strong> a demandé un rendez-vous pour le service <strong>"${serviceName}"</strong>.</p>
          
          <div style="background-color: #f5f5f5; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <h3 style="margin-top: 0; color: #6F3322;">Détails du rendez-vous</h3>
            <p><strong>Date et heure :</strong> ${formattedDate}</p>
            <p><strong>Service :</strong> ${serviceName}</p>
          </div>
          
          <p>Veuillez vous connecter à votre application <strong>Coconut Agencement</strong> pour confirmer ou refuser cette demande.</p>
          
          <hr style="margin: 30px 0;">
          
          <p style="font-size: 14px; color: #666;">
            Cordialement,<br/>
            <strong>L'équipe Coconut Agencement</strong>
          </p>
        </div>
      `,
    };

    // Envoyer l'email seulement si SendGrid est configuré
    if (SENDGRID_API_KEY) {
      await sgMail.send(msg);
      console.log('Email envoyé avec succès à:', artisanEmail);
      return { success: true, message: 'Email envoyé avec succès' };
    } else {
      console.log('SendGrid non configuré - email simulé');
      // En développement, on simule l'envoi
      return { success: true, message: 'Email simulé (SendGrid non configuré)' };
    }
  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Erreur lors de l\'envoi de l\'email: ' + error.message
    );
  }
});

// Fonction pour envoyer un email de confirmation/refus au client
exports.sendAppointmentStatusEmail = functions.https.onCall(async (data, context) => {
  // Vérifier que l'utilisateur est authentifié
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'The function must be called while authenticated.'
    );
  }

  try {
    const { 
      clientEmail, 
      artisanName, 
      appointmentDate, 
      serviceName, 
      isConfirmed,
      clientName
    } = data;

    // Validation des données
    if (!clientEmail || !artisanName || !appointmentDate || !serviceName === undefined) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required parameters'
      );
    }

    // Formatage de la date
    const formattedDate = new Date(appointmentDate).toLocaleDateString('fr-FR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });

    const statusText = isConfirmed ? 'confirmé' : 'refusé';
    const statusColor = isConfirmed ? '#4CAF50' : '#F44336';
    const statusMessage = isConfirmed 
      ? 'Nous vous attendons avec impatience.' 
      : 'Nous nous excusons pour ce désagrément et restons à votre disposition pour programmer un nouveau rendez-vous.';

    const msg = {
      to: clientEmail,
      from: 'romain.cuisine.972@gmail.com', // Email vérifié SendGrid
      replyTo: 'romain.cuisine.972@gmail.com', // Email de contact
      subject: `Rendez-vous ${statusText} - Coconut Agencement`,
      text: `
        Bonjour ${clientName || 'Client'},
        
        Votre rendez-vous avec ${artisanName} pour le service "${serviceName}" a été ${statusText}.
        
        Détails du rendez-vous :
        - Date et heure : ${formattedDate}
        - Service : ${serviceName}
        - Statut : ${statusText.charAt(0).toUpperCase() + statusText.slice(1)}
        
        ${statusMessage}
        
        Cordialement,
        L'équipe Coconut Agencement
      `,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #6F3322;">Rendez-vous ${statusText}</h2>
          
          <p>Bonjour ${clientName || 'Client'},</p>
          
          <p>Votre rendez-vous avec <strong>${artisanName}</strong> pour le service <strong>"${serviceName}"</strong> a été 
             <span style="color: ${statusColor}; font-weight: bold;">${statusText}</span>.</p>
          
          <div style="background-color: #f5f5f5; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <h3 style="margin-top: 0; color: #6F3322;">Détails du rendez-vous</h3>
            <p><strong>Date et heure :</strong> ${formattedDate}</p>
            <p><strong>Service :</strong> ${serviceName}</p>
            <p><strong>Statut :</strong> <span style="color: ${statusColor}; font-weight: bold;">
                ${statusText.charAt(0).toUpperCase() + statusText.slice(1)}
              </span></p>
          </div>
          
          <p>${statusMessage}</p>
          
          <hr style="margin: 30px 0;">
          
          <p style="font-size: 14px; color: #666;">
            Cordialement,<br/>
            <strong>L'équipe Coconut Agencement</strong>
          </p>
        </div>
      `,
    };

    // Envoyer l'email seulement si SendGrid est configuré
    if (SENDGRID_API_KEY) {
      await sgMail.send(msg);
      console.log('Email de statut envoyé avec succès à:', clientEmail);
      return { success: true, message: 'Email de statut envoyé avec succès' };
    } else {
      console.log('SendGrid non configuré - email de statut simulé');
      // En développement, on simule l'envoi
      return { success: true, message: 'Email de statut simulé (SendGrid non configuré)' };
    }
  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email de statut:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Erreur lors de l\'envoi de l\'email de statut: ' + error.message
    );
  }
});

// Fonction pour tester l'envoi d'emails
exports.testEmail = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'The function must be called while authenticated.'
    );
  }

  if (!SENDGRID_API_KEY) {
    return { success: false, message: 'SendGrid non configuré' };
  }

  try {
    const msg = {
      to: data.email || 'test@example.com',
      from: 'romain.cuisine.972@gmail.com',
      subject: 'Test Email - Coconut Agencement',
      text: 'Ceci est un email de test.',
      html: '<strong>Ceci est un email de test.</strong>',
    };

    await sgMail.send(msg);
    return { success: true, message: 'Email de test envoyé' };
  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email de test:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Erreur lors de l\'envoi de l\'email de test: ' + error.message
    );
  }
});