/* function that will be called from document.onload event
 * main event handling, for all pages */
function preload() {
    load();
}
function preunload() {
    unload();
}

/* function that will be called from document.onload event
 * override this function to do individual onload event */
function load()
{
}
function unload()
{
}

/**
 * Change the forecolor of the element with id eid
 * to the color specified by color
 */
function changeForegroundColor(eid, color) {
    if(document.getElementById && (elem=document.getElementById(eid)))
        elem.style.color=color;
}

/**
 * Shorthand for id'ing elements
 */
if (typeof $ == "undefined") $ = function(id) { return document.getElementById(id); }   // do not override if already defined by prototype

/**	ccc rights link */
function RightslinkPopUp(aPublisher, aPublication, aTitle, aDate, aAuthor, aContentId, aCopyright, aVolume, aIssue, aStartPage, aEndPage, aIssn, aOrderBeanReset, aColor,aIncludeColor, aReprints, aPermissions)
{
    var location =
        "?publisherName=" + aPublisher
            + "&publication=" + aPublication
            + "&title=" + aTitle
            + "&publicationDate=" + aDate
            + "&author=" + aAuthor
            + "&contentID=" + aContentId
            + "&copyright=" + aCopyright
            + "&startPage=" + aStartPage
            + "&endPage=" + aEndPage;
    if (aVolume != null) {
        location += "&volumeNum=" + aVolume;
    }
    if (aIssue != null) {
        location += "&issueNum=" + aIssue;
    }
    if (aIssn != null) {
        location += "&issn=" + aIssn;
    }
    if (aOrderBeanReset != null) {
        location += "&orderBeanReset=" + aOrderBeanReset;
    }
    if(aIncludeColor != 'false'){
        if (aColor != null){
            location += "&color=" + aColor;
        }
    }
    if (aReprints != null) {
        location += "&reprints=" + aReprints;
    }
    if (aPermissions != 'false') {
        location += "&permissions=" + aPermissions;
    }

    var link = "/servlet/linkout?type=rightslink&url=" + escape(location);
    var winprops = "location=no,toolbar=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=650,height=550";
    PopUp = window.open(link, 'Rightslink', winprops);
}


/* Function to load images.
 *	note: make this empty method so that
 * 1) mininize code changes; 2) for future integration; 3) easier to take the feature back
 */
function MM_preloadImages() {
}

function MM_swapImgRestore() {
}

function MM_findObj(n, d) {
}

function MM_swapImage() {
}

function menuMouseOver(type, actualType) {
    document.getElementById('MenuItem_'+type).className='MenuItemOver_'+(type == actualType);
}
function menuMouseOut(type, actualType) {
    document.getElementById('MenuItem_'+type).className='MenuItem_'+(type == actualType);
}
function menuClick(type) {
    document.getElementById('MenuLink_'+type).click();
}

// browser detection
function browserCheck() {
    this.ns4 = (document.layers)? true:false;
    this.ie = (document.all&&(!window.opera))? true:false;
    this.dom = (document.getElementById)? true:false;
    this.ns6 = (window.sidebar)? true:false;
    this.moz = (window.sidebar||navigator.userAgent.indexOf('Gecko')!=-1)? true:false;
    this.opera = (window.opera)? true:false;
    this.mac = (navigator.userAgent.indexOf('Mac')!=-1)? true:false;
}
browser = new browserCheck();
var Obj;

// multibrowser get object by id, in NN4 you cannot access all object (test it first)
function getObjectByName(nameOfObject){
    Obj = null;
    if (browser.ie) Obj = document.all[nameOfObject]
    else if (browser.dom) Obj = findDOMObject(nameOfObject)
    else if (browser.ns4) findLayer(window,nameOfObject);
    return (!Obj || ( browser.ns4 && Obj == window ) ) ? "Object not found" : Obj;
}
// helper function
function findDOMObject(nameOfObject) {
    for (var i = 0; i < document.images.length; i++) {
        if (document.images[i].name==nameOfObject) return document.images[i]
    }
    return document.getElementById(nameOfObject)
}
// helper function
function findLayer(node,nameOfObject) {
    if ( node.name == nameOfObject ) Obj = node;
    for ( var counter = 0; counter < node.document.images.length; counter++ ) {
        if (node.document.images[counter].name==nameOfObject) Obj = node.document.images[counter];
    }
    for ( var i = 0; i < node.document.layers.length; i++ ) {
        findLayer(node.document.layers[i],nameOfObject);
    }
}

function toggleVisibility(id) {
    obj = getObjectByName(id);
    if (obj) {
        v = obj.style.display;
        obj.style.display = (v == 'none') ? 'block' : 'none';
        i = getObjectByName('hiddenImage');
        if(i) i.src = '/page/imageHack.jsp?object=' + id + '&display=' + obj.style.display + '&dummy=' + (new Date()).getTime();
    }
}

/** CSS class support */
/** return true if removed, false if not found */
function removeClass(el, className) {
    if (!(el && el.className)) return false;
    var cls = el.className.split(" ");
    var ar = new Array();
    for (var i = cls.length; i > 0;) if (cls[--i] != className) ar[ar.length] = cls[i];
    el.className = ar.join(" ");
    return cls.length != ar.length;
}
/** return true if element has that class */
function hasClass(el, className) {
    if (!(el && el.className)) return false;
    var cls = el.className.split(" ");
    for (var i = cls.length; i > 0;) if (cls[--i] == className) return true;
    return false;
}
/** add class to element, if element already had that class - does nothink */
function addClass(el, className) {
    if (!el || hasClass(el, className)) return;
    if (el.className) el.className += " " + className;
    else el.className = className;
}
/** Add CSS rule as last rule in last stylesheet - override all previous definitions
 removing is harder - not implemented, use it with caution */
function addCssRule(selector, rule) {
    if (document.styleSheets) {
        var css = document.styleSheets[document.styleSheets.length-1]; // get last css
        if (css.addRule) css.addRule(selector, rule);         // IE
        else if (css.insertRule) css.insertRule(selector + "{" + rule + "}", css.cssRules.length);  // W3C
    }
}
/** get CSS style of the document */
function getCssText() {
    var imports = "";
    var cssText = "\n";
    var styleSheets = document.styleSheets;
    for (var i = 0; i < styleSheets.length; i++) {
        var css = styleSheets.item(i);
        var mediaText = typeof css.media == "string" ? css.media : css.media.mediaText;
        if (!mediaText || mediaText.indexOf("all") != -1 || mediaText.indexOf("screen") != -1) {
            if (css.imports) {
                // IE imports
                for (var j = 0; j < css.imports.length; j++) {
                    var href = css.imports[j].href;
                    var lastQuote = href.lastIndexOf('"');
                    if (lastQuote != -1) {
                        // href contains media - "url" media
                        mediaText = href.substr(lastQuote + 1);
                        if (mediaText.indexOf("all") == -1 && mediaText.indexOf("screen") == -1) continue;
                        href = href.substr(1, lastQuote - 1);
                    }
                    imports += '@import url("' + href + '");\n';
                }
            }
            if (css.rules) {
                // IE rules
                for (var j = 0; j < css.rules.length; j++) {
                    // How to filter media rules ???
                    cssText += css.rules[j].selectorText + " { " + css.rules[j].style.cssText + " }\n";
                }
            } else if (css.cssRules) {
                // W3C compliant browser
                for (var j = 0; j < css.cssRules.length; j++) {
                    var rule = css.cssRules.item(j);
                    if (rule.type == rule.IMPORT_RULE || rule.type == rule.MEDIA_RULE) {
                        mediaText = rule.media.mediaText;
                        if (mediaText && mediaText.indexOf("all") == -1 && mediaText.indexOf("screen") == -1) continue;
                        if (rule.type == rule.IMPORT_RULE) imports += rule.cssText;
                        else cssText += rule.cssText + "\n";
                    } else {
                        cssText += rule.cssText + "\n";
                    }
                }
            }
        }
    }
    return imports + cssText;
}

function loadCss(url, title, media) {
    var el = document.createElement('link');
    el.type = 'text/css';
    el.rel = 'stylesheet';
    el.href = url;
    el.media = media || 'screen';
    el.title = title || 'dynamicLoadedSheet';
    document.getElementsByTagName("head")[0].appendChild(el);
}

function loadJs(url) {
    var el = document.createElement("script");
    el.type = "text/javascript";
    el.src = url;
    document.getElementsByTagName("head")[0].appendChild(el);
}

/** DOM Event support */
/** addEventListener method may already exist, it's not trivial implement it and not break it, use other mame 'addListener' is simple */
function addListener(el, evname, func) {
    if (el.attachEvent) el.attachEvent("on" + evname, func);
    else if(el.addEventListener) el.addEventListener(evname, func, true);
}
/** removeEventListener */
function removeListener(el, evname, func) {
    if (el.detachEvent) el.detachEvent("on" + evname, func);
    else if (el.removeEventListener) el.removeEventListener(evname, func, true);
}

/** Server session access */
/** helper method to access session object */
function _getSession() {
    return window.session ? window.session : (window.session = new Array());
}
/** send request to server to preserve some value between different requests, value is accessible using getSessionAttribute */
function setSessionAttribute(name, value) {
    /* just to test callback */
    function test(doc) {
//        alert("Server returned: " + doc.body.innerHTML);
    }
    sendServerMsg("/action/sessionAccess?action=setJavaScriptAttribute&name=" + name + "&value=" + value, test);
    _getSession()[name] = value;
}
/** see setSessionAttribute */
function getSessionAttribute(name) {
    return _getSession()[name];
}

/** send request - url - to the server, response is accessible in document passed to callback function
 DO NOT Send anything before page is loaded!
 */
function sendServerMsg(url, callBack) {
    /* called when frame is loaded */
    function _receiveServerResponse(ev) {
        var iFrame = window.event ? window.event.srcElement : ev.currentTarget;                          // IE : W3C
        var doc = iFrame.contentDocument ? iFrame.contentDocument : document.frames(iFrame.id).document; // W3C : IE
        if (iFrame.callBack) iFrame.callBack(doc);
        document.body.removeChild(document.getElementById(iFrame.id));
    }

    var iFrame = document.createElement('iframe');
    addListener(iFrame, "load", _receiveServerResponse);
    iFrame.setAttribute("id", "msgFrame" + new Date().getTime());   // so IE can retrive document
    iFrame.setAttribute("src", url);
    iFrame.setAttribute("style", "display:none");
    if (callBack) iFrame.callBack = callBack;
    document.body.appendChild(iFrame);
}

/**
 copy innerHTML of src element to innerHTML of target element
 */
function copyInnerHtml(src, target) {
    var domSupported = document.getElementById ? true : false;
    var se = (domSupported && typeof src == "string") ? document.getElementById(src) : src;
    var te = (domSupported && typeof target == "string") ? document.getElementById(target) : target;
    if (se.innerHTML && te.innerHTML) te.innerHTML = se.innerHTML;
}
/**
 filter select options, options that do not contain filter text are removed
 in first use, original select options are backed up as attribute optionsCopy
 */
function filterSelect(selectId, value) {
    var select;
    if (document.getElementById && (select = document.getElementById(selectId)) && select.options) {
        if (!select.optionsCopy) {
            select.optionsCopy = new Array();
            select.optionTexts = new Array();
            for (var i=0; i<select.options.length; i++) {
                var opt = select.options[i];
                select.optionsCopy[i] = opt;
                select.optionTexts[i] = opt.text.toLowerCase();
            }
        }
        value = value.toLowerCase();
        var allTexts = select.optionTexts;
        var displayOptions = select.options;
        var count = displayOptions.length = 0;
        for (var i=0; i < allTexts.length; i++) {
            if (allTexts[i].indexOf(value) != -1) {
                var option = select.optionsCopy[i];
                displayOptions[count++] = option;
                option.selected = option.text == value;
            }
        }
        if (count == 1) displayOptions[0].selected = true;
    }
}

function popupElement(el, anchor, windowParams) {
    if (typeof el == "string") { // el is id
        el = (document.getElementById) ? document.getElementById(el) :
            (document.all) ? document.all[el] : false;
    }
    if (el) {
        var tmp;
        if (el.popupWindow && !el.popupWindow.closed) {
            el.popupWindow.focus();
            tmp = el.popupWindow.document;
        } else {
            if(!windowParams) windowParams = {};
            el.popupWindow = window.open('',
                windowParams.name?windowParams.name:'',
                windowParams.featureString?windowParams.featureString:'resizable=yes,scrollbars=yes,width=600,height=500');
            tmp = el.popupWindow.document;
            tmp.writeln('<html><head><title>'+document.title+'</title><style type="text/css">');
            var styleSheets = document.styleSheets;
            for (var i = 0; styleSheets && i < styleSheets.length; i++) {
                var css = styleSheets.item(i);
                var cssHref = css.href;
                /* in FF we get js error (Security error: 1000) when we try to access stylesheets coming from
                 * a different domain (e.g yui stylesheets included in ar), for these cases don't load stylesheets
                 * we don't really need them. */
                if(cssHref != null && cssHref.indexOf(window.location.hostname) > 0) {
                    if (css.cssText) tmp.writeln(css.cssText);
                    else {
                        var cssRules = css.rules ? css.rules : css.cssRules;
                        for (var j = 0; cssRules && j < cssRules.length; j++) {
                            tmp.writeln(cssRules.item(j).cssText);
                        }
                    }
                }
            }
            tmp.writeln('</style></head><body id="' + el.id + '">');
            tmp.writeln(el.innerHTML);
            tmp.writeln('</body></html>');
            tmp.close();
        }
        if (anchor) {
            var target = (tmp.getElementById) ? tmp.getElementById(anchor) :
                (tmp.all) ? tmp.all[anchor] : false;
            if (target) {
                if (target.scrollIntoView) target.scrollIntoView();
                else if (window.scroll && target.offsetTop) el.popupWindow.scroll(0, target.offsetTop);
            }
        }
    }
}

/**	marks all check box */
function markAllCheckboxes(aForm, aNamePrefix, aChecked)
{
    var elmts = aForm.elements;
    for (var i=0; i<elmts.length; i++)
        if ((elmts[i].type == "checkbox") &&
            (elmts[i].name.indexOf(aNamePrefix) == 0))
            elmts[i].checked = aChecked;
}

function submitMultiArticles(aForm, action, aMarkall, errorMessage) {
    var hasMarked = false;
    var elmts = aForm.elements;
    for (var i = 0; i < elmts.length; i++) {
        if ((elmts[i].name == "doi") &&
            (elmts[i].type == "checkbox") &&
            (elmts[i].checked)) {
            hasMarked = true;
            break;
        }
    }

    if (!hasMarked) {
        if (aMarkall) {
            markAllCheckboxes(aForm, "doi", true);
        } else {
            alert(errorMessage ? errorMessage : "Please check at least one article.");
            return false;
        }
    }

    for (var i = 0; i < elmts.length; i++) {
        if ((elmts[i].name == "doi") &&
            (elmts[i].type != "checkbox")) {
            elmts[i].name = "xdoi";
        }
    }

    if (aForm.getAttributeNode) {
        aForm.getAttributeNode("action").nodeValue = action;
    } else {
        aForm.action = action;
    }
    aForm.method = "post";
    aForm.submit();
    return true;
}

function setCheckWhenDefine(aCbx, aState)
{
    if (aCbx) {
        aCbx.checked = aState;
    }
}

// --- side sfx links ---
//
function genSideCitation(dbid, linkoutUrl, display) {
    genSide('citation', dbid, linkoutUrl, display);
}
function genSideQuickSearch(dbid, value, display) {
    genSide('quicksearch', dbid, '', display, '', '', '', value);
}
function genSideRelated(dbid, linkoutUrl, display) {
    genSide('related', dbid, linkoutUrl, display);
}

// --- popup ---
//
/*Function to generate a popup window, with params to pass to dispatcher */
function popup(citart, id, doi, ptype, area) {
    popupRef(citart, id, doi, ptype, area, 600, 500);
}

function popupFull(id, doi, ptype, area, width, height) {
    var popupURL = "/action/showFullPopup?id=" + id + "&doi=" + doi;
    if (area) popupURL += "&area=" + area;
    if (ptype) ptype = ptype.replace(/\W/g, '');
    var winname = ptype ? ptype : 'popupRef';
    var n = window.open(popupURL, winname, 'resizable=yes,scrollbars=yes,width='+width+',height='+height);
    n.focus();
}
function popupRef(citart, id, doi, ptype, area, width, height) {
    var popupURL = "/action/showPopup?citid=" + citart + "&id=" + id + "&doi=" + doi;
    if (area) popupURL += "&area=" + area;
    if (ptype) ptype = ptype.replace(/\W/g, '');
    var winname = ptype ? ptype : 'popupRef';
    var n = window.open(popupURL, winname, 'resizable=yes,scrollbars=yes,width='+width+',height='+height);
    n.moveTo(10,10);
    n.focus();
}

function popupHelp550(aUrl)
{
    popupHelpX(aUrl, "width=550,height=540,top=10,left=50,toolbar=0,menubar=0,resizable=yes,scrollbars=yes");
}
function popupHelp580(aUrl)
{
    popupHelpX(aUrl, "width=580,height=540,top=10,left=50,toolbar=0,menubar=0,resizable=yes,scrollbars=yes");
}
function popupHelp625(aUrl)
{
    popupHelpX(aUrl, "width=625,height=540,top=10,left=50,toolbar=0,menubar=0,resizable=yes,scrollbars=yes");
}
function popupHelpX(aUrl, aWinProps)
{
    var winid = window.open(aUrl,"popupHelp",aWinProps);
    if (winid.focus) winid.focus();
    return false;
}
function popupHelp(aUrl)
{
    popupHelp580(aUrl);
}

/* Function to open up a new browser window, without a navigation bar */
function popupCoverImage(url)
{
    var new_window;
    var windowProperties;
    windowProperties = "width=750,height=700,top=30,left=230,toolbar=0,menubar=0,resizable=1,scrollbars=yes";
    if(new_window==null) {
        new_window = window.open(url,null,windowProperties);
    } else {
        new_window.document.replace(url);
    }
}

// --- quick search ---
//
/**
 *	get all the form elements and check if the "dbname"
 *	maps to specifid value.
 */
function checkDbName(aForm, aValue)
{
    var elements = aForm.elements;
    for (var i=0; i<elements.length; i++)
    {
        var elmt = elements[i];
        if (elmt.name == "dbname")
        {
            if (elmt.options) {
                if ((elmt.value == aValue) ||
                    (elmt.options[elmt.selectedIndex].value == aValue))
                    return true;
            }
            else if (elmt.checked && (elmt.value == aValue)) {
                return true;
            }
        }
    }
    return false;
}

function onAuthorSearchClick(aForm)
{
    if (! aForm) {
        aForm = document.document.forms[0];
    }
    var elmts = aForm.elements;
    var authors = new Array();
    var keywords = new Array();
    getAuthorsAndKeywords(aForm, authors, keywords, false);
    if (checkDbName(aForm, "medline")) {
        showPubMedSearch(authors, keywords);
    } else if (checkDbName(aForm, "ads")) {
        showAdsSearch(authors, keywords);
    } else if (checkDbName(aForm, "crossref")) {
        showCrossRefSearch(authors, keywords);
    } else {
        var url = "/action/doSearch";
        for (var i=0; i<elmts.length; i++) {
            if (! elmts[i].name)
                continue;
            var addElmt = false;
            if (elmts[i].type == "checkbox")
                addElmt = elmts[i].checked;
            else
                addElmt = (elmts[i].value.length > 0);
            if (addElmt) {
                if (i == 0) {
                    url += "?" + elmts[i].name + "=" + elmts[i].value;
                } else {
                    url += "&" + elmts[i].name + "=" + elmts[i].value;
                }
            }

        }
        window.location = url;
    }
}

/**
 *	@param	aAuthorArray	array stores all authors
 *	@param	aKeywordArray	array stores all keywords
 */
function getAuthorsAndKeywords(aForm, aAuthorArray, aKeywordArray, aForceAdd)
{
    setCheckWhenDefine(aForm.sauthusercbx, true);
    setCheckWhenDefine(aForm.keyusercbx, true);

    var elements = aForm.elements;
    var cntAuthor = -1;
    var cntKeyword = -1;
    for (var i=0; i<elements.length; i++)
    {
        var elmt = elements[i];
        if ((elmt.name == "Contrib") ||
            (elmt.name == "sauthusercbx"))
        {
            if (elmt.name == "sauthusercbx") {
                cntAuthor++;
            }
            if (aForceAdd) {
                elmt.checked = true;
            } else if (! elmt.checked) {
                continue;
            }

            var result = null;
            if (elmt.name == "sauthusercbx") {
                var sat = aForm.sauthtext;
                result = sat.length ? sat[cntAuthor].value : sat.value;
                if (result == "") {
                    aForm.sauthusercbx.checked = false;
                }
            } else {
                result = elmt.value;
            }
            if (result != "") {
                aAuthorArray[aAuthorArray.length] = result;
            }
        }
        else if ((elmt.name == "keyword") ||
            (elmt.name == "keyusercbx"))
        {
            if (elmt.name == "keyusercbx") {
                cntKeyword++;
            }
            if (aForceAdd) {
                elmt.checked = true;
            } else if (! elmt.checked) {
                continue;
            }

            var result = null;
            if (elmt.name == "keyusercbx") {
                var kwt = aForm.keytext;
                result = kwt.length ? kwt[cntKeyword].value : kwt.value;
                if (result == "") {
                    aForm.keyusercbx.checked = false;
                }
            } else {
                result = elmt.value;
            }
            if (result != "") {
                aKeywordArray[aKeywordArray.length] = result;
            }
        }
    }
    // when there is no selection, add them all
    if ((! aForceAdd) && (aAuthorArray.length==0 && aKeywordArray.length==0)) {
        getAuthorsAndKeywords(aForm, aAuthorArray, aKeywordArray, true);
    }
}

function encodeLinkOutUrl(aUrl)
{
    var result = "";
    for (var i=0; i<aUrl.length; i++) {
        var encoded = aUrl.charAt(i);
        switch (encoded) {
            case '?':
            case '&':	encoded = escape(encoded);	break;
            default:	// does nothing
        }
        result += encoded;
    }
    return result;
}

function showExternalSearch(aDbId, aUrl)
{
    popupHelp("/servlet/linkout?type=search&dbid="+aDbId+"&url="+encodeLinkOutUrl(aUrl));
}

// pubmed url format:
// http://www.ncbi.nlm.nih.gov/entrez/query.fcgi
//   ?dopt=DocSum&cmd=Search&db=PubMed
//   &term=Bhatnagar[AU]+OR+Bagchi[AU]
//
function showPubMedSearch(aAuthors, aKeywords)
{
    var pmurl = "http://www.ncbi.nlm.nih.gov/pubmed/";
    if ((aAuthors.length>0) || (aKeywords.length>0))
    {
        pmurl = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?dopt=DocSum&cmd=Search&db=PubMed&term=";

        for (var i=0; i<aAuthors.length; i++) {
            pmurl += aAuthors[i].replace(",","+");
            pmurl += "[AU]";
            if (i < aAuthors.length-1) {
                pmurl += "+OR+";
            }
        }

        if ((aAuthors.length>0) && (aKeywords.length>0)) {
            pmurl += "+OR+";
        }

        for (var i=0; i<aKeywords.length; i++) {
            pmurl += aKeywords[i].replace(":"," ");
            if (i < aKeywords.length-1) {
                pmurl += "+OR+";
            }
        }
    }
    showExternalSearch(8, pmurl);
}

// ads url format:
// http://adsabs.harvard.edu/cgi-bin/nph-abs_connect?db_key=AST
//	&sort=SCORE&ttl_syn=YES&version=1
//	&txt_syn=YES&txt_logic=AND&text=galaxy%0D%0Astar%0D%0Aocean
//	&aut_syn=YES&aut_logic=AND&&author=&author=jack%0D%0Asmith
function showAdsSearch(aAuthors, aKeywords)
{
    var adsurl = "http://adsabs.harvard.edu/abstract_service.html";
    if ((aAuthors.length>0) || (aKeywords.length>0))
    {
        adsurl =
            "http://adsabs.harvard.edu/cgi-bin/nph-abs_connect?db_key=AST" +
                "&sort=SCORE&ttl_syn=YES&version=1" +
                "&txt_syn=YES&txt_logic=AND" +
                "&aut_syn=YES&aut_logic=AND";

        if (aAuthors.length > 0) {
            adsurl += "&author=";
            for (var i=0; i<aAuthors.length; i++) {
                adsurl += aAuthors[i].replace(",","%2C");
                if (i < aAuthors.length-1) {
                    adsurl += "%0D%0A";
                }
            }
        }
        if (aKeywords.length > 0) {
            adsurl += "&text=";
            for (var i=0; i<aKeywords.length; i++) {
                adsurl += aKeywords[i];
                if (i < aKeywords.length-1) {
                    adsurl += "%0D%0A";
                }
            }
        }
    }
    showExternalSearch(64, adsurl);
}

// xrs url format:
// http://www.google.com/cobrand?restrict=crossref&sa=Search+
//	&q=%22stem+cell%22+%22type+1%22&cof=AWPID:bbd6d01e9a530922
function showCrossRefSearch(aAuthors, aKeywords)
{
    var xrsurl = "http://www.google.com/cobrand?restrict=crossref&sa=Search+&filter=0&q=";
    if ((aAuthors.length>0) || (aKeywords.length>0))
    {
        var array = [aAuthors, aKeywords];
        for (var i=0; i<array.length; i++) {
            for (var j=0; j<array[i].length; j++) {
                xrsurl += "%22"+array[i][j]+"%22+";
            }
        }
    }
    xrsurl += "&cof=AWPID:bbd6d01e9a530922";
    showExternalSearch(16, xrsurl);
}

/**	crossref search */
function submitXrsSearch(frm)
{
    if (! frm) {
        frm = document.forms['frmSearch'];
    }
    var xrsurl = "http://www.google.com/cobrand?" +
        "restrict=" + frm.restrict.value +
        "&q=" + frm.searchText.value +
        "&filter=0" +
        "&sa=Search+" +
        "&cof=AWPID:bbd6d01e9a530922";

    var url = "/servlet/linkout?type=search&dbid=16&url="+encodeLinkOutUrl(xrsurl);
    var winprops = "width=750,height=700,top=10,left=20,toolbar=1,menubar=1,resizable=yes,scrollbars=yes,status=yes";
    var win = window.open(url, null, winprops);
    if (win != null) {
        win.focus();
    }
    return false;
}

var search_highlight = true;
function highlight()
{
    var from = search_highlight ? "single_highlight_class searchToken" : "searchNone";
    var to   = search_highlight ? "searchNone" : "single_highlight_class searchToken";
    var elmts = document.getElementsByTagName("span");
    for (var i=0; i<elmts.length; i++){
        var node = elmts.item(i);
        for (var j=0; j<node.attributes.length; j++) {
            var item = node.attributes.item(j);
            if ((item.nodeName == 'class') &&
                (item.nodeValue.indexOf(from) == 0)) {
                node.className = to + item.nodeValue.substring(from.length);
            }
        }
    }
    search_highlight = ! search_highlight;
}
var emailRegx = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
function isEmail(email) {
    if (email.value) email = email.value;   // is form field
    return emailRegx.test(email);
}
function countSelected(select) {
    var result = 0;
    if (select.options) for (var i = 0; i < select.options.length; i++) if (select.options[i].selected) result++;
    return result;
}
function countChecked(form, fieldName) {
    var result = 0;
    var items = form.elements[fieldName];
    if (items) for (var i = 0; i < items.length; i++) if (items[i].checked) result++;
    return result;
}
function getCookie(name) {
    name = name + "=";
    var cookies = document.cookie.split(';');
    for (var i = 0; i < cookies.length; i++) {
        var c = cookies[i];
        while (c.charAt(0) == ' ') c = c.substring(1);// LTrim
        if (c.indexOf(name) == 0) return c.substring(name.length);
    }
    return null;
}
function syncSession(sid, atcookie) {
    if (sid) {
        var url = location.host;
        url = url.indexOf("staging.") == 0 ? url.substring(8) : ("staging." + url);
        url = "http://" + url + "/session.jsp" + "?JSESSIONID=" + sid;
        if (atcookie) url += "&atcookie=" + atcookie;
        window._sidImg = new Image;
        window._sidImg.src = url;
    }
}

function confirmAction(url, msg) {
    if (confirm(msg)) document.location = url;
}

function msword2html(str)
{
    if (str == null || str.replace(/\s/g, "") == "") {
        return str;
    }
    var array = [
        8211,   "&ndash;",
        8212,   "&mdash;",
        8216,   "&lsquo;",
        8217,   "&rsquo;",
        8218,   "&sbquo;",
        8219,   "&#x201b;",
        8220,   "&ldquo;",
        8221,   "&rdquo;",
        8222,   "&bdquo;",
        8223,   "&#x201f;"
    ];
    for (var i=0; i<array.length; i+=2) {
        str = str.replace(new RegExp(String.fromCharCode(array[i]),"g"),array[i+1]);
    }
    return str;
}
function addFlashMovie(id, flv) {
    var flashvars = {file: flv ,type: 'flv'};
    var params = {allowfullscreen :false};
    var attributes = {};
    swfobject.embedSWF('/flvplayer.swf', id, "352", "288", "7.0.0", false, flashvars, params, attributes);
}

/**
 * Retrieves the input element <code>inputName</code>
 * from the form named <code>formName</code> in the
 * current document. Works in all browsers.
 * @param formName
 * @param inputName
 */
function getFormInput(formName, inputName)
{
    var form=getForm(formName);

    for(var i=0; i < form.elements.length; i++) {
        if(form.elements[i].name == inputName)
            return form.elements[i];
    }

    return null;
}

function searchResultPage(aForm, page, aSubject)
{
    getFormInput(aForm.name, 'startPage').value= page;
    filterBySimilarArticles(aForm, null);
}

function filterBySimilarArticles(searchForm, doi) {
    // nothing
}
/**	function to show next search page */
function searchNextResultPage(aForm, aOffset)
{
    var startPage=null;

    for(var i=0; i < aForm.elements.length; i++) {
        if(aForm.elements[i].name == 'startPage') {
            startPage=aForm.elements[i];
            break;
        }
    }

    if(startPage != null) {
        startPage.value = eval(startPage.value) + aOffset;
        aForm.submit();
    }
}


function searchWithButtona(aPageOffset,button)
{   var form = document.forms.searchForm;
    var page = eval(form.startPage.value) + aPageOffset;
    form.startPage.value = page;
    form.nextPrev.value = "yes";
    submitFormWithButtonClicked(form, button);
}

/**
 *	simulate a mouse event on clicking speicfied button
 *	and then call the form to automatically submit.
 *	@param	aFrom	form to be submitted.
 *	@param	aButton	button to be simulated being clicked.
 */
function submitFormWithButtonClicked(aForm, aButton)
{
    if (document.all && document.all[aButton])
    {
        var x = document.all[aButton];
        if (x.length)
            x = x[0];
        x.click();
    }
    else
    {
        var x = aForm.action;
        if ((x.type==null) || (x.type.indexOf("select")==-1))
        {
            x += ((x.indexOf("?") > 0) ? "&" : "?");
            x += (aButton + ".x=1");
            aForm.action = x;
        }
        else
        {
            var sltd = x.options[x.selectedIndex];
            var pfxJSBTN = "jsbtn:";
            if (sltd.value.indexOf(pfxJSBTN) == -1)
            {
                var value = (pfxJSBTN + aButton + ";" + sltd.value);
                //x.options[x.selectedIndex] = new Option(sltd.text, value, true, true);
                x.options[x.selectedIndex].value = value;
            }
        }
        aForm.submit();
    }
}

function searchResultPageByFormId(aForm, page, aSubject) {
    getFormIdInput(aForm.id, 'startPage').value= page;
    aForm.submit();
}

function getFormIdInput(formId, inputName) {
    var form=getFormById(formId);

    for(var i=0; i < form.elements.length; i++) {
        if(form.elements[i].name == inputName) return form.elements[i];
    }

    return null;
}

function getFormById(id) {
    for(var i=0; i < document.forms.length; i++) {
        if(document.forms[i].id == id) return document.forms[i];
    }

    return null;
}
/**
 * Retrieves the form with <code>name</code>
 * from the current document. Works in all browsers.
 * @param name
 */
function getForm(name) {
    for (var i = 0; i < document.forms.length; i++) {
        if (document.forms[i].name == name)
            return document.forms[i];
    }

    return null;
}
//sets input in form and submits it
function setInputAndSubmit(aForm, aField, aValue)
{
    setInput(aForm, aField, aValue);
    aForm.submit();
}

// set an input's value in given form
function setInput(aForm, aField, aValue)
{
    var input = aForm[aField];
    if (typeof input == 'undefined' || input == null) {
        input = document.createElement("input");
        input.type = "hidden";
        input.name = aField;
        aForm.appendChild(input);
    }
    if (typeof input.length != 'undefined') {
        var i;
        for (i = 0; i < input.length; i++) {
            input[i].value = aValue;
        }
    } else {
        input.value = aValue;
    }
}

function validateRecommendationForm(form, alert1, alert2) {
    if (!isEmail(form.mailToAddress)) {
        alert(alert1);
        return false;
    } else if (form.doi.type != 'hidden' && countSelected(form.doi) < 1) {
        alert(alert2);
        return false;
    }
    return true;
}

function commentSearchResultPage(i) {
    var f = document.forms.commentSearch;
    f.startRow.value = i;
    f.submit();
}
function editAdLabel(anchor){
    anchor.parentNode.parentNode.getElementsByTagName("form")[0].style.display = "block";
}

/*
function deleteAdLabel(anchor) {
    if (confirm("Are you sure you want to delete this placeholder?")) {
        var xmlhttp;
        if (window.XMLHttpRequest)
        {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp=new XMLHttpRequest();
            var description = anchor.parentNode.parentNode.getElementsByTagName("form")[0].elements["name"].value;
            xmlhttp.open("GET","/action/adminPlaceholderManager?action=removePlaceholder&name=" + description, false);
            xmlhttp.send();
            var obj = eval ("(" + xmlhttp.responseText + ")");
            if (obj.display == "confirm") {
                if (obj.code == 1) {
                    if (confirm(obj.msg)) {
                        xmlhttp=new XMLHttpRequest();
                        var description = anchor.parentNode.parentNode.getElementsByTagName("form")[0].elements["name"].value;

                        xmlhttp.open("GET","/action/adminPlaceholderManager?action=removePlaceholder&removeAds=true&name=" + description, false);
                        xmlhttp.send();
                    }
                }
            }
            if (obj.display == "alert") {
                alert(obj.msg);
            }
        }
        else
        {// code for IE6, IE5
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
        document.location.reload(true);
    }
}
*/

function checkUploadedFile(fileId){
    if(document.getElementById(fileId).value.length != 0)
        return true;

    alert('Please Choose a File');
    return false;
}

if (typeof jQuery != 'undefined') {
    jQuery(document).ready(function() {
        jQuery(".includeDebug").hover(function() {
            jQuery(this).stop(true, true);
            jQuery(this).children(".debugInfo").show();
            jQuery(this).addClass("debugBox");
        }, function() {
            jQuery(this).stop(true, true);
            jQuery(this).children(".debugInfo").hide();
            jQuery(this).removeClass("debugBox");
        });

        jQuery(".includeDebug .debugInfo").click(function() {
            jQuery(this).parent().children(".debugAttr").fadeToggle("fast");
            jQuery(this).parent().children(".debugAttr").children(".debugTable").fadeIn("fast");
        });

        jQuery(".includeDebug").bind("mouseenter", function() {
            jQuery(this).removeClass("debugNoF");
        });

        jQuery(".debugError .debugPE").click(function() {
            jQuery(this).parent().children(".debugST").fadeToggle("fast");
        });


        jQuery(".debugTable").click(function() {
            jQuery(this).fadeOut("fast");
        });

        jQuery('.relatedLink').click(function(event) {
            var layer = jQuery(this).next('.relatedLayer');
            if (layer.css('display') == 'none') layer.show();
            else layer.hide();
            event.preventDefault();
        });
    });

    function replace_param(theURL, paramName, newValue) {
        var uri_array = theURL.split('?');
        var params_array = uri_array[1].split('&');
        var items_array = new Array;
        for (i=0; i<params_array.length; i++) {
            items_array = params_array[i].split('=');
            if (items_array[0] == paramName) {
                params_array[i] = items_array[0] + '=' + newValue;
            }
        }
        return uri_array[0] + '?' + params_array.join('&');
    }
}

function checkQuickSearchInput(aForm, quickSearch) {
    if (aForm.elements["AllField"].value == quickSearch) {
        //alert("Please enter search terms");
        var url = "/action/doSearch";
        window.location = url;
    } else {
        aForm.submit();
    }
}

function resizePopup(imagePath){
    var img = new Image();
    img.src = imagePath;
    img.onload = function() {
        var popupWidth = this.width;
        var popupHeight = this.height;
        if(popupWidth>980)
            popupWidth = 980;
        resizeTo(popupWidth,popupHeight);
    }
}