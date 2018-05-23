SELECT DISTINCT CAST(tmp.CreatedOn as smalldatetime) as GMT, suc.DomainName as CallingUserDName,suc.FullName as CallingUserName,suo.DomainName as WhomDName, suo.FullName as WhomName,su.DomainName as WhoDName, e.Name as ObjectType, sa.Value AS ActionName,so.Value AS OperationName,tmp.UserIdName as UserIdName, tmp.CallingUserIdName as CallingUserIdName, cast(tmp.AttributeMask as NVARCHAR(4000)) as AttributeMask, tmp.TransactionId as TransactionId,  tmp.Action as Action,
tmp.ObjectId as ObjectId, tmp.UserId as UserId, cast(tmp.ChangeData as nvarchar(4000)) as ChangeData, tmp.CreatedOn as CreatedOn, tmp.Operation as Operation, tmp.AuditId as AuditId, tmp.CallingUserId as CallingUserId, tmp.ObjectTypeCode as ObjectTypeCode, tmp.ObjectIdName as ObjectIdName, tmp.RegardingObjectId as RegardingObjectId, tmp.RegardingObjectIdName as RegardingobjectIdName
  FROM [dnmcs_MSCRM].[dbo].[Audit] tmp
  LEFT OUTER JOIN StringMap sa ON sa.Attributevalue = tmp.[Action] AND sa.AttributeName='action'
  LEFT OUTER JOIN StringMap so ON so.Attributevalue = tmp.Operation AND so.AttributeName='operation'
  INNER JOIN Entity e ON e.ObjectTypeCode = tmp.ObjectTypeCode
  LEFT OUTER JOIN SystemUser su ON su.SystemUserId = tmp.UserId
  LEFT OUTER JOIN SystemUser suo ON suo.SystemUserId = tmp.ObjectId
  LEFT OUTER JOIN SystemUser suc ON suc.SystemUserId = tmp.CallingUserId
  Where tmp.CreatedOn>= %LAST_GATHERED_EVENT%
  ORDER By GMT asc
