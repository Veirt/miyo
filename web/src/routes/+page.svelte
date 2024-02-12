<script lang="ts">
    import Navbar from "$lib/components/Navbar.svelte";
    import { upscalers } from "$lib/upscaler";

    // default to esrgan
    let key: keyof typeof upscalers = "realesrgan";

    let data = {
        selectedUpscaler: key,
        scale: upscalers[key].scale.default,
        denoiseLevel: upscalers[key].denoiseLevel?.default,
        modelName: upscalers[key].modelName[0],
    };

    $: {
        data = {
            ...data,
            scale: upscalers[key].scale.default,
            denoiseLevel: upscalers[key].denoiseLevel?.default,
            modelName: upscalers[key].modelName[0],
        };
    }

    let imageVisible = false;
</script>

<Navbar />
<main class="flex flex-col justify-around mx-5 mt-5 md:flex-row">
    <form
        class="p-5 rounded bg-alt basis-[45%] flex flex-col justify-between text-md gap-5"
        action=""
    >
        <div class="flex flex-col gap-2">
            <label for="type">Type</label>
            <select
                bind:value={key}
                class="p-3 rounded bg-background"
                id="type"
            >
                {#each Object.values(upscalers) as upscaler}
                    <option value={upscaler.key}>{upscaler.name}</option>
                {/each}
            </select>
        </div>

        <div class="flex flex-col gap-2">
            <label for="scale">Scale</label>
            <div class="flex gap-2">
                {#each upscalers[key].scale.available as s (s)}
                    <input
                        bind:group={data.scale}
                        type="radio"
                        name="scale"
                        id="scale"
                        value={s}
                        checked={s === upscalers[key].scale.default}
                    />
                    {s}
                {/each}
            </div>
        </div>

        <div class="flex flex-col gap-2">
            <label for="model-name">Model Name</label>
            <select
                bind:value={data.modelName}
                class="p-3 rounded bg-background"
                id="model-name"
            >
                {#each upscalers[key].modelName as m (m)}
                    <option value={m}>{m}</option>
                {/each}
            </select>
        </div>

        <div class="flex flex-col gap-2">
            <label for="output-type">Output type</label>
            <select
                class="p-3 rounded bg-background"
                name="output-type"
                id="output-type"
            >
                <option selected value="png">png</option>
                <option value="jpg">jpg</option>
                <option value="webp">webp</option>
            </select>
        </div>
        <div class="flex flex-col">
            <button
                type="submit"
                class="justify-end p-2 mt-5 rounded bg-secondary"
                >Upscale</button
            >
            <button
                type="submit"
                class="justify-end p-2 mt-5 rounded bg-secondary"
                >Upscale & Download</button
            >
        </div>
    </form>

    <div
        class="p-5 rounded bg-alt basis-[50%] h-[75vh] flex flex-col items-center gap-2"
    >
        <img
            class="object-contain h-full"
            src="https://i.pinimg.com/736x/bc/20/94/bc20948f3bccfd926b41688b38b3d9c9.jpg"
            alt=""
        />
        <div>Test</div>
    </div>
</main>
