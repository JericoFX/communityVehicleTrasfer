const translations = {
  en: {
    title: 'VEHICLE TRANSFER CONTRACT',
    subtitle:
      'Official vehicle ownership transfer agreement between two parties.',
    legalText:
      'This agreement is entered into between the parties listed below, hereinafter referred to as the "Current Owner" and "New Owner," and shall be governed by applicable state and federal laws.',
    ownerInfoHeader: 'OWNER INFORMATION',
    labelFirstName: 'First Name',
    labelLastName: 'Last Name',
    vehicleDetailsHeader: 'VEHICLE DETAILS',
    labelPlate: 'License Plate',
    labelModel: 'Vehicle Model',
    labelColor: 'Color',
    transferHeader: 'TRANSFER DETAILS',
    labelNewOwner: "New Owner's Full Name",
    labelNewOwnerId: "New Owner's ID",
    labelNewOwnerCitizenID: "New Owner's Citizen ID",
    signaturesHeader: 'SIGNATURES',
    labelCurrentSignature: 'Current Owner Signature',
    labelNewSignature: 'New Owner Signature',
    cancelBtn: 'Cancel',
    submitBtn: 'Submit Contract',
    notifications: {
      bothSignaturesRequired:
        'Both signatures are required to transfer the vehicle.',
      cannotSignTwice: 'You cannot sign in both places.',
      fieldsRequired: 'First Name and Last Name are required to sign.',
      contractSubmitted: 'Contract submitted successfully!',
      contractError: 'There was an error submitting the contract.',
    },
  },
  es: {
    title: 'CONTRATO DE TRANSFERENCIA DE VEHÍCULO',
    subtitle:
      'Acuerdo oficial de transferencia de propiedad de vehículo entre dos partes.',
    legalText:
      'Este acuerdo se celebra entre las partes que figuran a continuación, en adelante denominadas "Propietario Actual" y "Nuevo Propietario", y se regirá por las leyes estatales y federales aplicables.',
    ownerInfoHeader: 'INFORMACIÓN DEL PROPIETARIO',
    labelFirstName: 'Nombre',
    labelLastName: 'Apellido',
    vehicleDetailsHeader: 'DETALLES DEL VEHÍCULO',
    labelPlate: 'Matrícula',
    labelModel: 'Modelo',
    labelColor: 'Color',
    transferHeader: 'DETALLES DE TRANSFERENCIA',
    labelNewOwner: 'Nombre completo del nuevo propietario',
    labelNewOwnerId: 'ID del nuevo propietario',
    labelNewOwnerCitizenID: 'ID de ciudadano del nuevo propietario',
    signaturesHeader: 'FIRMAS',
    labelCurrentSignature: 'Firma del propietario actual',
    labelNewSignature: 'Firma del nuevo propietario',
    cancelBtn: 'Cancelar',
    submitBtn: 'Enviar Contrato',
    notifications: {
      bothSignaturesRequired:
        'Se requieren ambas firmas para transferir el vehículo.',
      cannotSignTwice: 'No puedes firmar en ambos lugares.',
      fieldsRequired: 'Nombre y Apellido son obligatorios para firmar.',
      contractSubmitted: '¡Contrato enviado con éxito!',
      contractError: 'Hubo un error al enviar el contrato.',
    },
  },
};

function getUserLang(lang) {
  return translations[lang] ? lang : 'en';
}
