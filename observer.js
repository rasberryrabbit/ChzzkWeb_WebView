var obser=document.querySelector("div.live_chatting_list_wrapper__a5XTV");
if(obser) {
    window.chrome.webview.postMessage("!Observer Start!");
    const observer = new MutationObserver((mutations) => {
        mutations.forEach(mutat => {
            mutat.addedNodes.forEach(node => {
                window.chrome.webview.postMessage(node.outerHTML);
            });
        });
    });

    observer.observe(obser, {
    subtree: false,
    attributes: false,
    childList: true,
    characterData: false,
    });

    observer.start();
    window.addEventListener('unload', function() {
      observer.disconnect();
    });
}

var obserlive=document.querySelector("button.live_chatting_scroll_button_chatting__kqgzN");
if(obserlive) {
    window.chrome.webview.postMessage("#Observer Start#");
    const observerlive = new MutationObserver((mutations) => {
        mutations.forEach(mutat => {
            mutat.addedNodes.forEach(node => {
                window.chrome.webview.postMessage(node.outerHTML);
            });
        });
    });

    observerlive.observe(obserlive, {
    subtree: false,
    attributes: false,
    childList: true,
    characterData: false,
    });

    observerlive.start();
    window.addEventListener('unload', function() {
      observerlive.disconnect();
    });
}
