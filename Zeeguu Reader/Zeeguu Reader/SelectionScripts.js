//
//  SetViewPort.js
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 03-05-16.
//  Copyright © 2015 Jorrit Oosterhof.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

zgjq = jQuery.noConflict(true);

const ZeeguuTranslateImmediately = 0;
const ZeeguuTranslateWordPair = 1;
const ZeeguuTranslateSentence = 2;

var zeeguuIDCounter = 0;
var zeeguuPeriodCounter = 0;

var zeeguuParagraphTagName = "zeeguuParagraph";
var zeeguuWordTagName = "zeeguuWord";
var zeeguuTranslatedWordTagName = "zeeguuTranslatedWord";

var zeeguuPeriodTagName = "zeeguuPeriod";
var zeeguuPeriodID = "zeeguuPeriod";

var zeeguuuTranslatedWordID = "zeeguuTranslatedWord";
var zeeguuuTranslationID = "zeeguuTranslation";

var zeeguuTranslationMode = ZeeguuTranslateImmediately;
var zeeguuLinksAreDisabled = false;

var zeeguuInlineTextElementsToWalkThrough = ["a", "b", "i", "u"];

function setupZeeguuJS() {
	var myCustomViewport = 'width=device-width';
	var viewportElement = document.querySelector('meta[name=viewport]');
	if (viewportElement) {
		viewportElement.content = myCustomViewport;
	} else {
		viewportElement = document.createElement('meta');
		viewportElement.name = 'viewport';
		viewportElement.content = myCustomViewport;
		document.getElementsByTagName('head')[0].appendChild(viewportElement);
	}

	encloseAllText();
	encloseAllWords();
	addClickListeners()
}

function textNodesUnder(el){
	var n, a=[], walk=document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null, false);
	while(n=walk.nextNode()) a.push(n);
	return a;
}

function wrapNode(textNode, tagName) {
	var wrapper = document.createElement(tagName);
	textNode.parentNode.insertBefore(wrapper, textNode);
	wrapper.appendChild(textNode);
	return wrapper;
}

function encloseAllText() {
	var bodyElements = Array.prototype.slice.call(document.querySelectorAll("body"));
	var noEnter = ["script", "style", "iframe", "canvas"];
	bodyElements.forEach(function (el) {
		var textNodes = textNodesUnder(el);

		textNodes.forEach(function (node) {
			if (node.nodeValue.trim().length == 0) {
				return;
			}
			if (noEnter.indexOf(node.parentNode.nodeName.toLowerCase()) > -1) {
				return;
			}
			wrapNode(node, zeeguuParagraphTagName);
		});

	});
}



function encloseAllWords() {
	var elements = Array.prototype.slice.call(document.querySelectorAll(zeeguuParagraphTagName));
	elements.forEach(function (el) {
		var word = /([a-zA-Z0-9À-ÖØ-öø-ÿĀ-ſƀ-ɏ_-]+)/g;
		// Used https://en.wikipedia.org/wiki/List_of_Unicode_characters#Latin_script to create above regex

		var dot = /\./g;

		var newText = zgjq(el).text().replace(word, "<" + zeeguuWordTagName + ">$1</" + zeeguuWordTagName + ">");
		newText = newText.replace(dot, function (x) {
			return "<" + zeeguuPeriodTagName + " id=\"" + zeeguuPeriodID + zeeguuPeriodCounter++ + "\">" + x + "</" + zeeguuPeriodTagName + ">";
		});
		zgjq(el).html(newText);
		//zgjq(el).html(zgjq(el).text().replace(/(\S+)/g, "<" + zeeguuWordTagName + ">$1</" + zeeguuWordTagName + ">"));
	});
}

function addClickListeners() {
	var words = Array.prototype.slice.call(document.querySelectorAll(zeeguuWordTagName));
	words.forEach(function (el) {
		el.addEventListener("click", wordClickHandler);
	})
}

var zeeguuSelectionFirstWord = null;

function wordClickHandler(event) {
	if (zeeguuTranslationMode == ZeeguuTranslateImmediately && event.target.hasAttribute("id")) {
		return; // Already translated
	}
	var word = event.target.innerText;
	var id = zeeguuuTranslatedWordID + zeeguuIDCounter++;

	event.target.setAttribute("id", id);

	var message = undefined;
	if (zeeguuTranslationMode == ZeeguuTranslateImmediately) {
		var context = getContextOfClickedWord(id);

		message = {action: "translate", word: word, context: context, id: id};

		window.webkit.messageHandlers.zeeguu.postMessage(message);
	} else {
		handleSelection(event.target, id);
	}
}

function handleSelection(tappedNode, tappedNodeID) {
	zgjq(tappedNode).addClass("zeeguuSelection");
	if (zeeguuSelectionFirstWord == null) {
		zeeguuSelectionFirstWord = event.target;
	} else {
		var text = zgjq(tappedNode).text();

		var selectionComplete = false;
		var callback = function (currentElement, directionIsPrevious) {
			if (elementIsTranslation(currentElement)) {
				return "continue";
			}

			if (directionIsPrevious) {
				text = zgjq(currentElement).text() + text;
			} else {
				text = text + zgjq(currentElement).text();
			}

			if (zeeguuTranslationMode == ZeeguuTranslateSentence) {
				zgjq(currentElement).addClass("zeeguuSelection");
			}

			if (currentElement == zeeguuSelectionFirstWord) {
				selectionComplete = true;
				return "break";
			}
		};


		var first = zeeguuSelectionFirstWord;
		var second = tappedNode;
		var comparison = first.compareDocumentPosition(second);

		var rectElement;

		if (comparison & Node.DOCUMENT_POSITION_FOLLOWING) { // second is following first
			walkElementsStartingWith(second, true, callback); // walk from second to the left to first
			rectElement = second;
			if (second.nextSibling && second.nextSibling.nodeType != 3 && second.nextSibling.tagName.toLowerCase() === zeeguuPeriodTagName.toLowerCase()) {
				text = text + ".";
				rectElement = second.nextSibling;
			}
		} else { // assume first is following second, as this is only done for zeeguuWord elements.
			// zeeguuWord elements should not be contained by other zeeguuWord elements
			walkElementsStartingWith(second, false, callback); // walk from second to the right to first
			rectElement = first;
			if (first.nextSibling && second.nextSibling.nodeType != 3 && first.nextSibling.tagName.toLowerCase() === zeeguuPeriodTagName.toLowerCase()) {
				text = text + ".";
				rectElement = first.nextSibling;
			}
		}

		var context = text;
		context = getContextNextTo(zeeguuSelectionFirstWord, true) + context;
		context = context + getContextNextTo(tappedNode, false);

		if (zeeguuTranslationMode == ZeeguuTranslateWordPair) {
			if (comparison & Node.DOCUMENT_POSITION_FOLLOWING) { // second is following first
				text = zgjq(zeeguuSelectionFirstWord).text() + ' ' + zgjq(tappedNode).text();
			} else { // assume first is following second, as this is only done for zeeguuWord elements.
				// zeeguuWord elements should not be contained by other zeeguuWord elements
				text = zgjq(tappedNode).text() + ' ' + zgjq(zeeguuSelectionFirstWord).text();
			}
		}

		var rect;
		if (zeeguuTranslationMode == ZeeguuTranslateSentence) {
			rect = rectElement.getBoundingClientRect();
		} else {
			rect = tappedNode.getBoundingClientRect();
		}
		var message = {action: "translate", word: text, context: context, id: rectElement.getAttribute("id"), selectionComplete: selectionComplete, top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right, width: rect.width, height: rect.height};

		window.webkit.messageHandlers.zeeguu.postMessage(message);

		zeeguuSelectionFirstWord = null;
	}
}

function elementIsPeriod(el) {
	return el.tagName && el.tagName.toLowerCase() == zeeguuPeriodTagName.toLowerCase();
}

function elementIsTranslation(el) {
	return el.tagName && el.tagName.toLowerCase() == zeeguuTranslatedWordTagName.toLowerCase();
}

function enterParagraphOutSideCurrent(el, directionIsPrevious) {
	var siblingProperty = directionIsPrevious ? "previousSibling" : "nextSibling";
	var firstLastChildOfParagraph = directionIsPrevious ? "firstChild" : "lastChild";
	var firstLastChildOfLink = directionIsPrevious ? "lastChild" : "firstChild";

	var parentSibling = null;
	var isInside = false;
	if (zeeguuInlineTextElementsToWalkThrough.indexOf(el.parentNode.parentNode.tagName.toLowerCase()) != -1) { // The parent of el (zeeguuParagraph) has a parent that is in the walkthrough list (such as 'a')
		isInside = true;
		parentSibling = el.parentNode.parentNode[siblingProperty];
	} else {
		parentSibling = el.parentNode[siblingProperty];
	}

	if (parentSibling == null || parentSibling == undefined) {
		return null;
	}

	if (el == el.parentNode[firstLastChildOfParagraph] && parentSibling.nodeType != 3 /* is not a text node */ && zeeguuInlineTextElementsToWalkThrough.indexOf(parentSibling.tagName.toLowerCase()) != -1) { // There is a link (or bold, etc.) next to the parent
		// Assume that each 'a' element has a zeeguu paragraph as first child
		var zeeguuParagraph = el.parentNode[siblingProperty].firstChild;
		return zeeguuParagraph[firstLastChildOfLink];
	} else if (isInside && el == el.parentNode[firstLastChildOfParagraph] && parentSibling.nodeType != 3 /* is not a text node */ && parentSibling.tagName.toLowerCase() == zeeguuParagraphTagName.toLowerCase()) { // We are in a link (or bold, etc.) and want to continue in the adjoining zeeguuParagraph
		return parentSibling[firstLastChildOfLink];
	}
	return null;
}

function walkElementsStartingWith(element, directionIsPrevious, callback) {
	var siblingProperty = directionIsPrevious ? "previousSibling" : "nextSibling";

	var text = "";
	var siblingElement = element[siblingProperty];
	while (siblingElement != null) {
		var currentElement = siblingElement;
		siblingElement = siblingElement[siblingProperty];

		if (callback != undefined && callback != null) {
			var str = callback(currentElement, directionIsPrevious);
			if (str === "continue") continue;
			if (str === "break") break;
		}

		if (siblingElement == null) {
			siblingElement = enterParagraphOutSideCurrent(currentElement, directionIsPrevious);
		}
	}
	return text;
}

function getContextNextTo(element, directionIsPrevious) {
	var text = "";

	walkElementsStartingWith(element, directionIsPrevious, function (currentElement, directionIsPrevious) {
		if (elementIsTranslation(currentElement)) {
			return "continue";
		}

		if (!directionIsPrevious) {
			text = text + zgjq(currentElement).text();
		}

		if (elementIsPeriod(currentElement)) {
			return "break";
		}

		if (directionIsPrevious) {
			text = zgjq(currentElement).text() + text;
		}
	});

	return text;
}

function getContextOfClickedWord(wordID) {
	var el = document.getElementById(wordID);

	var text = zgjq(el).text();

	text = getContextNextTo(el, true) + text;
	text = text + getContextNextTo(el, false);

	return text.trim();
}

function translationClickHandler(event) {
	var word = event.target.getAttribute("data-zeeguu-translation");
	var originalWordID = event.target.getAttribute("data-zeeguu-original-word-id");
	var bookmarkID = event.target.getAttribute("data-zeeguu-bookmark-id");
	var wordElement = document.getElementById(originalWordID);

	var rect = event.target.getBoundingClientRect();
	var message = {action: "editTranslation", oldTranslation: word, originalWord: wordElement.innerHTML, id: event.target.getAttribute("id"), bookmarkID: bookmarkID, top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right, width: rect.width, height: rect.height};

	window.webkit.messageHandlers.zeeguu.postMessage(message);
}

function insertTranslationForID(translation, id, bid) {
	var wordElement = document.getElementById(id);
	var translationElement = document.createElement(zeeguuTranslatedWordTagName);
	translationElement.setAttribute("id", zeeguuuTranslationID + zeeguuIDCounter++);
	translationElement.setAttribute("style", "color: red;");
	translationElement.setAttribute("data-zeeguu-translation", translation);
	translationElement.setAttribute("data-zeeguu-original-word-id", id);
	translationElement.setAttribute("data-zeeguu-bookmark-id", bid);
	translationElement.innerHTML = " (" + translation + ")";
	translationElement.addEventListener("click", translationClickHandler);
	insertElementAfter(translationElement, wordElement);
	removeSelectionHighlights();
}

function removeSelectionHighlights() {
	zgjq(".zeeguuSelection").removeClass("zeeguuSelection");
}

function updateTranslationForID(translation, id) {
	var translationElement = document.getElementById(id);
	translationElement.innerHTML = " (" + translation + ")";
}

function zeeguuUpdateLinkState() {
	var func = function (idx, el) {
		var attrToAdd = zeeguuLinksAreDisabled ? "data-zeeguu-href" : "href";
		var attrToRemove = zeeguuLinksAreDisabled ? "href" : "data-zeeguu-href";

		zgjq(el).attr(attrToAdd, zgjq(el).attr(attrToRemove));
		zgjq(el).removeAttr(attrToRemove);
	};

	zgjq("a").each(func);
}

function insertElementAfter(newElement, afterElement) {
	afterElement.parentNode.insertBefore(newElement, afterElement.nextSibling);
}

document.body.style.webkitTouchCallout='none';
document.body.style.KhtmlUserSelect='none';

setupZeeguuJS();
/************************************************* Get Nodes under selection... *************************************************/
function getSelectionHtml() {
	var range = window.getSelection().getRangeAt(0);
	var content = range.cloneContents();
//    $('body').append('<span id="selection_html_placeholder"></span>');
//    var placeholder = document.getElementById('selection_html_placeholder');
//    placeholder.appendChild(content);
	var htmlContent = range.commonAncestorContainer;
//    var htmlContent = placeholder.innerHTML;
//    $('#selection_html_placeholder').remove();
	return htmlContent;
}
/*********************************************************************************************************************************/