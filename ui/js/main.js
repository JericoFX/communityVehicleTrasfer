$(document).ready(function () {
  const lang = getUserLang();
  let t = null;
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

  // Función para mostrar/ocultar el UI con animación
  function toggleUI(show) {
    if (show) {
      $('body').fadeIn(200);
    } else {
      $('body').fadeOut(200);
    }
  }

  // Deshabilita la firma del newOwner si el rol no corresponde
  if ($('[name="currentRole"]').val() !== contractConfig.prefill.currentRole) {
    $('[data-sign-for="newOwner"]').addClass('disabled');
  }

  // Handler de mensajes desde Lua
  $(window).on('message', function (event) {
    const msg = event.originalEvent.data;
    let data = msg.data;
    let action = msg.action;
    if (msg.action === undefined) {
      return;
    }
    switch (action) {
      case 'open':
        const lang = getUserLang(data.language);
        t = translations[lang];
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
        toggleUI(false);
        break;
      case 'openForNewOwner':
        fillContractFields(data);
        // Hace todos los inputs readonly
        $('input').prop('readonly', true);
        // Oculta el botón submit
        $('#submitBtn').hide();
        // Solo permite firmar al newOwner
        $('[data-sign-for="newOwner"]').removeClass('disabled');
        $('[data-sign-for="currentOwner"]').addClass('disabled');
        toggleUI(true);
        break;
    }
  });

  // Firma
  $('[data-role="sign"]').on('click', function () {
    const role = $(this).data('sign-for');
    let name = '';
    if (role === 'currentOwner') {
      name = $('#firstName').val() + ' ' + $('#lastName').val();
      // Envía mensaje a Lua y oculta el UI
      $.post(
        `https://${GetCurrentResourceName()}/currentOwnerSigned`,
        JSON.stringify({ signed: true }),
        function () {
          toggleUI(false);
        }
      );
      return;
    } else if (role === 'newOwner') {
      // Seguridad: Evita que el current owner firme como new owner
      const currentOwnerName =
        $('#firstName').val() + ' ' + $('#lastName').val();
      const newOwnerName = $('#newOwner').val();
      if (
        currentOwnerName.trim().toLowerCase() ===
        newOwnerName.trim().toLowerCase()
      ) {
        $.post(
          `https://${GetCurrentResourceName()}/error`,
          JSON.stringify(t.notifications.cannotSignTwice),
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
      // Firma y envía automáticamente el contrato
      $(this).addClass('signed').text(name);
      updateSubmitButtonState();

      const values = {};
      $('input').each(function () {
        values[this.name] = $(this).val();
      });
      $.post(
        `https://${GetCurrentResourceName()}/submitContract`,
        JSON.stringify(values),
        function (response) {
          if (response.status === 'ok') {
            toggleUI(false);
          } else {
            console.log('Error:', response.error);
          }
        }
      );
      return;
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

  // Cancelar
  $('#cancelBtn').on('click', function () {
    $('input').val('');
    $('.signature-field').removeClass('signed').text('');
    location.reload();
  });

  // Submit (solo para casos legacy, normalmente no se usará con este flujo)
  $('#submitBtn').on('click', function () {
    const values = {};
    $('input').each(function () {
      values[this.name] = $(this).val();
    });
    const currentOwnerSigned = $(
      '.signature-field[data-sign-for="currentOwner"]'
    ).hasClass('signed');
    const newOwnerSigned = $(
      '.signature-field[data-sign-for="newOwner"]'
    ).hasClass('signed');
    if (!(currentOwnerSigned && newOwnerSigned)) {
      $.post(
        `https://${GetCurrentResourceName()}/error`,
        JSON.stringify('Both signatures are required to transfer the vehicle')
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

  // Habilita/deshabilita el submit según firmas (legacy)
  function updateSubmitButtonState() {
    const currentOwnerSigned = $(
      '.signature-field[data-sign-for="currentOwner"]'
    ).hasClass('signed');
    const newOwnerSigned = $(
      '.signature-field[data-sign-for="newOwner"]'
    ).hasClass('signed');
    $('#submitBtn').prop('disabled', !(currentOwnerSigned && newOwnerSigned));
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
