//
//  ZeeguuAPIEndpoints.swift
//  ZeeguuAPI
//
//  Created by Jorrit Oosterhof on 29-11-15.
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

import UIKit

enum ZeeguuAPIEndpoint: String {
	case AddNewTranslationToBookmark = "add_new_translation_to_bookmark"
	case AddUser = "add_user"
	case AvailableLanguages = "available_languages"
	case AvailableNativeLanguages = "available_native_languages"
	case BookmarksByDay = "bookmarks_by_day"
	case BookmarkWithContext = "bookmark_with_context"
	case DeleteBookmark = "delete_bookmark"
	case DeleteTranslationFromBookmark = "delete_translation_from_bookmark"
	case GetContentFromURL = "get_content_from_url"
	case GetDifficultyForText = "get_difficulty_for_text"
	case GetExerciseLogForBookmark = "get_exercise_log_for_bookmark"
	case GetFeedsAtURL = "get_feeds_at_url"
	case GetFeedsBeingFollowed = "get_feeds_being_followed"
	case GetFeedItems = "get_feed_items"
	case GetKnownBookmarks = "get_known_bookmarks"
	case GetKnownWords = "get_known_words"
	case GetLearnabilityForText = "get_learnability_for_text"
	case GetLearnedBookmarks = "get_learned_bookmarks"
	case GetLowerBoundPercentageOfBasicVocabulary = "get_lower_bound_percentage_of_basic_vocabulary"
	case GetLowerBoundPercentageOfExtendedVocabulary = "get_lower_bound_percentage_of_extended_vocabulary"
	case GetNotEncounteredWords = "get_not_encountered_words"
	case GetNotLookedUpWords = "get_not_looked_up_words"
	case GetPercentageOfProbablyKnownBookmarkedWords = "get_percentage_of_probably_known_bookmarked_words"
	case GetPossibleTranslations = "get_possible_translations"
	case GetProbablyKnownWords = "get_probably_known_words"
	case GetTranslationsForBookmark = "get_translations_for_bookmark"
	case GetUpperBoundPercentageOfBasicVocabulary = "get_upper_bound_percentage_of_basic_vocabulary"
	case GetUpperBoundPercentageOfExtendedVocabulary = "get_upper_bound_percentage_of_extended_vocabulary"
	case getUserDetails = "get_user_details"
	case LearnedAndNativeLanguage = "learned_and_native_language"
	case LearnedLanguage = "learned_language"
	case Logout = "logout_session"
	case NativeLanguage = "native_language"
	case Session = "session"
	case StartFollowingFeeds = "start_following_feeds"
	case StopFollowingFeed = "stop_following_feed"
	case TranslateAndBookmark = "translate_and_bookmark"
	case UserWords = "user_words"
	case Validate = "validate"
}
