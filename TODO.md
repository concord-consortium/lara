# Roadmap

This is what's coming up for lightweight-standalone, along with questions where I have them about how this progress should happen.

#### Finishing authoring
Stories are [in Pivotal Tracker](https://www.pivotaltracker.com/projects/442903#!/epics/70357) for this. Currently, we want to:

* √ finish edit-in-place,
* add the ability to add choices to MultipleChoice embeddables,
* allow pages and Embeddables to be reordered,
* check for bugs and this-isn't-working-as-expected issues.

#### Access control/authorization:
We have at least two roles here: activity authors and "students" taking the activities. We don't actually need to *authenticate* the students, because we only need to persist their answers to questions; we don't actually need to know anything else about them, and so any kind of login/password setup is probably overkill. Authors do need to be authenticated, however, and only allowed to edit their own activities.

We should be supporting eventual single-sign-on so Devise is probably in order.

* Install Devise
* Set up user registration and authentication
* Plan for non-authenticated session keys for persistence

#### Persistence of data
See above: we need some kind of user key for retrieving saved activity for a specific user, and we'll probably need to re-implement a basic level of Saveable using that key.

* Create Saveable resources
* Set up controller actions to save user activity as Saveables
* Update show pages to use Saveable data if it exists

#### Home page √
What should go on it? Should it just redirect to the Activities index page?

#### Deploying √
Where should this live? Does it replace http://lightweight-mw.concord.org?

Yes, for now.

#### Misc
* √ Seed data for demos

## Future authoring work
There are a lot more pieces in the long run:

* More complicated activity models, including containers
* Ability to copy activities for editing (this should be discussed in more detail)