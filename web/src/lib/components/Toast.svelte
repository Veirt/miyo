<script lang="ts">
    import { flip } from "svelte/animate";
    import { fly } from "svelte/transition";
    import { notifications } from "$lib/store/notifications";
</script>

<div class="notifications">
    {#each $notifications as notification (notification.id)}
        <div
            class:success={notification.type === "success"}
            class:danger={notification.type === "danger"}
            animate:flip
            class="toast"
            transition:fly={{ y: 30 }}
        >
            <div class="content">{notification.message}</div>
        </div>
    {/each}
</div>

<style>
    .success {
        --at-apply: rounded bg-green-600 px-3;
    }

    .danger {
        --at-apply: rounded bg-red-600 px-3;
    }

    .notifications {
        position: fixed;
        top: 10px;
        left: 0;
        right: 0;
        margin: 0 auto;
        padding: 0;
        z-index: 9999;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        align-items: center;
        pointer-events: none;
    }

    .toast {
        flex: 0 0 auto;
        margin-bottom: 10px;
    }

    .content {
        padding: 10px;
        display: block;
        color: white;
        font-weight: 500;
    }
</style>
