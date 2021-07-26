[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [IRuntimeLabbookQuestionMetadata](iruntimelabbookquestionmetadata.md)

# Interface: IRuntimeLabbookQuestionMetadata

## Hierarchy

* [IRuntimeMetadataBase](iruntimemetadatabase.md)

  ↳ **IRuntimeLabbookQuestionMetadata**

## Index

### Properties

* [answerImageUrl](iruntimelabbookquestionmetadata.md#optional-answerimageurl)
* [answerText](iruntimelabbookquestionmetadata.md#optional-answertext)
* [answerType](iruntimelabbookquestionmetadata.md#answertype)
* [submitted](iruntimelabbookquestionmetadata.md#optional-submitted)

## Properties

### `Optional` answerImageUrl

• **answerImageUrl**? : *undefined | string*

___

### `Optional` answerText

• **answerText**? : *undefined | string*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerText](iruntimemetadatabase.md#optional-answertext)*

answerText can be used by all the interactive types to display answer summary without having to load iframe
with report view.

___

###  answerType

• **answerType**: *"labbook_question_answer"*

*Overrides [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerType](iruntimemetadatabase.md#answertype)*

___

### `Optional` submitted

• **submitted**? : *undefined | false | true*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[submitted](iruntimemetadatabase.md#optional-submitted)*
