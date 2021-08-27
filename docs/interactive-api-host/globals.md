[@concord-consortium/interactive-api-host](README.md) › [Globals](globals.md)

# @concord-consortium/interactive-api-host

## Index

### Interfaces

* [IAnswerMetadataWithAttachmentsInfo](interfaces/ianswermetadatawithattachmentsinfo.md)
* [IAttachmentsFolder](interfaces/iattachmentsfolder.md)
* [IAttachmentsManagerInitOptions](interfaces/iattachmentsmanagerinitoptions.md)
* [IHandleGetAttachmentUrlOptions](interfaces/ihandlegetattachmenturloptions.md)
* [IReadableAttachmentInfo](interfaces/ireadableattachmentinfo.md)
* [IS3SignedUrlOptions](interfaces/is3signedurloptions.md)
* [ISignedReadUrlOptions](interfaces/isignedreadurloptions.md)
* [ISignedWriteUrlOptions](interfaces/isignedwriteurloptions.md)
* [IWritableAttachmentsFolder](interfaces/iwritableattachmentsfolder.md)

### Type aliases

* [S3Operation](globals.md#s3operation)

### Variables

* [attachmentsManager](globals.md#const-attachmentsmanager)

### Functions

* [handleGetAttachmentUrl](globals.md#const-handlegetattachmenturl)
* [initializeAttachmentsManager](globals.md#const-initializeattachmentsmanager)

## Type aliases

###  S3Operation

Ƭ **S3Operation**: *"getObject" | "putObject"*

## Variables

### `Const` attachmentsManager

• **attachmentsManager**: *Promise‹AttachmentsManager‹››* = new Promise<AttachmentsManager>((resolve, reject) => {
  resolveAttachmentsManager = resolve;
})

## Functions

### `Const` handleGetAttachmentUrl

▸ **handleGetAttachmentUrl**(`options`: [IHandleGetAttachmentUrlOptions](interfaces/ihandlegetattachmenturloptions.md)): *Promise‹IAttachmentUrlResponse›*

**Parameters:**

Name | Type |
------ | ------ |
`options` | [IHandleGetAttachmentUrlOptions](interfaces/ihandlegetattachmenturloptions.md) |

**Returns:** *Promise‹IAttachmentUrlResponse›*

___

### `Const` initializeAttachmentsManager

▸ **initializeAttachmentsManager**(`optionsPromise`: Promise‹[IAttachmentsManagerInitOptions](interfaces/iattachmentsmanagerinitoptions.md)›): *Promise‹void›*

**Parameters:**

Name | Type |
------ | ------ |
`optionsPromise` | Promise‹[IAttachmentsManagerInitOptions](interfaces/iattachmentsmanagerinitoptions.md)› |

**Returns:** *Promise‹void›*
