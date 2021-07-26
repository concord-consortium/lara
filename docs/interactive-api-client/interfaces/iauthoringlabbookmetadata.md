[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [IAuthoringLabbookMetadata](iauthoringlabbookmetadata.md)

# Interface: IAuthoringLabbookMetadata

## Hierarchy

* [IAuthoringMetadataBase](iauthoringmetadatabase.md)

  ↳ **IAuthoringLabbookMetadata**

## Index

### Properties

* [answerPrompt](iauthoringlabbookmetadata.md#optional-answerprompt)
* [prompt](iauthoringlabbookmetadata.md#optional-prompt)
* [questionSubType](iauthoringlabbookmetadata.md#optional-questionsubtype)
* [questionType](iauthoringlabbookmetadata.md#questiontype)
* [required](iauthoringlabbookmetadata.md#optional-required)

## Properties

### `Optional` answerPrompt

• **answerPrompt**? : *undefined | string*

___

### `Optional` prompt

• **prompt**? : *undefined | string*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[prompt](iauthoringmetadatabase.md#optional-prompt)*

___

### `Optional` questionSubType

• **questionSubType**? : *undefined | string*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[questionSubType](iauthoringmetadatabase.md#optional-questionsubtype)*

Interactive can optionally set questionSubType, so Teacher Report can display different icons
or categorize interactives into subcategories.

___

###  questionType

• **questionType**: *"labbook_question"*

*Overrides [IAuthoringMetadataBase](iauthoringmetadatabase.md).[questionType](iauthoringmetadatabase.md#questiontype)*

___

### `Optional` required

• **required**? : *undefined | false | true*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[required](iauthoringmetadatabase.md#optional-required)*
