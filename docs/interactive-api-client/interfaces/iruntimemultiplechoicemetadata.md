[@concord-consortium/lara-interactive-api - v0.6.0](../README.md) › [Globals](../globals.md) › [IRuntimeMultipleChoiceMetadata](iruntimemultiplechoicemetadata.md)

# Interface: IRuntimeMultipleChoiceMetadata

## Hierarchy

* [IRuntimeMetadataBase](iruntimemetadatabase.md)

  ↳ **IRuntimeMultipleChoiceMetadata**

## Index

### Properties

* [answerText](iruntimemultiplechoicemetadata.md#optional-answertext)
* [answerType](iruntimemultiplechoicemetadata.md#answertype)
* [selectedChoiceIds](iruntimemultiplechoicemetadata.md#selectedchoiceids)
* [submitted](iruntimemultiplechoicemetadata.md#optional-submitted)

## Properties

### `Optional` answerText

• **answerText**? : *undefined | string*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerText](iruntimemetadatabase.md#optional-answertext)*

answerText can be used by all the interactive types to display answer summary without having to load iframe
with report view.

___

###  answerType

• **answerType**: *"multiple_choice_answer"*

*Overrides [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerType](iruntimemetadatabase.md#answertype)*

___

###  selectedChoiceIds

• **selectedChoiceIds**: *[ChoiceId](../globals.md#choiceid)[]*

___

### `Optional` submitted

• **submitted**? : *undefined | false | true*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[submitted](iruntimemetadatabase.md#optional-submitted)*
