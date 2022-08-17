select 
    [name] as [Name],
    [enabled] as [Enabled],
    message_id as MessageId,
    delay_between_responses as DelayBetweenResponses,
    notification_message as NotificationMessage,
    event_description_keyword as EventDescriptionKeyword
from msdb.dbo.sysalerts
where [enabled] = 1
  and has_notification = 1;
