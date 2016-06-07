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

function zeeguuPostMessage(message) {
	window.webkit.messageHandlers.zeeguu.postMessage(message);
}

function wordClickHandler(event) {
	if (zeeguuTranslationMode == ZeeguuTranslateImmediately && event.target.hasAttribute("data-zeeguu-translated")) {
		return; // Already translated
	}
	var word = event.target.innerText;
	var id = zeeguuuTranslatedWordID + zeeguuIDCounter++;

	event.target.setAttribute("id", id);

	if (zeeguuTranslationMode == ZeeguuTranslateImmediately) {
		var context = getContextOfClickedWord(id);
		var message = {action: "translate", word: word, context: context, id: id};
		zeeguuPostMessage(message);
		event.target.setAttribute("data-zeeguu-translated", "translated");
	} else {
		handleSelection(event.target);
	}
}

function handleSelection(tappedNode) {
	zgjq(tappedNode).addClass("zeeguuSelection");
	if (zeeguuSelectionFirstWord == null) {
		zeeguuSelectionFirstWord = event.target;
	} else {
		var first = zeeguuSelectionFirstWord;
		var second = tappedNode;
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

			if (currentElement == first) {
				selectionComplete = true;
				return "break";
			}
		};

		var comparison = first.compareDocumentPosition(second);
		// second is following first
		// If this is false, assume first is following second, as this check is only done for zeeguuWord elements
		// and zeeguuWord elements should not be contained by other zeeguuWord elements.
		var secondFollowsFirst = comparison & Node.DOCUMENT_POSITION_FOLLOWING ? true : false;

		// if secondFollowsFirst is true, walk from second to the left to first
		// else, walk from second to the right to first
		walkElementsStartingWith(second, secondFollowsFirst, callback);

		if (!selectionComplete) {
			var message = {action: "selectionIncomplete"};
			removeSelectionHighlights();
			zgjq(zeeguuSelectionFirstWord).addClass("zeeguuSelection");
			zeeguuPostMessage(message);
			return;
		}

		var lastElement = getPeriodAfterElement(secondFollowsFirst ? second : first, function () { text += "."; });
		var context = getContextOfSelection(first, second, secondFollowsFirst, text);

		if (zeeguuTranslationMode == ZeeguuTranslateWordPair) {
			text = fuseWordPair(first, second, secondFollowsFirst);
		}

		var rect = tappedNode.getBoundingClientRect();
		var message = {action: "translate", word: text, context: context, id: lastElement.getAttribute("id"), selectionComplete: selectionComplete, top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right, width: rect.width, height: rect.height};

		zeeguuPostMessage(message);

		zeeguuSelectionFirstWord = null;
	}
}

function translationClickHandler(event) {
	var word = event.target.getAttribute("data-zeeguu-translation");
	//var originalWordID = event.target.getAttribute("data-zeeguu-original-word-id");
	var originalWord = event.target.getAttribute("data-zeeguu-original-word");
	var bookmarkID = event.target.getAttribute("data-zeeguu-bookmark-id");
	//var wordElement = document.getElementById(originalWordID);
	var otherTranslations = null;
	if (event.target.hasAttribute("data-zeeguu-other-translations")) {
		otherTranslations = event.target.getAttribute("data-zeeguu-other-translations");
	}
	var originalContext = event.target.getAttribute("data-zeeguu-original-context");

	var rect = event.target.getBoundingClientRect();
	var message = {action: "editTranslation", oldTranslation: word, originalWord: originalWord, originalContext: originalContext, id: event.target.getAttribute("id"), bookmarkID: bookmarkID, top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right, width: rect.width, height: rect.height, otherTranslations: otherTranslations};

	zeeguuPostMessage(message);
}

function insertTranslationForID(translation, originalWord, originalContext, id, bid) {
	var wordElement = document.getElementById(id);
	var translationElement = document.createElement(zeeguuTranslatedWordTagName);
	translationElement.setAttribute("id", zeeguuuTranslationID + zeeguuIDCounter++);
	translationElement.setAttribute("style", "color: red;");
	translationElement.setAttribute("data-zeeguu-translation", translation);
	translationElement.setAttribute("data-zeeguu-original-word-id", id);
	translationElement.setAttribute("data-zeeguu-original-word", originalWord);
	translationElement.setAttribute("data-zeeguu-original-context", originalContext);
	translationElement.setAttribute("data-zeeguu-bookmark-id", bid);
	translationElement.innerHTML = " (" + translation + ")";
	translationElement.addEventListener("click", translationClickHandler);
	insertElementAfter(translationElement, wordElement);
	removeSelectionHighlights();
}

function setTranslationMode(mode) {
	zeeguuTranslationMode = mode;
	removeSelectionHighlights();
	zeeguuSelectionFirstWord = null;
}

function removeSelectionHighlights() {
	zgjq(".zeeguuSelection").removeClass("zeeguuSelection");
}

function updateTranslationForID(translation, id, otherTranslations) {
	var translationElement = document.getElementById(id);
	translationElement.innerHTML = " (" + translation + ")";
	translationElement.setAttribute("data-zeeguu-translation", translation);
	translationElement.setAttribute("data-zeeguu-other-translations", otherTranslations);
}

function deleteTranslationWithID(id) {
	var translationElement = document.getElementById(id);
	translationElement.parentNode.removeChild(translationElement);
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