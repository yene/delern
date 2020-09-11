import 'package:delern_flutter/l10n/messages_all.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

@immutable
class AppLocalizations {
  const AppLocalizations();

  static Future<AppLocalizations> load(String locale) async {
    final localeName = Intl.canonicalizedLocale(locale);

    await initializeMessages(localeName);
    await initializeDateFormatting(localeName);
    Intl.defaultLocale = localeName;

    return const AppLocalizations();
  }

  String get navigationDrawerSignOut => Intl.message(
        'Sign Out',
        name: 'navigationDrawerSignOut',
        desc: 'Sign Out in Navigation Drawer',
      );

  String get navigationDrawerInviteFriends => Intl.message(
        'Invite Friends',
        name: 'navigationDrawerInviteFriends',
        desc: 'Invite Friends in Navigation Drawer',
      );

  String get navigationDrawerContactUs => Intl.message(
        'Contact Us',
        name: 'navigationDrawerContactUs',
        desc: 'Contact Us in Navigation Drawer',
      );

  String get navigationDrawerAbout => Intl.message(
        'About',
        name: 'navigationDrawerAbout',
        desc: 'About in Navigation Drawer',
      );

  String get signInWithGoogle => Intl.message(
        'Google',
        name: 'signInWithGoogle',
        desc: 'Sign in with Google Button',
      );

  String get signInWithLabel => Intl.message(
        'Sign in with:',
        name: 'signInWithLabel',
        desc: 'Sign in with lable before different providers',
      );

  String get signInWithFacebook => Intl.message(
        'Facebook',
        name: 'signInWithFacebook',
        desc: 'Sign in with Facebook Button',
      );

  String get editCardsDeckMenu => Intl.message(
        'Edit Cards',
        name: 'editCardsDeckMenu',
        desc: 'Edit Cards in Deck Menu',
      );

  String get settingsDeckMenu => Intl.message(
        'Settings',
        name: 'settingsDeckMenu',
        desc: 'Settings in Deck Menu',
      );

  String get shareDeckMenu => Intl.message(
        'Share',
        name: 'shareDeckMenu',
        desc: 'Share in Deck Menu',
      );

  String numberOfCards(int number) => Intl.message(
        'Cards in the deck: $number',
        name: 'numberOfCards',
        args: [number],
        desc: 'Card in the deck',
      );

  String get canEdit => Intl.message(
        'Can Edit',
        name: 'canEdit',
        desc: 'User can edit a deck',
      );

  String get canView => Intl.message(
        'Can View',
        name: 'canView',
        desc: 'User can view a deck',
      );

  String get owner => Intl.message(
        'Owner',
        name: 'owner',
        desc: 'User has owner access',
      );

  String get noAccess => Intl.message(
        'No access',
        name: 'noAccess',
        desc: 'User has no access',
      );

  String get emailAddressHint => Intl.message(
        'Email address',
        name: 'emailAddressHint',
        desc: 'Email address hint',
      );

  String get peopleLabel => Intl.message(
        'People',
        name: 'peopleLabel',
        desc: 'People label',
      );

  String get whoHasAccessLabel => Intl.message(
        'Who has access',
        name: 'whoHasAccessLabel',
        desc: 'Who has access label',
      );

  String get frontSideHint => Intl.message(
        'Front side:',
        name: 'frontSideHint',
        desc: 'front side',
      );

  String get backSideHint => Intl.message(
        'Back side:',
        name: 'backSideHint',
        desc: 'back side',
      );

  String get reversedCardLabel => Intl.message(
        'Add a reversed copy of this card',
        name: 'reversedCardLabel',
        desc: 'Add reversed card',
      );

  String get deck => Intl.message(
        'Deck',
        name: 'deck',
        desc: 'Deck label',
      );

  String get add => Intl.message(
        'Add',
        name: 'add',
        desc: 'Add',
      );

  String get save => Intl.message(
        'Save',
        name: 'save',
        desc: 'Save',
      );

  String get delete => Intl.message(
        'Delete',
        name: 'delete',
        desc: 'Delete',
      );

  String get saveChangesQuestion => Intl.message(
        'Do you want to save changes?',
        name: 'saveChangesQuestion',
        desc: 'Do you want to save changes?',
      );

  String get deleteCardQuestion => Intl.message(
        'Do you want to delete this card?',
        name: 'deleteCardQuestion',
        desc: 'Do you want to delete card?',
      );

  String get errorUserMessage => Intl.message(
        'Error: ',
        name: 'errorUserMessage',
        desc: 'Error occurred.',
      );

  String get send => Intl.message(
        'Send',
        name: 'send',
        desc: 'Send',
      );

  String get appNotInstalledSharingDeck => Intl.message(
        "This user hasn't installed Delern yet. Do you want to sent an "
        'invite?',
        name: 'appNotInstalledSharingDeck',
        desc: "The app hasn't installed by user with who deck was shared",
      );

  String get inviteToAppMessage => Intl.message(
        '''
I invite you to install Delern, a spaced repetition learning app, which will allow you to learn quickly and easily!

Proceed to install it from:
Google Play: https://play.google.com/store/apps/details?id=org.dasfoo.delern
App Store: https://itunes.apple.com/us/app/delern/id1435734822

After install, follow Delern latest news on:
Facebook: https://fb.me/das.delern
LinkedIn: https://www.linkedin.com/company/delern
VK: https://vk.com/delern
Twitter: https://twitter.com/dasdelern''',
        name: 'inviteToAppMessage',
        desc: 'Invite to the App message',
      );

  String get edit => Intl.message(
        'Edit',
        name: 'edit',
        desc: 'Edit',
      );

  String answeredCards(int number) => Intl.message(
        'Answered: $number',
        args: [number],
        name: 'answeredCards',
        desc: 'Label for number of answered cards',
      );

  String get basicDeckType => Intl.message(
        'Basic',
        name: 'basicDeckType',
        desc: 'basic decktype name',
      );

  String get germanDeckType => Intl.message(
        'German',
        name: 'germanDeckType',
        desc: 'german decktype name',
      );

  String get swissDeckType => Intl.message(
        'Swiss',
        name: 'swissDeckType',
        desc: 'swiss decktype name',
      );

  String get unknownDeckType => Intl.message(
        'Unknown',
        name: 'unknownDeckType',
        desc: 'unknown decktype name',
      );

  String get deckType => Intl.message(
        'Deck Type',
        name: 'deckType',
        desc: 'Deck Type',
      );

  String get markdown => Intl.message(
        'Markdown',
        name: 'markdown',
        desc: 'Markdown',
      );

  String get cardDeletedUserMessage => Intl.message(
        'Card was deleted',
        name: 'cardDeletedUserMessage',
        desc: 'Card was deleted',
      );

  String get cardAddedUserMessage => Intl.message(
        'Card was added',
        name: 'cardAddedUserMessage',
        desc: 'Card was added',
      );

  String get searchHint => Intl.message(
        'Search...',
        name: 'searchHint',
        desc: 'Search...',
      );

  String get emptyUserSharingList => Intl.message(
        'Share your deck',
        name: 'emptyUserSharingList',
        desc: 'Share your deck',
      );

  String get emptyDecksList => Intl.message(
        'Add your decks',
        name: 'emptyDecksList',
        desc: 'Add your decks',
      );

  String get emptyCardsList => Intl.message(
        'Add your cards',
        name: 'emptyCardsList',
        desc: 'Add your cards',
      );

  String get noSharingAccessUserMessage => Intl.message(
        'Only owner of deck can share it.',
        name: 'noSharingAccessUserMessage',
        desc: 'Only owner of deck can share it.',
      );

  String get noEditingWithReadAccessUserMessage => Intl.message(
        'You cannot edit card with a read access.',
        name: 'noEditingWithReadAccessUserMessage',
        desc: 'You cannot edit card with a read access.',
      );

  String get noDeletingWithReadAccessUserMessage => Intl.message(
        'You cannot delete card with a read access.',
        name: 'noDeletingWithReadAccessUserMessage',
        desc: 'You cannot delete card with a read access.',
      );

  String get noAddingWithReadAccessUserMessage => Intl.message(
        'You cannot add cards with a read access.',
        name: 'noAddingWithReadAccessUserMessage',
        desc: 'You cannot add cards with a read access..',
      );

  String get continueEditingQuestion => Intl.message(
        'You have unsaved changes. Would you like to continue editing?',
        name: 'continueEditingQuestion',
        desc: 'You have unsaved changes. Would you like to continue editing?',
      );

  String get yes => Intl.message(
        'Yes',
        name: 'yes',
        desc: 'Yes',
      );

  String get discard => Intl.message(
        'Discard',
        name: 'discard',
        desc: 'Discard',
      );

  String get installEmailApp => Intl.message(
        'Please install Email App',
        name: 'installEmailApp',
        desc: 'Please install Email App',
      );

  String couldNotLaunchUrl(String url) => Intl.message(
        'Could not launch url $url',
        args: [url],
        name: 'couldNotLaunchUrl',
        desc: 'Could not launch url',
      );

  String get no => Intl.message(
        'no',
        name: 'no',
        desc: 'no',
      );

  String continueLearningQuestion(String date) => Intl.message(
        'Next card to learn is suggested at $date. Would you like to continue '
        'learning anyway?',
        args: [date],
        name: 'continueLearningQuestion',
        desc: 'Question for the user to continue learning',
      );

  String get offlineUserMessage => Intl.message(
        'You are offline, please try it later',
        name: 'offlineUserMessage',
        desc: 'Offline user message',
      );

  String get serverUnavailableUserMessage => Intl.message(
        'Server temporarily unavailable, please try again later',
        name: 'serverUnavailableUserMessage',
        desc: 'Server temporarily unavailable',
      );

  String get continueAnonymously => Intl.message(
        'Continue as a Guest',
        name: 'continueAnonymously',
        desc: 'Sign in as a guest to the app',
      );

  String get splashScreenFeatures => Intl.message(
        'All the data will be saved in the Cloud and synchronized across all '
        'your devices. You can also share cards with your friends and '
        'colleagues',
        name: 'splashScreenFeatures',
        desc: 'Data and progress are saved',
      );

  String get anonymous => Intl.message(
        'Anonymous',
        name: 'anonymous',
        desc: 'Anonymous',
      );

  String get navigationDrawerSignIn => Intl.message(
        'Sign In',
        name: 'navigationDrawerSignIn',
        desc: 'Sign In',
      );

  String get signInCredentialAlreadyInUseWarning => Intl.message(
        'The account you have chosen is already registered with the '
        'application. If you continue with sign in, all data that you have '
        'created anonymously will be lost. Would you like to continue?',
        name: 'signInCredentialAlreadyInUseWarning',
        desc: 'Sign in flow: a warning after sign in attempt (anonymous)',
      );

  String get signInAccountExistWithDifferentCredentialWarning => Intl.message(
        'You have previously signed in to the application using this email, '
        'but with a different provider (e.g. Google instead of Facebook). '
        'Please sign in with the same provider you have used before.',
        name: 'signInAccountExistWithDifferentCredentialWarning',
        desc: 'Sign in flow: a warning after sign in attempt (unauthenticated)',
      );

  String get deleteDeckOwnerAccessQuestion => Intl.message(
        'The deck, all cards and learning history will be removed.\n\n'
        'If you have shared this deck with other users, it will also be '
        'removed from all users it is shared with. Do you want to delete '
        'the deck?',
        name: 'deleteDeckOwnerAccessQuestion',
        desc: 'Delete deck question to owner of deck',
      );

  String get deleteDeckWriteReadAccessQuestion => Intl.message(
        'The deck will be removed from your account only, all cards and '
        'learning history will remain with the owner and other users. '
        'Do you want to delete the deck?',
        name: 'deleteDeckWriteReadAccessQuestion',
        desc: 'Delete deck question to user with write access',
      );

  String get addCardsDeckMenu => Intl.message(
        'Add Cards',
        name: 'addCardsDeckMenu',
        desc: 'Add Cards in Deck Menu',
      );

  String get addDeckTooltip => Intl.message(
        'Add Deck',
        name: 'addDeckTooltip',
        desc: 'Add Deck',
      );

  String get addCardTooltip => Intl.message(
        'Add Card',
        name: 'addCardTooltip',
        desc: 'Add Card',
      );

  String get cardAndReversedAddedUserMessage => Intl.message(
        'Card and reversed card were added',
        name: 'cardAndReversedAddedUserMessage',
        desc: 'Card and reversed card were added',
      );

  String get listOFDecksScreenTitle => Intl.message(
        'List of decks',
        name: 'listOFDecksScreenTitle',
        desc: 'List of decks',
      );

  String cardsToLearnLabel(String numberOfCards, String total) => Intl.message(
        '$numberOfCards of $total to learn',
        args: [numberOfCards, total],
        name: 'cardsToLearnLabel',
        desc: 'Cards to learn label',
      );

  String get profileTooltip => Intl.message(
        'Profile',
        name: 'profileTooltip',
        desc: 'Tooltip for the icon in top corner that opens Navigation Drawer',
      );

  String get offlineProfileTooltip => Intl.message(
        'Profile (you are offline)',
        name: 'offlineProfileTooltip',
        desc: 'Tooltip for the icon in top corner when offline',
      );

  String get deckDeletedUserMessage => Intl.message(
        'Deck was deleted',
        name: 'deckDeletedUserMessage',
        desc: 'Deck was deleted',
      );

  String get flip => Intl.message(
        'flip',
        name: 'flip',
        desc: 'flip',
      );

  String learning(String deckName) => Intl.message(
        'Learning: $deckName',
        args: [deckName],
        name: 'learning',
        desc: 'Learning Type',
      );

  String get intervalLearning => Intl.message(
        'Interval',
        name: 'intervalLearning',
        desc: 'Interval Learning Label',
      );

  String get intervalLearningTooltip => Intl.message(
        'Start learning cards ordered for interval learning',
        name: 'intervalLearningTooltip',
        desc: 'Tooltip for Interval Learning Label',
      );

  String get viewLearning => Intl.message(
        'View',
        name: 'viewLearning',
        desc: 'View Learning Label',
      );

  String get viewLearningTooltip => Intl.message(
        'Start learning all cards in any order',
        name: 'viewLearningTooltip',
        desc: 'Tooltip for View Learning Label',
      );

  String get scrollToStartLabel => Intl.message(
        'Scroll to the beginning',
        name: 'scrollToStartLabel',
        desc: 'Scroll to the beginning',
      );

  String get deleteDeckButton => Intl.message(
        'Delete Deck',
        name: 'deleteDeckButton',
        desc: 'Delete deck button',
      );

  String get other => Intl.message(
        'other',
        name: 'other',
        desc: 'Other',
      );

  String get createDeckTooltip => Intl.message(
        'Create deck',
        name: 'createDeckTooltip',
        desc: 'Create Deck tooltip',
      );

  String get menuTooltip => Intl.message(
        'Menu',
        name: 'menuTooltip',
        desc: 'Menu tooltip',
      );

  String get deckSettingsTooltip => Intl.message(
        'Settings of deck',
        name: 'deckSettingsTooltip',
        desc: 'Tooltip for settings of deck',
      );

  String get shareDeckTooltip => Intl.message(
        'Share deck',
        name: 'shareDeckTooltip',
        desc: 'Tooltip for deck sharing',
      );

  String get deleteCardTooltip => Intl.message(
        'Delete card',
        name: 'deleteCardTooltip',
        desc: 'Tooltip for deleting card',
      );

  String get editCardTooltip => Intl.message(
        'Edit card',
        name: 'editCardTooltip',
        desc: 'Tooltip for editing card',
      );

  String get knowCardTooltip => Intl.message(
        'I know',
        name: 'knowCardTooltip',
        desc: 'Tooltip for know card button',
      );

  String get doNotKnowCardTooltip => Intl.message(
        "I don't know",
        name: 'doNotKnowCardTooltip',
        desc: 'Tooltip for do not know card button',
      );

  String get privacyPolicy => Intl.message(
        'Privacy Policy',
        name: 'privacyPolicy',
        desc: 'Privacy Policy label',
      );

  String get termsOfService => Intl.message(
        'Terms of Service',
        name: 'termsOfService',
        desc: 'Terms of Service label',
      );

  String get legacyAcceptanceLabel => Intl.message(
        'By using this app you accept the ',
        name: 'legacyAcceptanceLabel',
        desc: 'User accept policy by using the app',
      );

  String get legacyPartsConnector => Intl.message(
        ' and the  ',
        name: 'legacyPartsConnector',
        desc: 'Connects parts of legacy',
      );

  String get shuffleTooltip => Intl.message(
        'Shuffle cards',
        name: 'shuffleTooltip',
        desc: 'Shuffle cards tooltip',
      );

  String get signInScreenOr => Intl.message(
        'or',
        name: 'signInScreenOr',
        desc: 'or label',
      );

  String get featureNotAvailableUserMessage => Intl.message(
        'This feature is currently not available. Please try it later.',
        name: 'featureNotAvailableUserMessage',
        desc: 'User message that a feature is not available right now',
      );

  String get imageFromGalleryLabel => Intl.message(
        'From Gallery',
        name: 'imageFromGalleryLabel',
        desc: 'Upload image from Gallery',
      );

  String get imageFromPhotoLabel => Intl.message(
        'Take Photo',
        name: 'imageFromPhotoLabel',
        desc: 'Take photo to upload image',
      );

  String get accessibilityAddImageLabel => Intl.message(
        'Add Image',
        name: 'accessibilityAddImageLabel',
        desc: 'Add Image Accessibility label',
      );

  String get imageLoadingErrorUserMessage => Intl.message(
        'Error during loading the image. Please try it later.',
        name: 'imageLoadingErrorUserMessage',
        desc: 'Image loading error message to user',
      );

  String get decksRefreshed => Intl.message(
        'Decks refreshed',
        name: 'decksRefreshed',
        desc: 'The user pulled down on decks list and some updates have been '
            'picked up',
      );

  String get noUpdates => Intl.message(
        'No updates',
        name: 'noUpdates',
        desc: 'The user pulled down on decks list but no updates were found',
      );
}
