/* SQL Query for Databases.DDLTrigger */
SELECT t.name TriggerName,
   COUNT(*) AS TriggerCount
FROM sys.triggers AS t
where t.is_disabled = 0 and t.name = 'LogDatabaseChanges'
GROUP BY t.name