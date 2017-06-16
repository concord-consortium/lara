# Embeddable and Interactive Filtering

## Runtime Page Rendering

The runtime page is rendered from "answers". Essentially the answers of the page_items of the page are used to generate the components on the page. If a page_item doesn't have an answer like an Xhtml element. Then the page_item is used directly. This logic of getting either answer object or the page_item is handled by the AnswerFinder.

Interactives on the page bypass this "answer" approach. They use the interactive objects directly.  And then within the partial a helper is used to find the InteractiveRunState if there is one.

The numbering of items in the activity boils down to:

    activity.reportable_items.index(item) + 1

This happens when individual 'answer' partials call the `Embeddable::Answer#question_index` to find the index of the 'question' on the page. The Xhtml partial  doesn't look for an index. Reportable interactives technically have an index because they are part of reportable_items, but they do not display it.

### Single page special cases

In single page rendering the labbooks are shown below their interactive. This labbook rendering is done by the interactive partial. If the interactive is not visible then the labbook will not be rendered. 

## Activity Progress

LARA shows activity progress in completion ribbons on the sequence table of contents. The progess is also shown in some admin info reports.

The progress is based on `Run#num_answered_reportable_items` / `Run#num_reportable_items`.

`Activity#reportable_items` is the combination of `Page#reportable_items` on all visible pages.

`Page#reportable_items` is the combination of visible_embeddables and visible_interactives that are `#reportable?`.

`Run#num_answers` is the count of `Run#answers` that are:
- `#answered?`.
- not part of another activity

`Run#answers` is the simple combination of
`open_response_answers + multiple_choice_answers + image_question_answers + labbook_answers + interactive_run_states`

NOTE: `Run#answers` differs from `Activity#answers(run)`. `Activity#answers(run)` will create an answer object for every `Activity#reportable_items` if the answer doesn't already exist. `Run#answers` doesn't do this.
This might be for speed as well as supporting the idea of clearing answers from a run.

TODO: Improve this confusing use of the answers method on two objects. There shouldn't be a need for both approaches.

## LARA summary report

The summary report is based off of:

    @answers = @activity.answers(@run)

`Activity#answers` uses the AnswerFinder to get answers from all of the `Activity#reportable_items`.

The numbering of the items in the report is based off of the index of the answer in the @answers array.

## Sending answers to the portal

The code to look at here is `LightweightActivity#serialize_for_portal`. It goes through each page.

It uses `Page#reportable_items` to get a filtered list of embeddables and interactives
A switch statement is used of known types with a fallback of looking for a `#portal_hash` method.
Xhtml isn't in the list of known types, and it doesn't have a `#portal_hash` method.
