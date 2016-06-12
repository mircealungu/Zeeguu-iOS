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
		if (zeeguuTranslationIsInserted) {
			event.target.setAttribute("data-zeeguu-translated", "translated");
		}
	} else {
		handleSelection(event.target);
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

		var selectionComplete = false;
		var elements = [second];
		var callback = function (currentElement, directionIsPrevious) {
			var modeSentence = zeeguuTranslationMode == ZeeguuTranslateSentence;
			if (directionIsPrevious && modeSentence) {
				elements.unshift(currentElement);
			} else if (modeSentence) {
				elements.push(currentElement);
			}
			if (elementIsTranslation(currentElement)) {
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
		var lastElement = getPeriodAfterElement(secondFollowsFirst ? second : first, function () { hasPeriodAtEnd = true; });
		if (hasPeriodAtEnd) {
			text += zgjq(lastElement).text();
		}
		var context = getContextOfSelection(first, second, secondFollowsFirst, text);

		if (zeeguuTranslationMode == ZeeguuTranslateWordPair) {
			text = fuseWordPair(first, second, secondFollowsFirst);
		}

		var sentence = encloseElementsInSentence(elements);
		sentence.appendChild(lastElement);
		if (zeeguuTranslationMode == ZeeguuTranslateSentence) {
			removeSelectionHighlights();
			zgjq(sentence).addClass("zeeguuSelection", 300);
		}
		var rect = sentence.getBoundingClientRect();

		var message = {action: "translate", word: text, context: context, id: lastElement.getAttribute("id"), selectionComplete: selectionComplete, top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right, width: rect.width, height: rect.height};

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

function insertTranslationForID(translation, originalWord, originalContext, id, bid) {
	var wordElement = document.getElementById(id);
	var translationElement = document.createElement(zeeguuTranslatedWordTagName);
	translationElement.setAttribute("id", zeeguuuTranslationID + zeeguuIDCounter++);
	translationElement.setAttribute("data-zeeguu-translation", translation);
	translationElement.setAttribute("data-zeeguu-original-word-id", id);
	translationElement.setAttribute("data-zeeguu-original-word", originalWord);
	translationElement.setAttribute("data-zeeguu-original-context", originalContext);
	translationElement.setAttribute("data-zeeguu-bookmark-id", bid);
	translationElement.innerHTML = " (" + translation + ")";
	translationElement.addEventListener("click", translationClickHandler);

	var pronounceElement = document.createElement(zeeguuPronounceTagName);
	pronounceElement.setAttribute("id", zeeguuPronounceID + zeeguuIDCounter++);
	translationElement.setAttribute("data-zeeguu-pronounce-icon-id", pronounceElement.getAttribute("id"));
	pronounceElement.setAttribute("data-zeeguu-pronounce-word", originalWord);

	var space = document.createTextNode(" ");
	pronounceElement.appendChild(space);

	var image = document.createElement("img");
	image.setAttribute("src", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAFUdJREFUeAHtnQ2QnlV1x3ez2ZBAvgPhK0BKGUqhnRYBqfIRNMRRO4JKpwNVrP1A26GDIjNNbRlbtDPQTkGZVgvMKBSrVXAGdByFlhShgKCCONJWUGgCEglJIB+EfGx2t7/fee958uy7u5lN8u5mN/uembv33nO/zv2fc8+9z32f992Ojja1EWgj0EagjUAbgTYCbQTaCLQRaCPQRqCNQBuBNgJtBNoItBGYGAh0TgwxRyzlFGo6p35C34hbtSu2HAGVMLWpV/NjYXCO00XQGMZqTIYav5SrIiScOXPmwiZRR0sp9jtc38q0VzRch3vV2X5opGX2Ou68efPeRfQXhEWEX/T391+3YcOGu0lLzlM31iqq+mPcs+n0EsJMwr+/+uqrXyqDVLKV/IiiiawQ3cNOZzl//vwrUcANnZ2dHcQdtfgdr7zyyj1U2Stw7HsYiv5Qxvsp/6LjJTH+TSjlT0velbJHe5kdT0TqRuhQxty5c1XE35RJ7CjxdnjdgDN/27ZtX4bn6tiFWqm0l1EoY/bs2fOnTJlyJ+PMYZztZYwu8qfPmDHjta1bt34X3h67rj1usJeTaGUzldGzaNGiGSjjTkBxdQi4CppGEDDrSEcQ5EmtUkhg1tXVdTJ9HtkYOjbzkMs84e9YPedQrjt1JY+YJpJCBNTJ9SxYsODoLVu23IcyfofJO2ndwqCJY63yW7l30F2jPxTyMumtMqAcQ6XsYFyN4nO40tnEPYQRe6KJohDlNOxkVZza19f3AJN+M8pwsvKHm3CrVgVDVKQBdK5bt+4Zxv8qcliQCjGeplzwf430pyyENIwRyTIRFCLYTrQXN/BOJno/4ZeZtPuFq2JEE6Xe3pL9i1OOoyyBGyv0KuR4EnnCXdXqdMHXdV3BKlkG3zaDVjC8QTTeFeIktMh+JvYh4m8yeTdRleHekCCRbDnZdxpDur5cicrUzQluE6v1j5FH16VS4qBBLK6uEqKOawnKOiLXNZ4VUk0QZbj0byZ0Mnknlhs1yVEhkYxVae9z5syZV0ZREYmZckzduHHj48j08QK+ZbaTpsJXkach/xXBGYEBZeel/riJ0gVMZTK3ItXVTE7htEDLRpNSGR3sV+/GTT6Ea3oCOe4jfx4DC3KuFNMdPIDeiHz3ohTxzFViP1FO2ZW0X1TKduu6xqNCQhmzZs1aAADfZhIfLJamde52MpS3ggJsxr4AgO8inEWniwlLSd+LgsyHyyIW8DAQZFxO2FLylkuuEl3XUcR/1mBFW5U1JI0nhSikgPcceuihvzJ16tQHsMzzmUhaXFrlkBNpEbOycMa+AiDdmF+n717ireR1lTcj3yzicFkZs0p+RPoztimUrks3K+syXN/xxGaGxX3YAnsYQ1IOZ+Kx9rydO3c+wMROYSJu3ipirOQMNA8//PBDGDsvKVWCMkyHp7Wfwkb+t+QlV4JtAnH411PnWepYv1olpG3nk/2HSEuprEau9nesJlobclBS4V36fbiD9yH4vQh+eFGGYFQmN6hl6xnh89esWaPr+UnpPsFTjinIFcdZDOct5C1L8N3gXyX/DwSpUhTpxPlSVteR5B3HdoMoKw4qGCOGLiosCWUsJ/2vhHiwMiaMNQmwMnVg7X8P+M17giD6JO4F5jWkxU+XahzKnDZt2hdp9xTl1k13qyJ74R1FvxfDl1TYINqfCnEzDIFRxj8h7HVFOn3zaJ+kEghBaQZGmbqw9h8A4tXIZV3/5Erx0lJwz2GV/L6FkOVh9WV13RTcxiqwXb3975FX6anIUrUR7S+FxEnKzRFl3M3kLmeSCu5qGQtlCJCgGEv1tPkAn436M1j0fyBfrgTLKnDhX+V+A0+5rRP9sQd+lek819zOKRJO5wj8VupKg9zW7hRimeC0MuiGDD1Y13EIvgKhL0RIJyQIgwSE12pKJWihWrXjmjbOMvnhurhE/Cvk83AhDuFeib0a6UP2U3bs2HEpeSldVNfmzZvXkb8juA1F2bd47qSNSrmolDlujhms4RRi5wql+2hlcGI7uK19I4J5rD0D4exfoYaThaKWUAJu3M8RVEv9JCv0WoxjSRkh65gV/M7169d/H1n/WSAhMZHMZPoy0mFkxM4h5sG8XCUemRNL29i/dD4fNR9GbH6AEcYo1qiRHTpYF0KfiiCHEHLwWrU9SyLcFKxta29v78n092nCXHhpeUPJsWcDDKytJWrhj3Pf9CZilZ4K9zT3fvK3USfAQA436auoewP8lEWw7GOnzw8Yz2PUOZS6WrV8MUnw34t7u4u8q8ixghjHp/e3DdPmQtp8g4oxRmnSWJaZIVbAXizHZwDvjt5IyImQDGFTy/V8XftDphGsE3/sMlcAl62Cj+VJyrn50OlJ53rSup1txIp2EOnrmfejKOUReAmSq8QN/jlW0e3U+5j1CWIgLqn4S0irkFztjqXi/Ez/bQTrZhufSboJS+GpkHRbgWsdbNO9hx122EyEux2LOIu8GrfzDNbJtHHmM67zhkqHMmjnRO17zIkV+pvMbyFBGQ4ykN4GQB51rykCCZJzShA7wOML1NsMz3k1e4ylKPpE+JLlAS5j3UebjeTta0Ab+GcvXrx4OnzJ8qAqQU7Nd7DRnoNwb0A4BVYw41YGBVPo/ULMbUMZuAKOvErpB/TzWQnvrZWbDAtm5fw36W+rOCgAJ3aVeQSeD/jLLIAsi/JNmzb9lHL3IPmpkHi4JH8yLuskC+pUV0jy55aEvSh0q8NQY+bYoxkHSAD7KCDdV0ASbMm5anT6r7wq1/0oq+3SzX6FtmQjL8BVO9K6Jin6Ic55PhDcYvCFrxKnYwBvKGVVlI0qBhVTkw52IJFACaz72CcBVmVMIySAeQm4hL0krT1XctShzXeo7/MF0S6LN0PZmbQ7xjRkhagE/7sEeTF24QfG8E+3AErlVlpssPlLpVRE9FIVHBiJAJb3pv6L6Xy5AOs8DRpnPCfgrvN6I9xVKe/0rgp8/pO8lPjotnR3h9NukMV3d3f/L3VXNykxOuCPn7uLd/Y1WCFZs1SsZSd8MicehwkA/Bw4euyuW24AA3jLPI1RZt5VYhzehLIVpKXk22+4PsrOjJIawLwMoTJ+UvjpfdIzHb8QKmXBy4LCmxRRgMcD32PM1psCJ50WqrWbPwZrf7OJZuJZ6gnqDHlyou6ppb7AZ596HVeJFIMZl3EWbt++ve7mdrtCoocD8I9AxSoBlDvL/NLaNVCfEwRxSSmru60OLH4VZc8URYYLpF4CfQKntOZDkX09U/qyf8fP+t0oeHEpC95kXCHOP13H/YC1nrxgJC8t+wx4obhSnvztuLv/gVenPMoeSZmuLimBX8k48lLxpj1cGOcKiQqTWiE8B6wEFN+rCoD8AyW4J3BlsqjBCoUJWOAFuE8XfjN+3vwmwKmMDlbBS/C3lzb2Y1kogL5SgZNaIWKT4D5upkYJ8gIUdVyNbzLLni/8tPgAuCj26KY2Pmy7CjeX8gCefMTwvGSUJrVCnHxYMBaa7qcObrqTYwOqpj9s+C8VF2Qf6eoihp+npqoVT/FeuRikVEgj09+fe47t44OXKJisfwDw5wVcrT8VFeBivUcMg4vXL1trZaHckk+A7SvAnz59unW31OpXScbWzVWUS7BiTLYEoK8HlLp/F4K04jq4FTS8oiS4zW2yfGZJZB8dfPbhyc2b5UEEPy8YLWuvEDZcb3oT3AGAwT94AKNk2BO854qn+lp5KsDrmAG0cuVK3+uK558BBY2MJzndZVB7hXR2JpCJST1OV9Rcx3wzL9oBfLap92N6yPrNlSa9Qthwtei4zW0Gp+bKBoDM/ZT1K6su7aIOq2qoleBRurl+DufDZR4MqmNcFk7GeA6TnlEmnsBHDIibhgIEJer3fX9sUDG83Lyzrw7eTJmKovwwbCjaATM76p/0KwSgjiAInqAkiBHDXlsQTH7JdjQrMQG1PJVYteELoAfR15D7EfVTgdH3ZFZIgIhFnxhIND4XEUT5ecn481I2IKLNYdYpzAQ+YoD3FaCk4HFw8GPxPH1l/axTV+CkXSGCkg9yeUObVp7+fAvgrkzUSpx1FlEmS/+fAMeVC8D/otStInjzyMwmrngksp1P8VIsjsm6QgIM7qrmAexpDTwqgPIpfRX8F0qZkW1UgB/znmAMqTz5iXQPoNfbWMcXJHx6zwdAMc/6FnvPJYVMk1Uh4W4A6rcA4peK5SYWCdaTfP6e7kReABbIdXaebAxl3f6yYtbysnW6Ocuy/JhSXu8nxqspcFIrJCwdwN5TgKp/5uGRVnqoEcVekSuhw08SAfGkUpZKTDf3f2vXrl1TygQ/+NTPFZUuLhRTDGFVrf5uj72p3VL/gIkEvM8XEgDkgjIrrdMgYO4Fm1DUg7WykqRhX98pZI4uYKZCsvzHJHIV2F9i+KulQiou+e4fI1ZI6ePAjAD2g7gsvxgkSAlsup5HyntYTr4ZxHPLqqq/JhTt6et7Ba3szy+Oeh+WClFJUo7zAp/J5CEglFQ1bNQb8DcbD2BO4IwTdnXsZHV4SvpwmYuAO1fj/Gj3jlJmPhVm7HF4WSlLfJL/On1+v5RVEfV1V8cTy0u8c4X4WXveow2oYOWk+kCZzrKJHAtGXGsAzp8Dnm5HK1dJUpyu4P2MtO/pSoItBZAo8gzSpzeB60tv1vkRrxfl2yXmg1iFp1GuYsMdFnY0gP9EyXvICIWkMIUf0QtlQCt5ZWyd1GhU2Mc/9puWso9d7VFzx+zFgxxHfElpmQbn/DL9edyIn3c47wH3UuByESC6Surgxlzgryj17cf+UplLSEuxkkrs16V9+eEHUVL7U1eInXSg5Yd4jf4raPZiGtTv6mvN9j6pIJATiqPn3ve0dy15al7I/uFXIewgDcOrdL+q9ixlN5eeowJp5dzp9+aJL6qVCbzzEFwVd08ps34ogzaHkj6r8HMsV5QHh+e4E3uqlFVRXSF2YqM+PoC5jDv/50m/k4ZeiqVwJMOSzKdFZTrrpIVkuQ9Gnk7cyKxzIrFWprsIn008FhTy9fT0PItSXkSG45DBiz0xCBzgXVu+SWs+V4eY9ILJxZT7zGI/Ca5uzrk8hiE/Cl+qcGScs8kf22gyAC/rfa9808p0YtcQRE6h6Iyz9Gvklx911FHX8LtUXoxVDbLinsRYgi+GdeKDX+eN8AtI30qfBxMLiEqplLcn/e5h3Zgb47+C2/oEbf8FGSoPgCxfAtTPlz6tK2ntPeBwMBeElwWnoShltk4okrZ3ko7VQpyK1BAvJK9rkmdf4pjKX0Fakm/boCjMTIlDcNL9q1evfp3Y0BICDPu5A8X4OfYdAOLGOlZKqYyKLeJ2rk1exIIvRZ5ZyLACZdxSJhleoqTDUFDGB5D1N6hXKYFyV4fuajWrR4VIjhEA8wB5JIa4jDpRwB8TukbbvMLYD5aCqoL5oRQi34GtaOetpk7O+I8AyLlY0NcQ8FQE1IIEIl1Bq8e0P+eT8+rANWmhaaWWS3VlOHf3DveB5RZCWrKro1Iusv+b7+/CS0u3HF30XsjcNDjr5ryy3cP+ABp8SZkqyooVo5awsQK0Ogh+t18TQ9a3Er6l1ZRxHWu0KUFxTOevojKd4MiLeljyXyLfYuSs73nW09I3sDfeRDrJ/qxn/L7CTGOzjcrycvLuUpaur2R3aa5ijFEiJufxElfx20zsFoR0EmGVYyCDYAtUKqCedngV1Mde8xbk+ijyyat7i3hmgXcLbvhnxMquMRn7G8JvJzq7qV20gfcCX6X+pvWgNI5Gjr/RQZUb20RlcSjlw1jaJ5i8EgiGZWNFzaAIvN+jn4s8NxIUSnkSq/jSJsC6B91YhLSO5SpW+pMyF/dH+fUx7n7ttddehjek8eUglO8XcqIqwB8B+xRK+QOS8UxA7GT2J30EUH8d4LX8kJFYYBOza5v2juCzNy6lzrvK6qi308XtYI63US6F9TWSu/5m57s4Y5/SqrSWKSjlNjb6dyD4esDwbRCVUrcusqNK4hH7GOO/qYykW0vwXB0+d9zPqv5sKVc+y2N1UL6cYFF9VcX1Cu2+wd6Z1yVD7pfjQSEKr3BObCpfpLmP+DyEf5qJqRTL0teTHFWqK39jGUmgDV4j+abJVsLHSlluyrES2DsuxqCWUR5zKXViM2+wOlKJ1q+PVaruWn4VYz8mFFDwu7G+p3j3aQmTeAClpPBDWlSL5a2AZNxbBZHYV4R8jWc6wYe85azkJ+UR0uX28Gw1m/xfEyRlzVWlC7afu2j3HQuhYQ1svKyQhpgNq3GS3S+//PIaFOPPUvjlTF3akJtgNmxhHGDyrHQPY3+A8DR9byZ+nvgqQP3HMlaCHpZO+dXIeRKxfGWVTLuqfJX0+uA0FDmsQlKLpe64inQHKsdj5HVM1h+ZNBsKM7Ebiidiypt/62RYIJr6EpcYTMtn3GO523updvekIYcrIvZEdi7y3U9afirE9nlAuRUF/yH5xDv6Jj+IssKggnHC0C3EZolSLiftD53pNtzs3V+Go31ViP2KTQKc45gXTEPIxhXJLJ7KH0YuT2R1Y1Fu66znZHUmm/mz2YZ4WHKA8UxOKpa/pxom/B6C30QaixOYoKe1u1oF11UhX2WFobBy/GWjujJSYbBj7/AGeUTKoM/qTG16vJKgaDhd+O+7OcUsRSmrmKxKERQBGE1yfC0/FFAGCiPBnV2GPH+EPLJz31BZeTx+EFd1Q2kzInc53ldImUtYZvhsf1AMAJbgBvxRlzx2CtpQNBrKErOdXskjx5VlUBWWWKq4PB5/lLQy5OoiuXvKTnZfa3yUOrHw0ayUVRyLvZj8OkrRMgOkmpixN1IuP9K1sn1NBmZ8TnQkHfkzT/aXq0OjQaTY5z6OnD8sZfXVZf1haSIpJCcRSvFDNPaVdwPIZwMBrJD0diq5WnyIk3xpLa9gWrVawvVwyHiRvl8SfMjxHCdd1Z0oI++59mjc1KydTiQSlHAD/I+pb/GlSgE5H38ubwog6TKcz5WU/5TYeQaQMveR7Nj9rIf/NeXLEL740E3ocnzG/SGnrt/lJzP8oqfyDOdOKRpME1UhzkSAlb8f0B9GKb41uJigQrx2+Qgr6OvkR40Y98coxTdHDiGsY1/7Gq70csZdS15ljNhVUfeAofo+MbX8io+bfVKr95Dh+q27/4ls6Dm/fYoFvRkE86OljBS2edzmfNYbcTzaAo9YkBZVzNWin2/VnjES0XJ1OG5sXiNp1K7TRqCNQBuBNgJtBNoItBFoI9BGoI1AG4E2Am0E2giMdwT+Hwjgx4+1ISNJAAAAAElFTkSuQmCC");
	image.setAttribute("class", "zeeguu-pronounce-icon");
	pronounceElement.appendChild(image);

	var sentences = Array.prototype.slice.call(document.getElementsByTagName(zeeguuSentenceTagName));
	sentences.forEach(function (el) {
		removeElementsFromSentence(el);
	});

	insertElementAfter(pronounceElement, wordElement);
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