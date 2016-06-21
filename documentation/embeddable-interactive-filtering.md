# Embeddable and Interactive Filtering

## Runtime Page Rendering

The runtime page is rendered from "answers". Essentially the answers of the page_items of the page are used to generate the components on the page. If a page_item doesn't have an answer like an Xhtml element. Then the page_item is used directly. This logic of getting either answer object or the page_item is handled by the AnswerFinder.

Interactives on the page bypass this "answer" approach. They use the interactive objects directly.  And then within the partial a helper is used to find the InteractiveRunState if there is one.

The numbering of items in the activity boils down to:

    activity.questions.index(item) + 1

This happens when individual 'answer' partials call the Embeddable::Answer#question_index to find the index of the 'question' on the page. The Xhtml partial  doesn't look for an index. Reportable interactives technically have an index, but they do not display it.

## Activity Progress

LARA shows activity progress in completion ribbons on the sequence table of contents. The progess is also shown in some admin info reports.

The progress is based on `Run#num_answers` / `Run#num_questions`.

The num_questions is the count of `Activity#questions`.

`Activity#questions` is the combination of
- visible_embeddables filtered by QUESTION_TYPES, this removes Xhtml items.
- visible_interactives filtered to only inclue interactives that are reportable.

`Run#num_answers` is
- `open_response_answers + multiple_choice_answers + image_question_answers + labbook_answers + interactive_run_states`
- interactive_run_states removed (BUG)
- answers that are not `#answered?` are removed
- answers with questions that aren't in the activity are removed

BUG: The num_answers doesn't include interactive run states that are included in num_questions. It should include interactive run states for reportable interactives.

I tested this with a activity that had a reportable codap interactive. The inteactive run state was filled with data and the interactive was set to be reportable, but num_answers was still 0.

Because `Activity#questions` is already filtering interactives that are not reportable, this incorrect filtering can be removed here.

BUG: Labbooks are not handled by the progress correctly. Labbooks that don't have an interactive are included in `Activty#questions`, but they are not seen by the user so they are not `answered?`. This makes them part of `num_questions` but they are not ever part of `num_answers`. The solution is to remove them from `Activity#questions`. This should also allow us to remove the `show_in_report?` method that is used by the summary report.

Addtionally renaming `questions` to `answerable_items` would help. Because the reason this all started was because it seemed wrong to filter things
from `Activity#questions` and instead `show_in_report?` was added to handle LabBooks. It might also be possible to simplify some of this by using a single
`show_in_runtime?` for both embeddables and interactives.

## LARA summary report

The summary report is based off of:

    @answers = @activity.answers(@run).select { |a| a.show_in_report? }

The numbering of the items in the report is based off of the index of the answer in the @answers array.

TODO: `show_in_report` should be unnessary here, because `Activity#questions` should correctly filter out any any interactives or labbooks
that should not be in the report.  Currently there is a bug where LabBooks are not handled correctly by `Activity#questions` (see above).

## Sending answers to the portal

The code to look at here is `LightweightActivity#serialize_for_portal`. It goes through each page.

It filters the combination of `Page#embddables + Page#interactives` with:
- `Embeddable#is_hidden?` and `Embeddable#hide_from_report?`
- `MwInteractive#is_reportable?`
- A switch statement is used of known types so this is how Xhtml embeddables get filtered.

As it is currently written it cannot use the existing `Activity#questions` filtering because the items need to be grouped by page.

TODO: Move the logic of `Activity#questions` into `Page`. Then this can be used in both places. This has the additional benefit of leaving the intra page
ordering of embeddables and interactives up to the Page.