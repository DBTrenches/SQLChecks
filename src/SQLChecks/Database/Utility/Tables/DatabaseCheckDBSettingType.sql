
create table Utility.DatabaseCheckDBSettingType (
    CheckTypeID   tinyint not null
        constraint PK_DatabaseCheckDBSettingType primary key clustered,
    CheckTypeDesc varchar(50)
);
go

insert into Utility.DatabaseCheckDBSettingType (
    CheckTypeID,
    CheckTypeDesc
)
values 
(0, 'DoNotFullCheckDB');
go
