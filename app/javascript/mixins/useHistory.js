export class HistoryService {

    unWantedData = ['turbo', 'controller', 'target', 'value']


    constructor() {
        this.history = History
    }

    pushState(data, title, url) {
        this.history.pushState(data, title, url)
    }

    getState() {
        return this.history.getState()
    }


    updateHistory(currentUrl, newData) {
        const state = this.#initStateFromUrl(currentUrl)
        const newUrl = this.getUpdatedURL(currentUrl, newData, state)
        this.pushState(state, state.title, newUrl)
    }

    getUpdatedURL(currentUrl, newData) {

        const base = document.location.origin
        const url = new URL(currentUrl, base)
        
        this.#updateURLFromState(url.searchParams, this.getState())
        
        const wantedData = this.#filterUnwantedData(newData, this.unWantedData);

        wantedData.forEach(([updatedParam, newValue]) => {

            if (newValue === null) {
                url.searchParams.delete(updatedParam)
            } else {
                newValue = Array.isArray(newValue) ? newValue : [newValue]
                url.searchParams.set(updatedParam, newValue.join(','))
            }
        });
        
        return url.pathname + url.search
    }

    #filterUnwantedData(data, unWantedData) {
        return Object.entries(data).filter(([key]) => !unWantedData.some(uw => key.toLowerCase().includes(uw.toLowerCase())))
    }

    #initStateFromUrl(currentUrl) {
        const url = new URL(currentUrl, document.location.origin)
        const urlParams = url.searchParams
        const oldState = this.getState().data
        let newState = oldState
        let oldValue = null
        urlParams.forEach((newVal, key) => {
            oldValue = oldState[key]
            if (oldValue === undefined) {
                newState[key] = newVal
            }
        })
        return newState
    }

    #updateURLFromState(urlParams, state) {
        let oldValue = null
        urlParams.forEach((newVal, key) => {
            oldValue = state[key]
            if (oldValue !== undefined && oldValue !== newVal) {
                urlParams.set(key, newVal)
            } else if (oldValue !== undefined) {
                state[key] = newVal
            }
        })
    }


}