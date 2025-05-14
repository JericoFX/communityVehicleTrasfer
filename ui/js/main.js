$(document).ready(function () {
  const lang = getUserLang();
  const t = translations[lang];

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

  // prefill data
  $.each(contractConfig.prefill, function (key, val) {
    $(`[name="${key}"]`).val(val);
  });

  // placeholder for message events
  $(window).on('message', function (event) {
    const msg = event.originalEvent.data;
    // switch(msg.action) {
    //   case 'loadContractType':
    //     // TODO
    //     break;
    // }
  });

  // signature click: fill in cursive name
  $('[data-role="sign"]').on('click', function () {
    const role = $(this).data('sign-for');
    let name = '';
    if (role === 'currentOwner') {
      name = $('#firstName').val() + ' ' + $('#lastName').val();
    } else if (role === 'newOwner') {
      name = $('#newOwner').val();
    }
    if (name) {
      $(this).addClass('signed').text(name);
    } else {
      alert(
        t.labelFirstName + ' ' + t.labelLastName + ' ' + 'required to sign'
      );
    }
  });

  // cancel and submit
  $('#cancelBtn').on('click', function () {
    location.reload();
  });
  $('#submitBtn').on('click', function () {
    const values = {};
    $('input').each(function () {
      values[this.name] = $(this).val();
    });
    const allSigned = $('.signature-field')
      .toArray()
      .every((el) => $(el).hasClass('signed'));
    if (!allSigned) {
      alert('All signatures are required.');
      return;
    }
    $.post(
      'https://contract/submit',
      JSON.stringify(values),
      function (response) {
        if (response.status === 'ok') {
          alert('Contract submitted successfully.');
          location.reload();
        } else {
          alert('Error submitting contract: ' + response.error);
        }
      }
    );
  });
});
