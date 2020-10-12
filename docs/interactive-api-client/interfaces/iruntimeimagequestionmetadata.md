[@concord-consortium/lara-interactive-api - v0.6.1](../README.md) › [Globals](../globals.md) › [IRuntimeImageQuestionMetadata](iruntimeimagequestionmetadata.md)

# Interface: IRuntimeImageQuestionMetadata

## Hierarchy

* [IRuntimeMetadataBase](iruntimemetadatabase.md)

  ↳ **IRuntimeImageQuestionMetadata**

## Index

### Properties

* [answerImageUrl](iruntimeimagequestionmetadata.md#answerimageurl)
* [answerText](iruntimeimagequestionmetadata.md#optional-answertext)
* [answerType](iruntimeimagequestionmetadata.md#answertype)
* [submitted](iruntimeimagequestionmetadata.md#optional-submitted)

## Properties

###  answerImageUrl

• **answerImageUrl**: *string*

___

### `Optional` answerText

• **answerText**? : *undefined | string*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerText](iruntimemetadatabase.md#optional-answertext)*

answerText can be used by all the interactive types to display answer summary without having to load iframe
with report view.

___

###  answerType

• **answerType**: *"image_question_answer"*

*Overrides [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerType](iruntimemetadatabase.md#answertype)*

___

### `Optional` submitted

• **submitted**? : *undefined | false | true*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[submitted](iruntimemetadatabase.md#optional-submitted)*
