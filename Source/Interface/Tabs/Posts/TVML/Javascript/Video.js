
function addVideo() {
    var document = getActiveDocument();
    var xml = '<lockup videoID="0"> <img src="https://images.contentful.com/s72atsk5w5jo/3cTlklmseIYWmi0aoaGEoK/344f1a03337534d629b390f973150227/mo-kudeki-startup-swift-header-image.png" width="384" height="226" /> <title>Startup Swift</title> </lockup>'
    
    var node = handler.parse(xml, document)
    
    var section = document.getElementById("videosSection");
    section.appendChild(node)
    
    handler.addVideoListener(node)
}

function setContent(id, content) {
    var document = getActiveDocument();
    var node = document.getElementById("title")
    node.textContent = content
}

var handler = {
    
    addVideoListener: function (node) {
        node.addEventListener("select", handler.select.bind(handler))
    },
    
    select: function(event) {
        var target = event.target
        var videoID = target.attributes.getNamedItem("videoID").value
        console.log("selected video: " + videoID)
        addVideo()
    },
    
    parse: function (XMLString, document) {
        if (!handler.parser) {
            handler.parser = new DOMParser();
        }
        var node = handler.parser.parseFromString(XMLString, 'text/xml');
        if (!document) {
            return node;
        }
        return document.adoptNode(node.documentElement);
    },
    
}
