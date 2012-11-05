# Roadmap

This is what's coming up for lightweight-standalone, along with questions where I have them about how this progress should happen.

#### Home page
√ What should go on it? Should it just redirect to the Activities index page?

#### Access control/authorization:
We have at least two roles here: activity authors and "students" taking the activities. We don't actually need to *authenticate* the students, because we only need to persist their answers to questions; we don't actually need to know anything else about them, and so any kind of login/password setup is probably overkill. Authors do need to be authenticated, however, and only allowed to edit their own activities.

We should be supporting eventual single-sign-on so Devise is probably in order.

#### Persistence of data
See above: we need some kind of user key for retrieving saved activity for a specific user, and we'll probably need to re-implement a basic level of Saveable using that key.

#### Finishing authoring
Stories are [in Pivotal Tracker](https://www.pivotaltracker.com/projects/442903#!/epics/70357) for this. Currently, we want to:

* finish edit-in-place,
* add the ability to add choices to MultipleChoice embeddables,
* allow pages and Embeddables to be reordered,
* check for bugs and this-isn't-working-as-expected issues. 

#### Deploying
Where should this live? Does it replace http://lightweight-mw.concord.org?

#### Misc
* √ Seed data for demos