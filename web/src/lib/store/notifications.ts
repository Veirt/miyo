// https://svelte.dev/repl/2254c3b9b9ba4eeda05d81d2816f6276?version=4.2.10
import { writable, derived } from "svelte/store";

type Notify = (msg: string, timeout: number) => void;
type Notification = {
    id: string;
    type: "default" | "danger" | "warning" | "info" | "success";
    message: string;
    timeout: number;
};

function createNotificationStore() {
    const _notifications = writable<Notification[]>([]);

    function send(
        message: string,
        type: "default" | "danger" | "warning" | "info" | "success" = "default",
        timeout: number,
    ) {
        _notifications.update((state) => {
            return [...state, { id: id(), type, message, timeout }];
        });
    }

    const notifications = derived<typeof _notifications, Notification[]>(
        _notifications,
        ($_notifications, set) => {
            set($_notifications);
            if ($_notifications.length > 0) {
                const timer = setTimeout(() => {
                    _notifications.update((state) => {
                        state.shift();
                        return state;
                    });
                }, $_notifications[0].timeout);
                return () => {
                    clearTimeout(timer);
                };
            }
        },
    );
    const { subscribe } = notifications;

    return {
        subscribe,
        send,
        default: ((msg, timeout) => send(msg, "default", timeout)) satisfies Notify,
        danger: ((msg, timeout) => send(msg, "danger", timeout)) satisfies Notify,
        warning: ((msg, timeout) => send(msg, "warning", timeout)) satisfies Notify,
        info: ((msg, timeout) => send(msg, "info", timeout)) satisfies Notify,
        success: ((msg, timeout) => send(msg, "success", timeout)) satisfies Notify,
    };
}

function id() {
    return "_" + Math.random().toString(36).substring(2, 9);
}

export const notifications = createNotificationStore();
