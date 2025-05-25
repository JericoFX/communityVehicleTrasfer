$(document).ready(function () {
  let contract = {};

  // --- AUTO DEBUG MODE FOR BROWSER ---
  // Si no estamos en FiveM, inicializa con datos de ejemplo para debug
  if (!window.invokeNative && !window.GetParentResourceName) {
    // Detecta idioma del navegador
    const browserLang = navigator.language?.slice(0, 2) || 'en';

    // Usa config global si existe, si no, crea uno de ejemplo
    const contractData =
      typeof contractConfig !== 'undefined'
        ? contractConfig.prefill
        : {
            firstName: 'Debug',
            lastName: 'User',
            plate: 'TEST123',
            model: 'DebugCar',
            color: 'Blue',
            newOwner: 'Debug Owner',
            newOwnerId: '99',
            newOwnerCitizenID: '00000000',
            currentRole: 'currentOwner',
          };

    // Rellena los campos de input
    Object.entries(contractData).forEach(([key, value]) => {
      $(`[name="${key}"]`).val(value);
    });

    // Muestra el UI
    $('body').fadeIn(200);
  }

  // Función para mostrar/ocultar el UI con animación
  function toggleUI(show) {
    if (show) {
      $('body').fadeIn(200);
    } else {
      $('body').fadeOut(200);
    }
  }

  // Deshabilita la firma del newOwner si el rol no corresponde
  if (
    typeof contractConfig !== 'undefined' &&
    $('[name="currentRole"]').val() !== contractConfig.prefill.currentRole
  ) {
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
        // Reset UI state
        $('.signature-field').removeClass('signed disabled').text('');
        $('input').prop('readonly', false);
        
        // Fill contract data
        if (data && data.contract) {
          fillContractFields(data.contract);
          contract = data.contract;
          
          // Configure UI based on role
          if (contract.role === 'currentOwner') {
            // Current owner can sign, new owner cannot yet
            $('[data-sign-for="currentOwner"]').removeClass('disabled');
            $('[data-sign-for="newOwner"]').addClass('disabled');
          } else if (contract.role === 'newOwner') {
            // Make all inputs readonly for new owner
            $('input').prop('readonly', true);
            // Current owner already signed, new owner can sign
            $('[data-sign-for="currentOwner"]').addClass('disabled signed').text(contract.currentOwner);
            $('[data-sign-for="newOwner"]').removeClass('disabled');
          }
        }
        
        toggleUI(true);
        break;
      case 'close':
        $.post(
          `https://${GetParentResourceName()}/close`,
          JSON.stringify({}),
          function () {
            // UI will be closed by client
          }
        );
        contract = {};
        toggleUI(false);
        break;
    }
  });

  // Firma
  $('[data-role="sign"]').on('click', function () {
    const role = $(this).data('sign-for');
    
    if ($(this).hasClass('disabled')) {
      return; // No permitir firmar si está deshabilitado
    }
    
    let name = '';
    
    if (role === 'currentOwner') {
      name = $('#firstName').val() + ' ' + $('#lastName').val();
      
      if (!name.trim()) {
        $.post(
          `https://${GetCurrentResourceName()}/error`,
          JSON.stringify('Nombre requerido para firmar'),
          function () {}
        );
        return;
      }
      
      // Marcar como firmado visualmente
      $(this).addClass('signed').text(name);
      
      // Enviar firma al servidor
      $.post(
        `https://${GetCurrentResourceName()}/CurrentOwnerSigned`,
        JSON.stringify(contract),
        function () {
          // El cliente manejará el cierre del UI
        }
      );
      return;
      
    } else if (role === 'newOwner') {
      name = $('#newOwner').val();
      
      if (!name.trim()) {
        $.post(
          `https://${GetCurrentResourceName()}/error`,
          JSON.stringify('Nombre del nuevo propietario requerido para firmar'),
          function () {}
        );
        return;
      }
      
      // Seguridad: Evita que el current owner firme como new owner
      const currentOwnerName = $('#firstName').val() + ' ' + $('#lastName').val();
      if (currentOwnerName.trim().toLowerCase() === name.trim().toLowerCase()) {
        $.post(
          `https://${GetCurrentResourceName()}/error`,
          JSON.stringify('El propietario actual no puede firmar como nuevo propietario'),
          function () {}
        );
        return;
      }
      
      // Marcar como firmado visualmente
      $(this).addClass('signed').text(name);
      
      // Enviar firma al servidor
      $.post(
        `https://${GetCurrentResourceName()}/NewOwnerSigned`,
        JSON.stringify(contract),
        function () {
          // El cliente manejará el cierre del UI
        }
      );
      return;
    }
  });

  // Cancelar
  $('#cancelBtn').on('click', function () {
    $.post(
      `https://${GetCurrentResourceName()}/cancel`,
      JSON.stringify(contract || {}),
      function () {
        // El cliente manejará el cierre del UI
      }
    );
  });


});

/**
 * Rellena los campos del contrato con los datos recibidos.
 * @param {Object} data - Objeto con los datos del contrato
 */
function fillContractFields(data) {
  if (!data) return;
  
  // Parse names
  const currentOwnerParts = data.currentOwner ? data.currentOwner.split(' ') : ['', ''];
  const firstName = currentOwnerParts[0] || '';
  const lastName = currentOwnerParts.slice(1).join(' ') || '';
  
  // Fill form fields
  $('#firstName').val(firstName);
  $('#lastName').val(lastName);
  $('#currentOwnerCitizenID').val(data.currentOwnerCitizenID || '');
  $('#newOwner').val(data.newOwner || '');
  $('#newOwnerId').val(data.newOwnerId || '');
  $('#newOwnerCitizenID').val(data.newOwnerCitizenID || '');
  
  // Vehicle information
  if (data.vehicle) {
    $('#plate').val(data.vehicle.plate || '');
    $('#model').val(data.vehicle.vehicle || '');
    $('#color').val(data.vehicle.color || 'N/A');
  }
  
  // Update signature states if already signed
  if (data.currentOwnerSigned) {
    $('[data-sign-for="currentOwner"]').addClass('signed').text(data.currentOwner);
  }
  
  if (data.newOwnerSigned) {
    $('[data-sign-for="newOwner"]').addClass('signed').text(data.newOwner);
  }
}
