
function addVideo(id, imageURL, title) {
    imageURL = imageURL.replace("&", "&amp;");
    var document = getActiveDocument();
    var xml = '<lockup videoID="' + id + '">'
    xml += '<img src="' + imageURL + '" width="384" height="226" />'
    xml += '<title>' + title + '</title> </lockup>'

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

    removeChildrenForId("monograms")
}

function clearEvent() {
  removeChildrenForId("sidebarEvent")
  removeChildrenForId("infoEvent")
}

function setEvent(general, specific) {
  setSidebarEvent(general)
  setInfoEvent(specific)
}

function setSidebarEvent(name) {
  var id = "sidebarEvent"
  addXMLToId("<header> <title>Event</title></header>", id)
  addXMLToId("<text>" + name + "</text>", id)

}

function setInfoEvent(name) {
  var id = "infoEvent"
  addXMLToId("<header> <title>Event</title></header>", id)
  addXMLToId("<text>" + name + "</text>", id)
}

function addSpeaker(name, imageURL) {
    addSpeakerToSidebar(name)
    addSpeakerToMonograms(name, imageURL)
}

function addSpeakerToSidebar(name) {
    var parent = elementWithId("sidebarSpeakers")
    var xml = '<text>'+name+'</text>'

    var node = handler.parse(xml)

    parent.appendChild(node)
}

function addSpeakerToMonograms(name, imageURL) {
    var xml = '<monogramLockup><monogram '
    if (imageURL) {
        xml += 'src="' + imageURL + '" '
    }
    var lastIndex = name.lastIndexOf(" ")

    if (lastIndex) {
        var firstName = name.substring(0, lastIndex)
        var lastName = name.substring(lastIndex + 1)
        xml += 'firstName="' + firstName + '" '
        xml += 'lastName="' + lastName + '"'
    }
    xml += ' />'
    xml += '<title>' + name + '</title>'
    xml += '<subtitle>Speaker</subtitle></monogramLockup>'
    addXMLToId(xml, "monograms")
}

function addXMLToId(xml, id) {
    var parent = elementWithId(id)
    var node = handler.parse(xml)
    parent.appendChild(node)
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
        selectVideo(videoID)
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
