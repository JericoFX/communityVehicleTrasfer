<script>
  import ContractForm from './components/ContractForm.svelte';

  let config = {
    sealUrl: '/seal.png',
    prefill: {
      firstName: '',
      lastName: '',
      plate: '',
      model: '',
      color: '',
      newOwner: '',
      newOwnerId: '',
      newOwnerCitizenID: '',
      currentRole: 'currentOwner'
    }
  };

  let t = {
    title: 'Transferencia de Vehículo',
    subtitle: 'Formulario oficial',
    legalText: 'Texto legal aquí...',
    ownerInfoHeader: 'Datos del propietario actual',
    labelFirstName: 'Nombre',
    labelLastName: 'Apellido',
    vehicleDetailsHeader: 'Datos del vehículo',
    labelPlate: 'Patente',
    labelModel: 'Modelo',
    labelColor: 'Color',
    transferHeader: 'Datos del nuevo propietario',
    labelNewOwner: 'Nombre nuevo propietario',
    labelNewOwnerId: 'ID nuevo propietario',
    labelNewOwnerCitizenID: 'DNI nuevo propietario',
    signaturesHeader: 'Firmas',
    labelCurrentSignature: 'Firma propietario actual',
    labelNewSignature: 'Firma nuevo propietario',
    cancelBtn: 'Cancelar',
    submitBtn: 'Enviar'
  };

  function handleCancel() {
    alert('Formulario cancelado');
  }

  function handleSubmit(data) {
    alert('Formulario enviado:\n' + JSON.stringify(data, null, 2));
  }
</script>


<main>
  <ContractForm
    {config}
    {t}
    onCancel={handleCancel}
    onSubmit={handleSubmit}
  />
</main>