Table of contents:

[TOC]

# LARA iframe APIs

This is an attempt to document the [postMessage](https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage) communication currently in use in [LARA](https://github.com/concord-consortium/LARA).  Some of these use [iFramePhone](https://github.com/concord-consortium/iframe-phone), and some use raw postMessage calls. This documentation was started from this [PT Story](https://www.pivotaltracker.com/story/show/90777130).

## Interactive Shutterbug

[Shutterbug](https://github.com/concord-consortium/shutterbug.js) is used widely in Lab and in LARA, it uses [postMessage](https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage) to request child iFrames HTML content for snapshotting.

The basic PostMessage API Calls that are used in the shutterbug javascript project are [documented in the github repo](https://github.com/concord-consortium/shutterbug.js/blob/master/app/scripts/shutterbug-worker.js#L276-L343)  

###  Shutterbug Messages:

-----
#### `htmlFragRequest` 

Parent asks iframes about their content:

```javascript
 var message  = {
   type:        'htmlFragRequest',
   id:          id,       // Shutterbug ID
   iframeReqId: iframeId, // position of iframe in dom
   iframeReqTimeout: this.iframeReqTimeout * 0.6
 };
 window.postMessage(JSON.stringify(message), "*");
```
----

#### `htmlFragResponse` 

An Iframe sends its content back:
```javascript 
var response = {
	type:        'htmlFragResponse',
	value:       html,
	iframeReqId: iframeReqId, // counter, from request
	id:          id           // sender_id from request
};
source.postMessage(JSON.stringify(response), "*");
```


----

## LARA: Interactive save state

LARA tries to save the interactive state in child iframes by using [iFramePhone](https://github.com/concord-consortium/iframe-phone), but it wraps it up in [iframe-saver.coffee](https://github.com/concord-consortium/LARA/blob/master/app/assets/javascripts/iframe-saver.coffee#L1).  The LARA logging service also uses iFramePhones [RPC endpoint](https://github.com/concord-consortium/iframe-phone/blob/master/lib/iframe-phone-rpc-endpoint.js) to log events from the interactives.

iFramePhone Handlers registered in iframe-saver.cofee:

### InteractiveState  iFramePhone listeners:
#### `setLearnerUrl`:
Listen for an attempt to set the exact URL for this current student. (In the case of Lab Interactives these are version-locked instances of the interactive). Usually sent LARA after LARA has asked for the info via a previous `getLearnerUrl` message to the iFrame.

```javascript
var learnerUrlCallback = function(learner_url) { … };
iframePhone.addListener('setLearnerUrl', learnerUrlCallback);
```

iFramePhone handles this for us, but for completeness here is the raw postMessage data object, note that `content` is the argument sent to our callback:
```javascript
var message = {
	type: "setLearnerUrl", 
	content: "https://lab.concord.org/version/1-0/embeddable.html?is_versioned_url=true"
};
```


#### `interactiveState`:
Listen for the current interactive state. Usually sent as a result of our having sent 'getInteractiveState' message to the iFrame earlier.
```javascript
var setStateCallback = function(stateObjOrJson) { … };
iframePhone.addListener('interactiveState', setStateCallback);
```

iFramePhone handles this for us, but for completeness here is the raw postMessage data object, note that `content` is the argument sent to our callback:
```javascript
var message = {
	type: "interactiveState", 
	content: {key: 'value', … } // maybe sent as Obj, or JSON depending. 
};
```


#### `extendedSupport`:
Listen for the option to reset state using delete button.  If `opts.reset` is true, we will allow the user to 'reset' the interactive via the _delete_ button in the LARA runtime. Usually sent as a result of our having sent 'getExtendedSupport' earlier.
```javascript
var extendSupport = function(opts) { … };
iframePhone.addListener('extendedSupport', extendSupport);
```

iFramePhone handles this for us, but for completeness here is the raw postMessage data object, note that `content` is the argument sent to our callback:
```javascript
var message = {
	type: "extendedSupport", 
	content: {rest: [true||false]} // maybe sent as Obj, or JSON depending. 
};
```

### InteractiveState iFramePhone posts:

#### `getExtendedSupport` 
LARA asks about extended support for things like 'reset':
```javascript
iframePhone.post('getExtendedSupport');
```
iFramePhone handles this for us, but for completeness here is the raw postMessage data object sent.
```javascript
var message = {
	type: "getExtendedSupport", 
	content: {} // ignored 
};
```

#### `getLearnerUrl` 
LARA asks for the exact URL for the current student. For Lab Interactives this results in a version-specific URL:
```javascript
iframePhone.post('getLearnerUrl');     
```
iFramePhone handles this for us, but for completeness here is the raw postMessage data object sent.
```javascript
var message = {
	type: "getLearnerUrl", 
	content: {} // ignored 
};
```

#### `getInteractiveState` 
LARA asks for the iframes state.
```javascript
iframePhone.post('getInteractiveState');     
```
iFramePhone handles this for us, but for completeness here is the raw postMessage data object sent.
```javascript
var message = {
	type: "getInteractiveState", 
	content: {} // ignored 
};
```


----

## LARA current_user info for an interactive
Information about whether this is an anonymous run, and or who the current_user is (email) is sometimes sent to the interactive. Most of this functionality was added (possibly erroneously) to the [iframe-saver](https://github.com/concord-consortium/LARA/blob/master/app/assets/javascripts/iframe-saver.coffee#L1) in  [these commits](https://github.com/concord-consortium/LARA/commit/58d7ee267fd0ae80547f432d932e287cdc856a7b)

### current_user Listeners:

#### `getAuthInfo` 
LARA listens for this message. When received, LARA is being asked to send authentication iformation to the iframe for the current_user.

```javascript
var sendAuthInfo = function() { iFramePhone.post('authInfo', …) };
iframePhone.addListener('getAuthInfo', sendAuthInfo);
```
iFramePhone handles this for us, but for completeness here is the raw postMessage data object sent.
```javascript
var message = {
	type: "getAuthInfo", 
	content: {} // ignored 
};
```

### current_user Posts:

#### `authInfo`
LARA posts this in response to `getAuthInfo` messages.

```javascript
var authInfo = { … }; // get the current_user info
iframePhone.post('authInfo', authInfo);
```

iFramePhone handles this for us, but for completeness here is the raw postMessage data object sent.
```javascript
var message = {
	type: "authInfo", 
	content: {
		provider: 'authentication-provider', 
		loggedIn: (true || false),
		email: (undefined || 'somebody@somplace.com')
	} 
};
```

----

## Interactive Logging (coming soon)
Interactive Logging is a service that proxies communication from the interactive → LARA → Logging server. Some endpoints for logging are (possibly erroniously) created in the [iframe-saver](https://github.com/concord-consortium/LARA/blob/master/app/assets/javascripts/iframe-saver.coffee#L1). Others are installed in [logger.js](https://github.com/concord-consortium/lara/blob/b51f764600816844088a0d45dc4493c0510eefe0/app/assets/javascripts/logger.js#L99)  Instead of using the Listen / Post paradigm, the interactive Logging service uses the [IframePhoneRpcEndpoint](https://github.com/concord-consortium/iframe-phone/blob/master/lib/iframe-phone-rpc-endpoint.js) of iFramePhone. 

### RPC Calls:
#### LARA-logging-present 
Here is an approximation of the initialization code in  [iframe-saver](https://github.com/concord-consortium/LARA/blob/master/app/assets/javascripts/iframe-saver.coffee#L146).

```javascript
var iframePhoneRpc = new iframePhone.IframePhoneRpcEndpoint({
	phone: iframePhone,  // existing iFramePhone
    namespace: 'lara-logging'
});
iframePhoneRpc.call(message: 'lara-logging-present');
```


The above code is only run in the event that there is saveable interactive.  Otherwise logger.js will create its own iFramePhone &etc.  After that optional step, it registers its logging handler, and indicates that its ready to log.

```javascript
iframePhoneRpc.handler = handler; // a function that logs :)
iframePhoneRpc.call({ message: 'lara-logging-present' });
```

----

## Global state (coming soon)

#### `globalSaveState`

```javascript
iframePhoneRpc.handler = handler;
iframePhoneRpc.namespace = lara-global-state;
iframePhoneRpc.call({ message: 'global-save-state' });
```

#### `globalLoadState`

```javascript
var handler = function()
iframePhoneRpc.handler = handler;
iframePhoneRpc.namespace = lara-global-state;
iframePhoneRpc.call({ message: 'global-load-state' });
```


----

## Only playing one at a time (coming soon)

----

# Reference: using iFramePhone:

As mentioned [iFramePhone](https://github.com/concord-consortium/iframe-phone) is the service which LARA uses for much of its iFrame communication.   It is also used by Lab Interactives internally. Most of the Lab messages are ignored by LARA.  

Here for reference is what the implementation looks like. Taken from the [iFramePhone Readme](https://github.com/concord-consortium/iframe-phone):

### parent setup:
```javascript
var phone = new iframePhone.ParentEndpoint(iframeElement, function () {
  console.log("connection with iframe established");
});
phone.post('testMessage', 'abc');
phone.addListener('response', function (content) {
  console.log("parent received response: " + content);
});
```

### iframe (child) setup:
```javascript
var phone = iframePhone.getIFrameEndpoint();
phone.addListener('testMessage', function (content) { 
  console.log("iframe received message: " + content);
  phone.post('response', 'got it');
});
// IMPORTANT:
// Initialize connection after all message listeners are added!
phone.initialize();
```

#### hello messages:
iFramePhone uses a `hello` messages to start communication with a specified origin. These messages get sent using the PostMessage API and look like this:

```javascript
var message = {
	type: "hello", 
	origin: "https://lab.concord.org"
};
```

#### other messages:
Subsequent messages follow a similar pattern, specifiying `type` which helps determine which listeners to notify:

```javascript
var message = {
	type:"modelLoaded",
	…
};
```

#### Message posting implementation:
The post messages looks like this as they are being sent out through iFramePhone. You don't need to worry about this; it is here for reference.

```javascript
message = {
	type: "getLearnerUrl", 
	origin: "http://localhost:3000",
	content: {} // something specific to 'type'
};
Window.postMessage(JSON.stringify(message), targetOrigin);
```

