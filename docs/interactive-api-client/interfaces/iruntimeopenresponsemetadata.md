[@concord-consortium/lara-interactive-api - v0.6.1](../README.md) › [Globals](../globals.md) › [IRuntimeOpenResponseMetadata](iruntimeopenresponsemetadata.md)

# Interface: IRuntimeOpenResponseMetadata

## Hierarchy

* [IRuntimeMetadataBase](iruntimemetadatabase.md)

  ↳ **IRuntimeOpenResponseMetadata**

## Index

### Properties

* [answerText](iruntimeopenresponsemetadata.md#optional-answertext)
* [answerType](iruntimeopenresponsemetadata.md#answertype)
* [submitted](iruntimeopenresponsemetadata.md#optional-submitted)

## Properties

### `Optional` answerText

• **answerText**? : *undefined | string*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerText](iruntimemetadatabase.md#optional-answertext)*

answerText can be used by all the interactive types to display answer summary without having to load iframe
with report view.

___

###  answerType

• **answerType**: *"open_response_answer"*

*Overrides [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerType](iruntimemetadatabase.md#answertype)*

answerType is different so Report and Portal can recognize this type of question.
Use answerText (defined in IRuntimeMetadataBase) to provide open response answer.

___

### `Optional` submitted

• **submitted**? : *undefined | false | true*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[submitted](iruntimemetadatabase.md#optional-submitted)*
