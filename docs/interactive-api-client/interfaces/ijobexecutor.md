[@concord-consortium/lara-interactive-api](../README.md) › [Globals](../globals.md) › [IJobExecutor](ijobexecutor.md)

# Interface: IJobExecutor

## Hierarchy

* **IJobExecutor**

## Index

### Methods

* [cancelJob](ijobexecutor.md#canceljob)
* [createJob](ijobexecutor.md#createjob)
* [getJobs](ijobexecutor.md#getjobs)
* [onJobUpdate](ijobexecutor.md#onjobupdate)

## Methods

###  cancelJob

▸ **cancelJob**(`jobId`: string): *Promise‹void›*

**Parameters:**

Name | Type |
------ | ------ |
`jobId` | string |

**Returns:** *Promise‹void›*

___

###  createJob

▸ **createJob**(`request`: object & Record‹string, any›, `context?`: Record‹string, any›): *Promise‹[IJobInfo](ijobinfo.md)›*

**Parameters:**

Name | Type |
------ | ------ |
`request` | object & Record‹string, any› |
`context?` | Record‹string, any› |

**Returns:** *Promise‹[IJobInfo](ijobinfo.md)›*

___

###  getJobs

▸ **getJobs**(`context?`: Record‹string, any›): *Promise‹[IJobInfo](ijobinfo.md)[]›*

**Parameters:**

Name | Type |
------ | ------ |
`context?` | Record‹string, any› |

**Returns:** *Promise‹[IJobInfo](ijobinfo.md)[]›*

___

###  onJobUpdate

▸ **onJobUpdate**(`callback`: function): *void*

**Parameters:**

▪ **callback**: *function*

▸ (`job`: [IJobInfo](ijobinfo.md)): *void*

**Parameters:**

Name | Type |
------ | ------ |
`job` | [IJobInfo](ijobinfo.md) |

**Returns:** *void*
