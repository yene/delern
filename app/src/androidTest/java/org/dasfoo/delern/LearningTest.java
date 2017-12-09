/*
 * Copyright (C) 2017 Katarina Sheremet
 * This file is part of Delern.
 *
 * Delern is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Delern is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with  Delern.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.dasfoo.delern;

import android.content.Context;
import android.support.test.rule.ActivityTestRule;
import android.support.test.runner.AndroidJUnit4;

import org.dasfoo.delern.listdecks.DelernMainActivity;
import org.dasfoo.delern.models.DeckType;
import org.dasfoo.delern.test.DeckPostfix;
import org.dasfoo.delern.test.FirebaseOperationInProgressRule;
import org.dasfoo.delern.test.FirebaseSignInRule;
import org.dasfoo.delern.test.ViewMatchers;
import org.hamcrest.CoreMatchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;
import org.junit.runner.RunWith;

import static android.support.test.InstrumentationRegistry.getInstrumentation;
import static android.support.test.espresso.Espresso.onData;
import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.Espresso.openActionBarOverflowOrOptionsMenu;
import static android.support.test.espresso.Espresso.pressBack;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.action.ViewActions.closeSoftKeyboard;
import static android.support.test.espresso.action.ViewActions.typeText;
import static android.support.test.espresso.assertion.ViewAssertions.matches;
import static android.support.test.espresso.matcher.ViewMatchers.hasSibling;
import static android.support.test.espresso.matcher.ViewMatchers.isChecked;
import static android.support.test.espresso.matcher.ViewMatchers.isDisplayed;
import static android.support.test.espresso.matcher.ViewMatchers.withId;
import static android.support.test.espresso.matcher.ViewMatchers.withSpinnerText;
import static android.support.test.espresso.matcher.ViewMatchers.withText;
import static org.dasfoo.delern.test.BasicOperations.createCard;
import static org.dasfoo.delern.test.BasicOperations.createDeck;
import static org.dasfoo.delern.test.BasicOperations.deleteDeck;
import static org.dasfoo.delern.test.WaitView.bringToFront;
import static org.dasfoo.delern.test.WaitView.waitView;
import static org.hamcrest.CoreMatchers.instanceOf;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.core.AllOf.allOf;

/**
 * Test learning cards functions.
 */
@RunWith(AndroidJUnit4.class)
public class LearningTest {

    @Rule
    public ActivityTestRule<DelernMainActivity> mActivityRule = new ActivityTestRule<>(
            DelernMainActivity.class);

    @Rule
    public TestName mName = new TestName();

    @Rule
    public FirebaseOperationInProgressRule mFirebaseRule =
            new FirebaseOperationInProgressRule(true);

    @Rule
    public FirebaseSignInRule mSignInRule = new FirebaseSignInRule(true);

    private String mDeckName;

    private void changeDeckType(final DeckType dType) {
        Context context = mActivityRule.getActivity().getApplicationContext();
        String deckType = context.getResources()
                .getStringArray(R.array.deck_type_spinner)[dType.ordinal()];
        onView(CoreMatchers.allOf(withId(R.id.deck_popup_menu), hasSibling(withText(mDeckName))))
                .perform(click());
        onView(withText(R.string.deck_settings_menu)).perform(click());
        // Spinner doesn't always open.
        onView(withId(R.id.deck_type_spinner)).perform(click());
        onData(CoreMatchers.allOf(is(instanceOf(String.class)), is(deckType))).perform(click());
        onView(withId(R.id.deck_type_spinner))
                .check(matches(withSpinnerText(is(deckType))));
        pressBack();
    }

    @Before
    public void createDeckBeforeTest() {
        mDeckName = mName.getMethodName() + DeckPostfix.getRandomNumber();
        createDeck(mDeckName);
    }

    @Test
    public void learnGermanCards() {
        String front1 = "mother";
        String back1 = "die Mutter";
        String front2 = "father";
        String back2 = "der Vater";
        String front3 = "kid";
        String back3 = "das Kind";
        createCard(front1, back1, /* reversed= */false);
        createCard(front2, back2, /* reversed= */false);
        createCard(front3, back3, /* reversed= */false);
        pressBack();
        // Change deckType
        changeDeckType(DeckType.GERMAN);
        // Start Learning Activity
        waitView(() -> onView(allOf(withText(mDeckName), hasSibling(withText("3"))))
                .perform(click()));
        // Check the first card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front1))));
        onView(withId(R.id.card_view)).check(matches(new ViewMatchers.ColorMatcher(R.color.feminine)));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        onView(withId(R.id.textBackCardView)).check(matches(withText(back1)));
        onView(withId(R.id.to_know_button)).perform(click());
        // Check the second card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front2))));
        onView(withId(R.id.card_view)).check(matches(new ViewMatchers.ColorMatcher(R.color.masculine)));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        // Check back side of card
        onView(withId(R.id.textBackCardView)).check(matches(withText(back2)));
        onView(withId(R.id.to_repeat_button)).perform(click());
        // Check the third card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front3))));
        onView(withId(R.id.card_view)).check(matches(new ViewMatchers.ColorMatcher(R.color.neuter)));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        // Check back side of card
        onView(withId(R.id.textBackCardView)).check(matches(withText(back3)));
        onView(withId(R.id.to_repeat_button)).perform(click());
    }

    @Test
    public void learnSwissCards() {
        Context context = mActivityRule.getActivity().getApplicationContext();
        String front1 = "mother";
        String back1 = "d Muetter";
        String front2 = "father";
        String back2 = "de Vater";
        String front3 = "kid";
        String back3 = "s Kind";
        createCard(front1, back1, /* reversed= */false);
        createCard(front2, back2, /* reversed= */false);
        createCard(front3, back3, /* reversed= */false);
        pressBack();
        // Change deckType
        changeDeckType(DeckType.SWISS);
        // Start Learning Activity
        waitView(() -> onView(allOf(withText(mDeckName), hasSibling(withText("3"))))
                .perform(click()));
        // Check the first card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front1))));
        onView(withId(R.id.card_view))
                .check(matches(new ViewMatchers.ColorMatcher(R.color.feminine)));
        onView(withId(R.id.learned_in_session))
                .check(matches(withText(String.format(context.getString(R.string.card_watched_text),
                        0))));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        onView(withId(R.id.textBackCardView)).check(matches(withText(back1)));
        onView(withId(R.id.to_know_button)).perform(click());
        // Check the second card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front2))));
        onView(withId(R.id.card_view))
                .check(matches(new ViewMatchers.ColorMatcher(R.color.masculine)));
        onView(withId(R.id.learned_in_session))
                .check(matches(withText(String.format(context.getString(R.string.card_watched_text),
                        1))));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        // Check back side of card
        onView(withId(R.id.textBackCardView)).check(matches(withText(back2)));
        onView(withId(R.id.to_repeat_button)).perform(click());
        // Check the third card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front3))));
        onView(withId(R.id.card_view)).check(matches(new ViewMatchers.ColorMatcher(R.color.neuter)));
        onView(withId(R.id.learned_in_session))
                .check(matches(withText(String.format(context.getString(R.string.card_watched_text),
                        2))));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        // Check back side of card
        onView(withId(R.id.textBackCardView)).check(matches(withText(back3)));
        onView(withId(R.id.to_repeat_button)).perform(click());
    }

    @Test
    public void deleteCardMenuOption() {
        String front = "mother";
        String back = "die Mutter";
        createCard(front, back, /* reversed= */false);
        pressBack();
        // Start Learning Activity
        waitView(() -> onView(allOf(withText(mDeckName), hasSibling(withText("1"))))
                .perform(click()));
        // Check the card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front))));
        // Open the options menu OR open the overflow menu, depending on whether
        // the device has a hardware or software overflow menu button.
        openActionBarOverflowOrOptionsMenu(getInstrumentation().getTargetContext());
        onView(withText(R.string.delete)).perform(click());
        onView(withText(R.string.delete)).perform(click());
    }

    @Test
    public void basicDeckType() {
        String front1 = "mother";
        String back1 = "d Muetter";
        createCard(front1, back1, /* reversed= */false);
        pressBack();
        // Change deckType
        changeDeckType(DeckType.SWISS);
        waitView(() -> onView(allOf(withText(mDeckName), hasSibling(withText("1"))))
                .perform(click()));
        // Check the first card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front1))));
        onView(withId(R.id.card_view))
                .check(matches(new ViewMatchers.ColorMatcher(R.color.feminine)));
        pressBack();
        // Change deckType
        changeDeckType(DeckType.BASIC);
        // Start Learning Activity
        waitView(() -> onView(allOf(withText(mDeckName), hasSibling(withText("1"))))
                .perform(click()));
        // Check the first card
        waitView(() -> onView(withId(R.id.textFrontCardView)).check(matches(withText(front1))));
        onView(withId(R.id.card_view)).check(matches(new ViewMatchers.ColorMatcher(R.color.noGender)));
    }

    @Test
    public void createMarkdownCardToLearn() {
        String frontCard = "**bold**";
        String frontShouldBeShown = "bold\n\n";
        String backCard = "*italic*";
        String backShouldBeShown = "italic\n\n";
        waitView(() -> onView(withId(R.id.add_card_to_db)).check(matches(isDisplayed())));
        onView(withId(R.id.front_side_text)).perform(typeText(frontCard));
        onView(withId(R.id.back_side_text)).perform(typeText(backCard), closeSoftKeyboard());
        onView(withId(R.id.add_card_to_db)).perform(click());
        // Check that fields are empty after adding card
        waitView(() -> onView(withId(R.id.front_side_text)).check(matches(withText(""))));
        onView(withId(R.id.back_side_text)).check(matches(withText("")));
        pressBack();
        waitView(() -> onView(withText(mDeckName)).check(matches(hasSibling(withText("1")))));
        // Set markdown in settings
        onView(allOf(withId(R.id.deck_popup_menu), hasSibling(withText(mDeckName))))
                .perform(click());
        onView(withText(R.string.deck_settings_menu)).perform(click());
        waitView(() -> onView(withId(R.id.on_off_switch)).check(matches(not(isChecked())))
                .perform(click()));
        onView(withId(R.id.on_off_switch)).check(matches(isChecked()));
        pressBack();
        waitView(() -> onView(allOf(withText(mDeckName), hasSibling(withText("1"))))
                .perform(click()));
        // Check the front side of markdown
        waitView(() -> onView(withId(R.id.textFrontCardView))
                .check(matches(withText(frontShouldBeShown))));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        // Check the back side of markdown
        waitView(() -> onView(withId(R.id.textBackCardView))
                .check(matches(withText(backShouldBeShown))));
    }

    @After
    public void delete() {
        bringToFront(mActivityRule);
        deleteDeck(mDeckName);
    }
}
