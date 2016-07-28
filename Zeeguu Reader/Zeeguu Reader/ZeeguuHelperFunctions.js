//
//  ZeeguuHelperFunctions.js
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

function getPeriodAfterElement(el, hasPeriodFunction) {
	var els = [];
	while (el.nextSibling && (elementIsTranslation(el.nextSibling) || elementIsPronounceIcon(el.nextSibling))) {
		el = el.nextSibling;
		els.push(el);
	}
	if (el.nextSibling && el.nextSibling.nodeType != 3 && el.nextSibling.tagName.toLowerCase() === zeeguuPeriodTagName.toLowerCase()) {
		if (hasPeriodFunction != null) {
			hasPeriodFunction();
		}
		els.push(el.nextSibling);
		return els;
	}
	return [el];
}

function fuseWordPair(first, second, secondFollowsFirst) {
	if (secondFollowsFirst) {
		return zgjq(first).text() + ' ' + zgjq(second).text();
	}
	return zgjq(second).text() + ' ' + zgjq(first).text();
}

function elementIsPeriod(el) {
	return el.tagName && el.tagName.toLowerCase() == zeeguuPeriodTagName.toLowerCase();
}

function elementIsTranslation(el) {
	return el.tagName && el.tagName.toLowerCase() == zeeguuTranslatedWordTagName.toLowerCase();
}

function elementIsPronounceIcon(el) {
	return el.tagName && el.tagName.toLowerCase() == zeeguuPronounceTagName.toLowerCase();
}

function elementIsInLink(el) {
	return el.parentNode && el.parentNode.parentNode && el.parentNode.parentNode.tagName && el.parentNode.parentNode.tagName.toLowerCase() == "a";
}

function getContextNextTo(element, directionIsPrevious) {
	var text = "";

	walkElementsStartingWith(element, directionIsPrevious, function (currentElement, directionIsPrevious) {
		if (elementIsTranslation(currentElement) || elementIsPronounceIcon(currentElement)) {
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

function getContextOfSelection(first, second, secondFollowsFirst, textInBetween) {
	var contextOfFirst = getContextNextTo(first, secondFollowsFirst);
	var contextOfSecond = getContextNextTo(second, !secondFollowsFirst);
	if (secondFollowsFirst) {
		return contextOfFirst + textInBetween + contextOfSecond;
	}
	return contextOfSecond + textInBetween + contextOfFirst;
}

function isWalkThroughParent(el) {
	return zeeguuInlineTextElementsToWalkThrough.indexOf(el.tagName.toLowerCase()) != -1;
}