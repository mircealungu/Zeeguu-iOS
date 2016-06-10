//
//  ZeeguuVars.js
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

/// Constants
const ZeeguuTranslateImmediately = 0;
const ZeeguuTranslateWordPair = 1;
const ZeeguuTranslateSentence = 2;

/// Options
var zeeguuTranslationMode = ZeeguuTranslateImmediately;
var zeeguuLinksAreDisabled = false;
var zeeguuSelectionFirstWord = null;

/// HTML vars
var zeeguuParagraphTagName = "zeeguuParagraph";
var zeeguuWordTagName = "zeeguuWord";
var zeeguuTranslatedWordTagName = "zeeguuTranslatedWord";
var zeeguuSentenceTagName = "zeeguuSentence";

var zeeguuPronounceTagName = "zeeguuPronounce";
var zeeguuPronounceID = "zeeguuPronounce";

var zeeguuPeriodTagName = "zeeguuPeriod";
var zeeguuPeriodID = "zeeguuPeriod";

var zeeguuuTranslatedWordID = "zeeguuTranslatedWord";
var zeeguuuTranslationID = "zeeguuTranslation";

var zeeguuIDCounter = 0;
var zeeguuPeriodCounter = 0;

var zeeguuInlineTextElementsToWalkThrough = ["a", "b", "i", "u"];

document.body.style.webkitTouchCallout='none';
document.body.style.KhtmlUserSelect='none';
