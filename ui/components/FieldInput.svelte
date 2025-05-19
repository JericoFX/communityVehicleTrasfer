<script>
  let { id, label, value, name, type = 'text', onInput } = $props();
</script>

<div class="field">
  <label for={id}>{label}</label>
  <input
    id={id}
    name={name}
    type={type}
    value={value}
    oninput={onInput}
  />
</div>