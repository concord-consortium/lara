[@concord-consortium/lara-interactive-api - v0.5.0-pre.4](../README.md) › [Globals](../globals.md) › [IRuntimeInteractiveMetadata](iruntimeinteractivemetadata.md)

# Interface: IRuntimeInteractiveMetadata

## Hierarchy

* [IRuntimeMetadataBase](iruntimemetadatabase.md)

  ↳ **IRuntimeInteractiveMetadata**

## Index

### Properties

* [answerText](iruntimeinteractivemetadata.md#optional-answertext)
* [answerType](iruntimeinteractivemetadata.md#answertype)
* [submitted](iruntimeinteractivemetadata.md#optional-submitted)

## Properties

### `Optional` answerText

• **answerText**? : *undefined | string*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerText](iruntimemetadatabase.md#optional-answertext)*

answerText can be used by all the interactive types to display answer summary without having to load iframe
with report view.

___

###  answerType

• **answerType**: *"interactive_state"*

*Overrides [IRuntimeMetadataBase](iruntimemetadatabase.md).[answerType](iruntimemetadatabase.md#answertype)*

___

### `Optional` submitted

• **submitted**? : *undefined | false | true*

*Inherited from [IRuntimeMetadataBase](iruntimemetadatabase.md).[submitted](iruntimemetadatabase.md#optional-submitted)*
