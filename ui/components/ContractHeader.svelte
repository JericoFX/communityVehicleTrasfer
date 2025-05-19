<script>
  let { sealUrl, title, subtitle, legalText } = $props();
</script>

<div class="header">
  <img id="seal" alt="Seal" src={sealUrl} />
  <h2 id="title">{title}</h2>
  <p id="subtitle">{subtitle}</p>
  <p class="legal-text" id="legalText">{legalText}</p>
</div>