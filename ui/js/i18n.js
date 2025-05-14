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
    signaturesHeader: 'SIGNATURES',
    labelCurrentSignature: 'Current Owner Signature',
    labelNewSignature: 'New Owner Signature',
    cancelBtn: 'Cancel',
    submitBtn: 'Submit Contract',
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
    signaturesHeader: 'FIRMAS',
    labelCurrentSignature: 'Firma del propietario actual',
    labelNewSignature: 'Firma del nuevo propietario',
    cancelBtn: 'Cancelar',
    submitBtn: 'Enviar Contrato',
  },
};
function getUserLang() {
  const lang = navigator.language.slice(0, 2);
  return translations[lang] ? lang : 'en';
}
