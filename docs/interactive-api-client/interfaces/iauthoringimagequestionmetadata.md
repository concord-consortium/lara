[@concord-consortium/lara-interactive-api - v0.7.0-pre.1](../README.md) › [Globals](../globals.md) › [IAuthoringImageQuestionMetadata](iauthoringimagequestionmetadata.md)

# Interface: IAuthoringImageQuestionMetadata

## Hierarchy

* [IAuthoringMetadataBase](iauthoringmetadatabase.md)

  ↳ **IAuthoringImageQuestionMetadata**

## Index

### Properties

* [answerPrompt](iauthoringimagequestionmetadata.md#optional-answerprompt)
* [prompt](iauthoringimagequestionmetadata.md#optional-prompt)
* [questionSubType](iauthoringimagequestionmetadata.md#optional-questionsubtype)
* [questionType](iauthoringimagequestionmetadata.md#questiontype)
* [required](iauthoringimagequestionmetadata.md#optional-required)

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

• **questionType**: *"image_question"*

*Overrides [IAuthoringMetadataBase](iauthoringmetadatabase.md).[questionType](iauthoringmetadatabase.md#questiontype)*

___

### `Optional` required

• **required**? : *undefined | false | true*

*Inherited from [IAuthoringMetadataBase](iauthoringmetadatabase.md).[required](iauthoringmetadatabase.md#optional-required)*
