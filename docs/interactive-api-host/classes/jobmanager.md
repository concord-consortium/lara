[@concord-consortium/interactive-api-host](../README.md) › [Globals](../globals.md) › [JobManager](jobmanager.md)

# Class: JobManager

## Hierarchy

* **JobManager**

## Index

### Constructors

* [constructor](jobmanager.md#constructor)

### Methods

* [addInteractive](jobmanager.md#addinteractive)
* [removeInteractive](jobmanager.md#removeinteractive)

## Constructors

###  constructor

\+ **new JobManager**(`executor`: [IJobExecutor](../interfaces/ijobexecutor.md)): *[JobManager](jobmanager.md)*

**Parameters:**

Name | Type |
------ | ------ |
`executor` | [IJobExecutor](../interfaces/ijobexecutor.md) |

**Returns:** *[JobManager](jobmanager.md)*

## Methods

###  addInteractive

▸ **addInteractive**(`interactiveId`: string, `phone`: IFrameEndpoint, `context?`: Record‹string, any›): *void*

**Parameters:**

Name | Type |
------ | ------ |
`interactiveId` | string |
`phone` | IFrameEndpoint |
`context?` | Record‹string, any› |

**Returns:** *void*

___

###  removeInteractive

▸ **removeInteractive**(`interactiveId`: string): *void*

**Parameters:**

Name | Type |
------ | ------ |
`interactiveId` | string |

**Returns:** *void*
