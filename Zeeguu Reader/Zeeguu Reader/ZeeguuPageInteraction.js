//
//  ZeeguuPageInteraction.js
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

///************************************************* Get Nodes under selection... *************************************************/
//function getSelectionHtml() {
//	var range = window.getSelection().getRangeAt(0);
//	var content = range.cloneContents();
////    $('body').append('<span id="selection_html_placeholder"></span>');
////    var placeholder = document.getElementById('selection_html_placeholder');
////    placeholder.appendChild(content);
//	var htmlContent = range.commonAncestorContainer;
////    var htmlContent = placeholder.innerHTML;
////    $('#selection_html_placeholder').remove();
//	return htmlContent;
//}
///*********************************************************************************************************************************/