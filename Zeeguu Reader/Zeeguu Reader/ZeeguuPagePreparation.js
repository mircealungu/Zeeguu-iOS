//
//  ZeeguuPagePreparation.js
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

function setupZeeguuJS() {
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

		var dot = /[\.\?!]/g;

		var newText = zgjq(el).text().replace(word, "<" + zeeguuWordTagName + ">$1</" + zeeguuWordTagName + ">");
		newText = newText.replace(dot, function (x) {
			return "<" + zeeguuPeriodTagName + " id=\"" + zeeguuPeriodID + zeeguuPeriodCounter++ + "\">" + x + "</" + zeeguuPeriodTagName + ">";
		});
		zgjq(el).html(newText);
	});
}

function encloseElementsInSentence(elements) {
	if (elements.length > 0) {
		var sentence = document.createElement(zeeguuSentenceTagName);
		var first = elements[0];
		first.parentNode.insertBefore(sentence, first);

		elements.forEach(function (el) {
			sentence.appendChild(el);
		});
		return sentence;
	}
	return null;
}

function removeElementsFromSentence(sentence) {
	var children = Array.prototype.slice.call(sentence.childNodes);
	children.forEach(function (el) {
		sentence.parentNode.insertBefore(el, sentence);
	});
	sentence.parentNode.removeChild(sentence);
}

function addClickListeners() {
	var words = Array.prototype.slice.call(document.querySelectorAll(zeeguuWordTagName));
	words.forEach(function (el) {
		el.addEventListener("click", wordClickHandler);
	})
}

function walkElementsStartingWith(element, directionIsPrevious, callback) {
	var siblingProperty = directionIsPrevious ? "previousSibling" : "nextSibling";

	var text = "";
	var siblingElement = element[siblingProperty];
	while (siblingElement != null) {
		var currentElement = siblingElement;
		siblingElement = siblingElement[siblingProperty];

		if (callback != null) {
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

function enterParagraphOutSideCurrent(el, directionIsPrevious) {
	var siblingProperty = directionIsPrevious ? "previousSibling" : "nextSibling";
	var firstLastChildOfParagraph = directionIsPrevious ? "firstChild" : "lastChild";
	var firstLastChildOfLink = directionIsPrevious ? "lastChild" : "firstChild";

	var parentSibling = null;
	var isInside = false;
	if (isWalkThroughElement(el.parentNode.parentNode)) { // The parent of el (zeeguuParagraph) has a parent that is in the walkthrough list (such as 'a')
		isInside = true;
		parentSibling = el.parentNode.parentNode[siblingProperty];
	} else {
		parentSibling = el.parentNode[siblingProperty];
	}

	if (parentSibling == null) {
		return null;
	}

	if (el == el.parentNode[firstLastChildOfParagraph] && parentSibling.nodeType != 3 /* is not a text node */ && isWalkThroughElement(parentSibling)) { // There is a link (or bold, etc.) next to the parent
		// Assume that each 'a' element has a zeeguu paragraph as first child
		var zeeguuParagraph = el.parentNode[siblingProperty].firstChild;
		return zeeguuParagraph[firstLastChildOfLink];
	} else if (isInside && el == el.parentNode[firstLastChildOfParagraph] && parentSibling.nodeType != 3 /* is not a text node */ && parentSibling.tagName.toLowerCase() == zeeguuParagraphTagName.toLowerCase()) { // We are in a link (or bold, etc.) and want to continue in the adjoining zeeguuParagraph
		return parentSibling[firstLastChildOfLink];
	}
	return null;
}

function insertElementAfter(newElement, afterElement) {
	afterElement.parentNode.insertBefore(newElement, afterElement.nextSibling);
}

setupZeeguuJS();

