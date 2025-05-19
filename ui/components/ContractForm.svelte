<script>
  import ContractHeader from './ContractHeader.svelte';
  import FieldInput from './FieldInput.svelte';
  import SignatureField from './SignatureField.svelte';

  let { config, t, onCancel, onSubmit } = $props();

  let firstName = $state(config.prefill.firstName);
  let lastName = $state(config.prefill.lastName);
  let plate = $state(config.prefill.plate);
  let model = $state(config.prefill.model);
  let color = $state(config.prefill.color);
  let newOwner = $state(config.prefill.newOwner);
  let newOwnerId = $state(config.prefill.newOwnerId);
  let newOwnerCitizenID = $state(config.prefill.newOwnerCitizenID);

  let currentOwnerSignature = $state('');
  let newOwnerSignature = $state('');
  const currentRole = config.prefill.currentRole;

  let isCurrentOwnerSigned = $derive(() => !!currentOwnerSignature);
  let isNewOwnerSigned = $derive(() => !!newOwnerSignature);

  function handleSign(role) {
    if (role === 'currentOwner') {
      currentOwnerSignature = `${firstName} ${lastName}`;
    } else if (role === 'newOwner') {
      if (
        `${firstName} ${lastName}`.trim().toLowerCase() ===
        newOwner.trim().toLowerCase()
      ) {
        alert('El propietario actual no puede firmar como nuevo propietario.');
        return;
      }
      newOwnerSignature = newOwner;
    }
  }

  function handleCancel() {
    firstName = '';
    lastName = '';
    plate = '';
    model = '';
    color = '';
    newOwner = '';
    newOwnerId = '';
    newOwnerCitizenID = '';
    currentOwnerSignature = '';
    newOwnerSignature = '';
    onCancel?.();
  }

  function handleSubmit() {
    if (!isCurrentOwnerSigned) {
      alert('Please sign the contract before submitting.');
      return;
    }
    onSubmit?.({
      firstName,
      lastName,
      plate,
      model,
      color,
      newOwner,
      newOwnerId,
      newOwnerCitizenID,
      currentOwnerSignature,
      newOwnerSignature,
    });
  }
</script>

<div class="contract-container">
  <ContractHeader
    sealUrl={config.sealUrl}
    title={t.title}
    subtitle={t.subtitle}
    legalText={t.legalText}
  />

  <div class="section">
    <h3>{t.ownerInfoHeader}</h3>
    <div class="grid-two">
      <FieldInput
        id="firstName"
        label={t.labelFirstName}
        name="firstName"
        value={firstName}
        onInput={(e) => (firstName = e.target.value)}
      />
      <FieldInput
        id="lastName"
        label={t.labelLastName}
        name="lastName"
        value={lastName}
        onInput={(e) => (lastName = e.target.value)}
      />
    </div>
  </div>

  <div class="section">
    <h3>{t.vehicleDetailsHeader}</h3>
    <div class="grid-three">
      <FieldInput
        id="plate"
        label={t.labelPlate}
        name="plate"
        value={plate}
        onInput={(e) => (plate = e.target.value)}
      />
      <FieldInput
        id="model"
        label={t.labelModel}
        name="model"
        value={model}
        onInput={(e) => (model = e.target.value)}
      />
      <FieldInput
        id="color"
        label={t.labelColor}
        name="color"
        value={color}
        onInput={(e) => (color = e.target.value)}
      />
    </div>
  </div>

  <div class="section">
    <h3>{t.transferHeader}</h3>
    <div class="grid-three">
      <FieldInput
        id="newOwner"
        label={t.labelNewOwner}
        name="newOwner"
        value={newOwner}
        onInput={(e) => (newOwner = e.target.value)}
      />
      <FieldInput
        id="newOwnerId"
        label={t.labelNewOwnerId}
        name="newOwnerId"
        value={newOwnerId}
        onInput={(e) => (newOwnerId = e.target.value)}
      />
      <FieldInput
        id="newOwnerCitizenID"
        label={t.labelNewOwnerCitizenID}
        name="newOwnerCitizenID"
        value={newOwnerCitizenID}
        onInput={(e) => (newOwnerCitizenID = e.target.value)}
      />
    </div>
  </div>

  <div class="section">
    <h3>{t.signaturesHeader}</h3>
    <div class="grid-two">
      <SignatureField
        label={t.labelCurrentSignature}
        signedName={currentOwnerSignature}
        disabled={currentRole !== 'currentOwner'}
        onSign={() => handleSign('currentOwner')}
      />
      <SignatureField
        label={t.labelNewSignature}
        signedName={newOwnerSignature}
        disabled={currentRole !== 'newOwner' ||
          `${firstName} ${lastName}`.trim().toLowerCase() ===
            newOwner.trim().toLowerCase()}
        onSign={() => handleSign('newOwner')}
      />
    </div>
  </div>

  <div class="controls">
    <button type="button" on:click={handleCancel}>{t.cancelBtn}</button>
    <button
      type="button"
      on:click={handleSubmit}
      disabled={!isCurrentOwnerSigned}>{t.submitBtn}</button
    >
  </div>
</div>
