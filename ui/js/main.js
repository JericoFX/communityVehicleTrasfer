$(document).ready(function () {
  const lang = getUserLang();
  const t = translations[lang];
  let contract = {};
  // onLoad logic
  $('#seal').attr('src', contractConfig.sealUrl);
  $('#title').text(t.title);
  $('#subtitle').text(t.subtitle);
  $('#legalText').text(t.legalText);
  $('#ownerInfoHeader').text(t.ownerInfoHeader);
  $('#labelFirstName').text(t.labelFirstName);
  $('#labelLastName').text(t.labelLastName);
  $('#vehicleDetailsHeader').text(t.vehicleDetailsHeader);
  $('#labelPlate').text(t.labelPlate);
  $('#labelModel').text(t.labelModel);

  $('#labelColor').text(t.labelColor);
  $('#transferHeader').text(t.transferHeader);
  $('#labelNewOwner').text(t.labelNewOwner);
  $('#signaturesHeader').text(t.signaturesHeader);
  $('#labelCurrentSignature').text(t.labelCurrentSignature);
  $('#labelNewSignature').text(t.labelNewSignature);
  $('#cancelBtn').text(t.cancelBtn);
  $('#submitBtn').text(t.submitBtn);
  $('#labelDate').text(t.labelDate);
  $('#labelNewOwnerId').text(t.labelNewOwnerId);
  $('#labelNewOwnerCitizenID').text(t.labelNewOwnerCitizenID);
  // prefill data
  function toggleUI(show) {
    if (show) {
      $('body').fadeIn(200); // 200 ms de animación
    } else {
      $('body').fadeOut(200);
    }
  }
  if ($('[name="currentRole"]').val() !== contractConfig.prefill.currentRole) {
    $('[data-sign-for="newOwner"]').addClass('disabled');
  }
  // placeholder for message events
  $(window).on('message', function (event) {
    const msg = event.originalEvent.data;
    let data = msg.data;
    let action = msg.action;
    if (msg.action === undefined) {
      return;
    }
    switch (action) {
      case 'open':
        location.reload();
        fillContractFields(data);
        toggleUI(true);
        break;
      case 'close':
        $.post(
          `https://${GetCurrentResourceName()}/close`,
          JSON.stringify({}),
          function (response) {
            if (response.status === 'ok') {
              location.reload();
            } else {
              console.log('Error:', response.error);
            }
          }
        );
        toggleUI;
        false;
        break;
    }
  });

  // signature click: fill in cursive name
  $('[data-role="sign"]').on('click', function () {
    const role = $(this).data('sign-for');
    // Solo permite firmar si el rol coincide con el usuario actual

    let name = '';
    if (role === 'currentOwner') {
      name = $('#firstName').val() + ' ' + $('#lastName').val();
    } else if (role === 'newOwner') {
      // Seguridad: Evita que el current owner firme como new owner
      // Puedes comparar el nombre del new owner con el current owner
      const currentOwnerName =
        $('#firstName').val() + ' ' + $('#lastName').val();
      const newOwnerName = $('#newOwner').val();
      if (
        currentOwnerName.trim().toLowerCase() ===
        newOwnerName.trim().toLowerCase()
      ) {
        $.post(
          `https://${GetCurrentResourceName()}/error`,
          JSON.stringify('You cant sign in the two places'),
          function (response) {
            if (response.status === 'ok') {
              location.reload();
            } else {
              console.log('Error:', response.error);
            }
          }
        );

        return;
      }
      name = newOwnerName;
    }
    if (name) {
      $(this).addClass('signed').text(name);
      updateSubmitButtonState();
    } else {
      alert(
        t.labelFirstName + ' ' + t.labelLastName + ' ' + 'required to sign'
      );
    }
  });

  // cancel and submit
  $('#cancelBtn').on('click', function () {
    $('input').val('');
    $('.signature-field').removeClass('signed').text('');
    location.reload();
  });
  $('#submitBtn').on('click', function () {
    const values = {};
    $('input').each(function () {
      values[this.name] = $(this).val();
    });
    const allSigned = $('[data-sign-for="currentOwner"]').hasClass('signed');
    if (!allSigned) {
      $.post(
        `https://${GetCurrentResourceName()}/error`,
        JSON.stringify('You need to sign the document first')
      );
      return;
    }
    $.post(
      `https://${GetCurrentResourceName()}/submitContract`,
      JSON.stringify(values),
      function (response) {
        if (response.status === 'ok') {
          location.reload();
        } else {
          console.log('Error:', response.error);
        }
      }
    );
  });

  function updateSubmitButtonState() {
    const currentOwnerSigned = $(
      '.signature-field[data-sign-for="currentOwner"]'
    ).hasClass('signed');
    $('#submitBtn').prop('disabled', !currentOwnerSigned);
  }

  // Llama al cargar la página
  updateSubmitButtonState();
});

/**
 * Rellena los campos del contrato con los datos recibidos.
 * @param {Object} data - Objeto con los datos a rellenar (ej: { firstName: 'Juan', lastName: 'Pérez', ... })
 */
function fillContractFields(data) {
  Object.entries(data).forEach(([key, value]) => {
    $(`[name="${key}"]`).val(value);
  });
  // Si necesitas actualizar otros elementos (no inputs), agrégalo aquí
  // Por ejemplo: $('#labelFirstName').text(data.firstName);
}
