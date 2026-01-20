<script lang="ts">
  let count = 0;
  
  function increment() {
    count += 1;
  }
</script>

<style>
  button {
    background: #ff3e00;
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 4px;
  }
</style>

<main>
  <h1>Hello Svelte!</h1>
  <button on:click={increment}>
    Count: {count}
  </button>
</main>
