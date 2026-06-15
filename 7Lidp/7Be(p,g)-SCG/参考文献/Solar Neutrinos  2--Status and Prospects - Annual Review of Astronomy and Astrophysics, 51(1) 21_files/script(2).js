var searchJournalId;
var dict = {};
// use the dict to change way we retrieve content over https
// the base is used to load loader-min.js (over https we'll serve it locally)
if (document.location.protocol == "https:") {
    dict['comboBase'] = '/action/yui/combo?';
    dict['combine'] = true;
    dict['timeout'] = 10000;
    dict['base'] = '/templates/jsp/js/';
}

YUI(dict).use('node', function(Y) {
    var initTop = function() {
        //add rounded corners in top right/left corners of boxes
        var modulesTopCorners = Y.all('.browseByAlphabet .topTabs .ui_activeTabs-hd li');
        modulesTopCorners.each(function(v) {
            // dynamically create spans for rounded corners
            var control = Y.Node.create(
                '<span class="rnd_corners tp">' +
                    '<span class="rnd1"></span>' +
                    '<span class="rnd2"></span>' +
                    '<span class="rnd3"></span>' +
                    '</span>'
            );
            // prepend spans in desired node
            v.prepend(control);
        });
    };

    // prepend spans in desired node
    var initBottom = function() {
        //add rounded corners in bottom right/left corners of boxes
        var modulesBottomCorners = Y.all('.browseByAlphabet .bottomTabs .ui_activeTabs-hd li');
        modulesBottomCorners.each(function(v) {
            // dynamically create spans for rounded corners
            var control = Y.Node.create(
                '<span class="rnd_corners btm">' +
                    '<span class="rnd3"></span>' +
                    '<span class="rnd2"></span>' +
                    '<span class="rnd1"></span>' +
                    '</span>'
            );
            // prepend spans in desired node
            v.append(control);
        });

    };

    Y.on("domready", initTop);
    Y.on("domready", initBottom);
});


// submits quick search
// user can initiate 3 different kinds of search from header
// 1.journal 2. story 3. staff directory db pub
// depending on type of search add correct inputs and submit form
function submitQuickSearch(aForm) {
    var typeVals = aForm.elements["type"];
    var selectedType;
    for(var i = 0; i < typeVals.length; i++) {
        if(typeVals.item(i).checked) selectedType = typeVals.item(i).value;
    }

    var allField = aForm.elements["AllField"];
    var textToSearch = allField.value;

    if(selectedType == "geninfo") {
        //set correct target in query
        var storyInput = document.createElement("input");
        storyInput.type = "hidden";
        storyInput.name = "target";
        storyInput.value = "story";
        aForm.appendChild(storyInput);

        // in story search we use searchText param, set it in query
        var searchTextInp = document.createElement("input");
        searchTextInp.type = "hidden";
        aForm.appendChild(searchTextInp);
    }else if(selectedType =="thisJournal"){
        var publication = document.createElement("input");
        publication.type ="hidden";
        publication.name="publication";
        publication.value=searchJournalId;
        aForm.appendChild(publication);
    }

    aForm.submit();
}
function goToUrl(url){
    window.location=url;
}
function submitResetPwd(aForm, inputName) {
    var submitInp = document.createElement("input");
    submitInp.type = "hidden";
    submitInp.name = inputName;
    submitInp.value = "true";
    aForm.appendChild(submitInp);

    aForm.submit();
}

// publisher specific custom styles to be added in site editor's "Styles" drop down
window.productSpecificEditorStyle = "Custom Header 1=custom_h1;Custom Paragraph=custom_p";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
$(function() {
    $( "#accordion" ).accordion({
        autoHeight: false,
        navigation: true
    });
});

if('undefined' !== typeof YAHOO){
    YAHOO.util.Event.onDOMReady(function(){
        var totalHeight = YAHOO.util.Dom.get('promo-hd').offsetHeight;
        var elements = YAHOO.util.Dom.getElementsByClassName("secondMenu");//document.querySelectorAll(".secondMenu");
        for (var i = 0, len = elements.length; i < len; i++) {
            elements[i].style.height = totalHeight + "px";
        }
    });
}

function showSection(evt) {

    if(evt == null){ return false; }
    var newID=evt.id;
    var temp=/Box$/;
    newID=newID.replace(temp,"");

    if(document.getElementById(newID).parentNode.className=='yui3-accordion-item activeFig') {
        document.getElementById(newID).parentNode.className='yui3-accordion-item hiddenFig';
    } else{
        document.getElementById(newID).parentNode.className='yui3-accordion-item activeFig';

    }

    return false;
}

function showRightsLinkPopup(tag, e) {
    var winprops = "location=no,toolbar=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=650,height=550";
    PopUp = window.open(tag.getAttribute('href'), 'Rightslink', winprops);
    e.preventDefault();
}





