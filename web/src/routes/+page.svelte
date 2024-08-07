<script lang="ts">
    import Navbar from "$lib/components/Navbar.svelte";
    import ImageLoading from "$lib/components/ImageLoading.svelte";
    import Toast from "$lib/components/Toast.svelte";
    import Dropzone from "svelte-file-dropzone";
    import { CompareImage } from "svelte-compare-image";
    import { upscalers } from "$lib/upscaler";
    import { notifications } from "$lib/store/notifications";
    import { tick } from "svelte";

    const notypecheck = (x: any) => x;

    // default to esrgan
    type Upscaler = keyof typeof upscalers;
    let key: Upscaler = "realesrgan";

    let fileName = "";

    let opt = {
        scale: upscalers[key].scale.default,
        denoiseLevel: upscalers[key].denoiseLevel?.default,
        modelName: upscalers[key].modelName[0],
        outputType: "png",
    };
    function handleKeyChange(key: Upscaler) {
        opt = {
            scale: upscalers[key].scale.default,
            denoiseLevel: upscalers[key].denoiseLevel?.default,
            modelName: upscalers[key].modelName[0],
            outputType: "png",
        };
    }

    $: {
        handleKeyChange(key);
    }

    $: {
        if (opt.modelName.includes("x4")) {
            opt.scale = 4;
        }
    }

    let imageEl: HTMLImageElement;
    let imageResultEl: HTMLImageElement;

    let image: File;
    async function handleFilesSelect(
        e: CustomEvent<{ acceptedFiles: File[] }>,
    ) {
        const { acceptedFiles } = e.detail;
        image = acceptedFiles[0];

        await tick();

        imageEl.src = URL.createObjectURL(image);
        if (imageResultEl.src) {
            imageResultEl.removeAttribute("src");
        }
    }

    let loading = false;
    async function handleSubmit() {
        if (!image) {
            notifications.danger("Please upload an image first", 2000);
            return;
        }
        fileName = `${image.name.split(".")[0]}_${key}_${opt.scale}x_${opt.modelName}.${opt.outputType}`;

        loading = true;
        const formData = new FormData();

        // append that options
        for (const [key, value] of Object.entries(opt)) {
            if (value !== undefined) {
                formData.append(key, value.toString());
            }
        }

        // append the image
        formData.append("image", image);

        try {
            const res = await fetch(`/api/upscale/${key}`, {
                method: "POST",
                body: formData,
            });

            if (res.status === 400) {
                const data = await res.json();
                throw Error(data.message);
            }

            const out = await res.blob();

            notifications.success("Upscaled", 2000);

            loading = false;
            await tick();
            imageResultEl.src = URL.createObjectURL(out);
        } catch (err) {
            notifications.danger(`${err}`, 2000);
            loading = false;
        }
    }

    function handleDownload() {
        if (imageResultEl.src) {
            const a = document.createElement("a");
            a.href = imageResultEl.src;
            a.download = fileName;
            a.click();
            a.remove();
        }
    }
</script>

<Navbar />
<main class="flex flex-col justify-around mx-5 mt-5 lg:flex-row">
    <form
        on:submit|preventDefault={handleSubmit}
        class="p-5 rounded bg-alt basis-[45%] flex flex-col justify-between gap-2"
    >
        <div class="flex flex-col gap-2">
            <div
                class="flex justify-center items-center p-5 text-center rounded bg-background"
            >
                <Dropzone
                    disableDefaultStyles={true}
                    on:drop={handleFilesSelect}
                    accept={"image/jpeg,image/png,image/webp"}
                    disabled={loading}
                >
                    {#if image}
                        <!-- svelte-ignore a11y-missing-attribute -->
                        <div
                            class="flex flex-col gap-2 items-center p-5 bg-alt"
                        >
                            <img class="h-24" bind:this={imageEl} />
                            {image.name}
                        </div>
                    {:else}
                        <div class="flex items-center p-5 h-42">
                            Drag and drop here or click to select an image
                        </div>
                    {/if}
                </Dropzone>
            </div>
        </div>

        <div class="flex flex-col gap-2">
            <label for="upscaler">Upscaler</label>
            <select
                bind:value={key}
                required
                class="p-2 rounded bg-background"
                id="upscaler"
            >
                {#each Object.values(upscalers) as upscaler}
                    <option value={upscaler.key}>{upscaler.name}</option>
                {/each}
            </select>
        </div>

        <div class="flex flex-col gap-2">
            <label for="model-name">Model Name</label>
            <select
                required
                bind:value={opt.modelName}
                class="p-2 rounded bg-background"
                id="model-name"
            >
                {#each upscalers[key].modelName as m (m)}
                    <option value={m}>{m}</option>
                {/each}
            </select>
        </div>

        <div class="flex flex-row gap-10">
            <div class="flex flex-col gap-2">
                <label for="scale">Scale</label>
                <div class="flex gap-2">
                    {#each upscalers[key].scale.available as s (s)}
                        <div hidden={opt.modelName.includes("x4") && s !== 4}>
                            <input
                                required
                                bind:group={opt.scale}
                                type="radio"
                                name="scale"
                                id="scale"
                                value={s}
                                checked={s === upscalers[key].scale.default}
                            />
                            {s}
                        </div>
                    {/each}
                </div>
            </div>

            {#if upscalers[key].denoiseLevel && key == "waifu2x"}
                <div class="flex flex-col gap-2">
                    <label for="denoise">denoise</label>
                    <div class="flex gap-2">
                        <!-- god ts-ignore doesn't work here. this should not be undefined -->
                        {#each notypecheck(upscalers[key].denoiseLevel).available as d (d)}
                            <input
                                required
                                bind:group={opt.denoiseLevel}
                                type="radio"
                                id="denoise"
                                value={d}
                                checked={d ===
                                    // @ts-ignore
                                    upscalers[key].denoiseLevel.default}
                            />
                            {d}
                        {/each}
                    </div>
                </div>
            {/if}
        </div>

        <div class="flex flex-col gap-2">
            <label for="output-type">Output type</label>
            <select
                required
                bind:value={opt.outputType}
                class="p-2 rounded bg-background"
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
                disabled={loading}
                type="submit"
                class="justify-end p-2 mt-5 rounded bg-secondary"
                >Upscale</button
            >
        </div>
    </form>

    <div
        class="invisible p-5 rounded bg-alt basis-[50%] h-[85vh] flex flex-col items-center gap-2"
        class:!visible={(imageEl?.src && imageResultEl?.src) || loading}
    >
        {#if loading}
            <ImageLoading />
        {:else}
            <!-- svelte-ignore a11y-missing-attribute -->
            <img hidden bind:this={imageResultEl} />
            {#if imageEl?.src && imageResultEl?.src}
                <CompareImage
                    imageLeftSrc={imageEl?.src}
                    imageRightSrc={imageResultEl?.src}
                    --handle-size="2.5rem"
                    --handle-border-width="0.125rem"
                    --slider-color="#ffffff"
                    --slider-width="0.125rem"
                ></CompareImage>
                <button
                    class="p-2 w-full rounded bg-secondary"
                    on:click={handleDownload}>Download</button
                >
            {/if}
        {/if}
    </div>
</main>
<Toast />

<style>
    :global(.svelte-compare-image-container) {
        width: 100%;
        height: 100%;
    }

    :global(.svelte-compare-image-container > img) {
        width: 100%;
        height: 100% !important;
        object-fit: contain;
    }
</style>
