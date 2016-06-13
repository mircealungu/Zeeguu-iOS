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
		translateSingleWord(word, id);
	} else {
		handleSelection(event.target);
	}
}

function translateSingleWord(word, id) {
	var context = getContextOfClickedWord(id);
	var pronounceID = insertIconAfterID(id);
	var message = {action: "translate", word: word, context: context, id: id, pronounceID: pronounceID};
	zeeguuPostMessage(message);
	if (zeeguuTranslationIsInserted) {
		event.target.setAttribute("data-zeeguu-translated", "translated");
	}
}

function handleSelection(tappedNode) {
	zgjq(tappedNode).addClass("zeeguuSelection", 300);
	if (zeeguuSelectionFirstWord == null) {
		zeeguuSelectionFirstWord = event.target;
	} else {
		var first = zeeguuSelectionFirstWord;
		var second = tappedNode;
		var text = zgjq(tappedNode).text();

		if (first == second) {
			translateSingleWord(text, zeeguuSelectionFirstWord.getAttribute("id"));
			return;
		}

		var selectionComplete = false;
		var elements = [second];
		var callback = function (currentElement, directionIsPrevious) {
			var modeSentence = zeeguuTranslationMode == ZeeguuTranslateSentence;
			if (directionIsPrevious && modeSentence) {
				elements.unshift(currentElement);
			} else if (modeSentence) {
				elements.push(currentElement);
			}
			if (elementIsTranslation(currentElement) || elementIsPronounceIcon(currentElement)) {
				return "continue";
			}
			if (directionIsPrevious) {
				text = zgjq(currentElement).text() + text;
			} else {
				text = text + zgjq(currentElement).text();
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

		var hasPeriodAtEnd = false;
		var lastElements = getPeriodAfterElement(secondFollowsFirst ? second : first, function () { hasPeriodAtEnd = true; });
		if (hasPeriodAtEnd) {
			text += zgjq(lastElements[lastElements.length - 1]).text();
		}
		var context = getContextOfSelection(first, second, secondFollowsFirst, text);

		if (zeeguuTranslationMode == ZeeguuTranslateWordPair) {
			text = fuseWordPair(first, second, secondFollowsFirst);
		}

		var sentence = encloseElementsInSentence(elements);
		for (var i = 0; i != lastElements.length; ++i) {
			sentence.appendChild(lastElements[i]);
		}
		if (zeeguuTranslationMode == ZeeguuTranslateSentence) {
			removeSelectionHighlights();
			zgjq(sentence).addClass("zeeguuSelection", 300);
		}
		var rect = sentence.getBoundingClientRect();

		var lastElID = lastElements[lastElements.length - 1].getAttribute("id");
		var message = {action: "translate", word: text, context: context, id: lastElID, selectionComplete: selectionComplete, top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right, width: rect.width, height: rect.height, pronounceID: -1};

		zeeguuPostMessage(message);

		zeeguuSelectionFirstWord = null;
	}
}

function translationClickHandler(event) {
	var word = event.target.getAttribute("data-zeeguu-translation");
	var originalWord = event.target.getAttribute("data-zeeguu-original-word");
	var bookmarkID = event.target.getAttribute("data-zeeguu-bookmark-id");
	var otherTranslations = null;
	if (event.target.hasAttribute("data-zeeguu-other-translations")) {
		otherTranslations = event.target.getAttribute("data-zeeguu-other-translations");
	}
	var originalContext = event.target.getAttribute("data-zeeguu-original-context");

	var rect = event.target.getBoundingClientRect();
	var message = {action: "editTranslation", oldTranslation: word, originalWord: originalWord, originalContext: originalContext, id: event.target.getAttribute("id"), bookmarkID: bookmarkID, top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right, width: rect.width, height: rect.height, otherTranslations: otherTranslations};

	zeeguuPostMessage(message);
}

function insertIconAfterID(id) {
	var pronounceElement = document.createElement(zeeguuPronounceTagName);
	pronounceElement.setAttribute("id", zeeguuPronounceID + zeeguuIDCounter++);

	var space = document.createTextNode(" ");
	pronounceElement.appendChild(space);

	var image = document.createElement("img");
	image.setAttribute("src", zeeguuLoadingImage);
	image.setAttribute("class", "zeeguu-pronounce-icon");
	pronounceElement.appendChild(image);

	var el = document.getElementById(id);
	insertElementAfter(pronounceElement, el);
	return pronounceElement.getAttribute("id");
}

function updateImageForPronounceIcon(pronounceElement, image) {
	var imageElement = pronounceElement.lastChild;
	imageElement.setAttribute("src", image);
}

/**
 * Insert translation in the text
 * @param translation The translation to insert
 * @param originalWord The original word
 * @param originalContext The original context
 * @param id The id of the translated word
 * @param bid The bookmark id of the translation
 * @param pid The id of the icon element
 */
function insertTranslationForID(translation, originalWord, originalContext, id, bid, pid) {
	var translationElement = document.createElement(zeeguuTranslatedWordTagName);
	translationElement.setAttribute("id", zeeguuuTranslationID + zeeguuIDCounter++);
	translationElement.setAttribute("data-zeeguu-translation", translation);
	translationElement.setAttribute("data-zeeguu-original-word-id", id);
	translationElement.setAttribute("data-zeeguu-original-word", originalWord);
	translationElement.setAttribute("data-zeeguu-original-context", originalContext);
	translationElement.setAttribute("data-zeeguu-bookmark-id", bid);
	translationElement.innerHTML = " (" + translation + ")";
	translationElement.addEventListener("click", translationClickHandler);

	var pronounceElement = document.getElementById(pid);
	updateImageForPronounceIcon(pronounceElement, zeeguuPronounceImage);
	pronounceElement.setAttribute("data-zeeguu-pronounce-word", originalWord);
	translationElement.setAttribute("data-zeeguu-pronounce-icon-id", pronounceElement.getAttribute("id"));


	var sentences = Array.prototype.slice.call(document.getElementsByTagName(zeeguuSentenceTagName));
	sentences.forEach(function (el) {
		removeElementsFromSentence(el);
	});

	insertElementAfter(translationElement, pronounceElement);
	removeSelectionHighlights();

	pronounceElement.addEventListener("click", pronounceClickHandler);
}

function pronounceClickHandler(event) {
	var word = event.target.getAttribute("data-zeeguu-pronounce-word");
	if (event.target.tagName != null && event.target.tagName.toLowerCase() == "img") {
		word = event.target.parentNode.getAttribute("data-zeeguu-pronounce-word");
	}
	var message = {action: "pronounce", word: word};
	zeeguuPostMessage(message);
}

function setTranslationMode(mode) {
	zeeguuTranslationMode = mode;
	removeSelectionHighlights();
	zeeguuSelectionFirstWord = null;
}

function setInsertsTranslation(inserts) {
	zeeguuTranslationIsInserted = inserts;
}


function removeSelectionHighlights() {
	zgjq(".zeeguuSelection").removeClass("zeeguuSelection", 300);
}

function updateTranslationForID(translation, id, otherTranslations) {
	var translationElement = document.getElementById(id);
	translationElement.innerHTML = " (" + translation + ")";
	translationElement.setAttribute("data-zeeguu-translation", translation);
	translationElement.setAttribute("data-zeeguu-other-translations", otherTranslations);
}

function deleteTranslationWithID(id) {
	var translationElement = document.getElementById(id);
	var originalWordID = translationElement.getAttribute("data-zeeguu-original-word-id");
	var pronounceID = translationElement.getAttribute("data-zeeguu-pronounce-icon-id");
	var pronounce = document.getElementById(pronounceID);
	translationElement.parentNode.removeChild(translationElement);
	pronounce.parentNode.removeChild(pronounce);
	document.getElementById(originalWordID).removeAttribute("data-zeeguu-translated");
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