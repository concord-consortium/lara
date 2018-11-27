## ExternalScripts (original)

* Admins must create a new `ApprovedScript` record.  The record includes the
    * URL to the remote script
    * An internal label for reference.
* ExternalScripts must conform to this (developing) API:
    * They must call `ExternalScripts.register("label", ExternalScriptClass)` immediately;
    * `new ExternalScriptClass(config, ctx)` must return an instance of an ExternalScript
        * `config` is an object of your choice.  Author's can edit this as json when adding a script instance.
        * `ctx` is the runtime context at page render time. It includes handy propertie for your script:
        `name`,`scriptLabel`, `scriptUrl`, `embeddableId` and `div`. Perhaps more data will be added to the context soon.
    * The API for a `ExternalScriptClass` is still being worked out.  Right now it only needs to implement these methods:
        `handleEvent({event: string, time: number, parameters: {}})`. These are logEvents as per `logger.js`.
    * see `external-scripts.js`, `external_script.rb`, `app/views/external_scripts/_lightweight` for more information.

----

## NOTES
- Scripts are inialized when their view partial `external_scripts/_lightweight` is rendered.
- This is how scripts can be bound to specific dom elements.
- `external-scripts.js` defines the external registration API
- `app/views/embeddable/external_scripts/_lightweight.html.haml` initializes the script on the page. (Important i)
- We are moving to a [Lara Plugin API](lara-plugin-api.md)

## Testing and debugging while transitioning to LARA Plugin API
* If you add an external debugging script from https://model-feedback.concord.org/debugging.js using the admin interface
* Then you can add that script to an activity page, and open the browser developer console to a preview url so long as you
* pass in the `?logging=true` to the activity preview URL.
* If you `npm install -g jest`
* Then you can then run tests using `cd jest && jest --watch`
