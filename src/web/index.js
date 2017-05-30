var Module = {
    onRuntimeInitialized: function() {
        var e = document.getElementById('loadingDiv');
        e.style.visibility = 'hidden';
        // var e = document.getElementById('startButton');
        // e.style.visibility = 'visible';
        document.getElementById("fullScreenButton").style.visibility="visible";
        Module.ccall('game', null, null);
    }, 
    canvas: (function() {
        var canvas = document.getElementById('canvas');
        return canvas;
        })()
};

var start_function = function(o) {
    o.style.visibility = "hidden";
    document.getElementById("fullScreenButton").style.visibility="visible";
    Module.ccall('game', null, null);
};


(function() {
    var memoryInitializer = '{{ name }}.js.mem';
    if (typeof Module['locateFile'] === 'function') {
        memoryInitializer = Module['locateFile'](memoryInitializer);
    } else if (Module['memoryInitializerPrefixURL']) {
        memoryInitializer = Module['memoryInitializerPrefixURL'] + memoryInitializer;
    }
    var xhr = Module['memoryInitializerRequest'] = new XMLHttpRequest();
    xhr.open('GET', memoryInitializer, true);
    xhr.responseType = 'arraybuffer';
    xhr.send(null);
})();

(function() {
    var script = document.createElement('script');
    script.src = "{{ name }}.js";
    document.body.appendChild(script);
})();
