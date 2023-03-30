export const getCookie = (name) => {
    document.cookie.replace(/(?:(?:^|.*;\s*)${name}\s*\=\s*([^;]*).*$)|^.*$/, "$1");
}

export const setCookie = (name, value, days) => {
    document.cookie = `${name}=${value};max-age=${days * 24 * 60 * 60}`;
}