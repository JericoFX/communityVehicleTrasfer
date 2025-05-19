<script>
  let { label, signedName = '', disabled = false, onSign } = $props();
</script>

<div class="field">
  <label>{label}</label>
  <div
    class="signature-field {signedName ? 'signed' : ''} {disabled
      ? 'disabled'
      : ''}"
    onclick={() => !disabled && onSign?.()}
    style="user-select: none;"
  >
    {signedName}
  </div>
</div>
