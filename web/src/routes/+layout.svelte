<script lang="ts">
    import "virtual:uno.css";
    import "@unocss/reset/tailwind-compat.css";
</script>

<slot />

<style>
    :global(body) {
        --at-apply: bg-background text-text h-screen;
    }
</style>
