
function addVideo() {
    var document = getActiveDocument();
    var xml = '<lockup videoID="0"> <img src="https://images.contentful.com/s72atsk5w5jo/3cTlklmseIYWmi0aoaGEoK/344f1a03337534d629b390f973150227/mo-kudeki-startup-swift-header-image.png" width="384" height="226" /> <title>Startup Swift</title> </lockup>'

    var node = handler.parse(xml)

    var section = document.getElementById("videosSection");
    section.appendChild(node)

    handler.addVideoListener(node)
}

function setContent(id, content) {
    var document = getActiveDocument();
    var node = document.getElementById(id)
    node.textContent = content
}

function setAttributeFor(id, attribute, value) {
    elementWithId(id).setAttribute(attribute, value)
}

function removeSpeakers() {
    var parent = elementWithId("sidebarSpeakers")
    var children = parent.children
    var remove = Array()

    for (var i=0; i < children.length; i++) {
        var child = children.item(i)
        if (child.tagName == "text") {
            remove.push(child)
        }
    }

    for (var index in remove) {
        var child = remove[index]
        parent.removeChild(child)
    }
}

function addSpeaker(name) {
    var parent = elementWithId("sidebarSpeakers")
    var xml = '<text>'+name+'</text>'

    var node = handler.parse(xml)

    parent.appendChild(node)
    console.log(node)
}

function clearEvent() {
    
}

function removeChildrenForId(id) {
    var parent = elementWithId(id)
    var children = parent.children
    
    var remove = Array()
    for (var i=0; i < children.length; i++) {
        remove.push(children.item(i))
    }
    
    for (var index in remove) {
        parent.removeChild(remove[index])
    }
}

function elementWithId(id) {
    var document = getActiveDocument();
    return document.getElementById(id)
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

    parse: function (XMLString) {
        var document = getActiveDocument()
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
