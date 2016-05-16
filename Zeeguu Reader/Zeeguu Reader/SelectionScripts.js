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

var zeeguuIDCounter = 0;
var zeeguuPeriodCounter = 0;

var zeeguuParagraphTagName = "zeeguuParagraph";
var zeeguuWordTagName = "zeeguuWord";
var zeeguuTranslatedWordTagName = "zeeguuTranslatedWord";

var zeeguuPeriodTagName = "zeeguuPeriod";
var zeeguuPeriodID = "zeeguuPeriod";

var zeeguuuTranslatedWordID = "zeeguuTranslatedWord";
var zeeguuuTranslationID = "zeeguuTranslation";

var zeeguuTranslatesImmediately = true;
var zeeguuLinksAreDisabled = false;

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

function wordClickHandler(event) {
	if (event.target.hasAttribute("id")) {
		return; // Already translated
	}
	var word = event.target.innerText;
	var id = zeeguuuTranslatedWordID + zeeguuIDCounter++;

	event.target.setAttribute("id", id);

	var context = getContextOfClickedWord(id);

	var message = {action: "translate", word: word, context: context, id: id};

	window.webkit.messageHandlers.zeeguu.postMessage(message);
}

function getContextOfClickedWord(wordID) {
	var el = document.getElementById(wordID);

	var text = zgjq(el).text();

	var prev = el;
	while (prev.previousSibling != null) {
		var p = prev.previousSibling;
		prev = prev.previousSibling;
		if (p.tagName && p.tagName.toLowerCase() == zeeguuPeriodTagName.toLowerCase()) {
			break;
		}
		if (p.tagName && p.tagName.toLowerCase() == zeeguuTranslatedWordTagName.toLowerCase()) {
			continue;
		}
		text = zgjq(p).text() + text;
	}

	var next = el;
	while (next.nextSibling != null) {
		var n = next.nextSibling;
		next = next.nextSibling;
		if (n.tagName && n.tagName.toLowerCase() == zeeguuTranslatedWordTagName.toLowerCase()) {
			continue;
		}
		text = text + zgjq(n).text();
		if (n.tagName && n.tagName.toLowerCase() == zeeguuPeriodTagName.toLowerCase()) {
			break;
		}
	}
	return text.trim();
}

function translationClickHandler(event) {
	var word = event.target.getAttribute("data-zeeguu-translation");
	var originalWordID = event.target.getAttribute("data-zeeguu-original-word-id");
	var wordElement = document.getElementById(originalWordID);

	var message = {action: "editTranslation", oldTranslation: word, originalWord: wordElement.innerHTML, id: event.target.getAttribute("id")};

	window.webkit.messageHandlers.zeeguu.postMessage(message);
}

function insertTranslationForID(translation, id) {
	var wordElement = document.getElementById(id);
	var translationElement = document.createElement(zeeguuTranslatedWordTagName);
	translationElement.setAttribute("id", zeeguuuTranslationID + zeeguuIDCounter++);
	translationElement.setAttribute("style", "color: red;");
	translationElement.setAttribute("data-zeeguu-translation", translation);
	translationElement.setAttribute("data-zeeguu-original-word-id", id);
	translationElement.innerHTML = " (" + translation + ")";
	translationElement.addEventListener("click", translationClickHandler);
	insertElementAfter(translationElement, wordElement);
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

setupZeeguuJS();
