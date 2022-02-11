
create table Utility.DatabaseCheckDBSetting (
    DatabaseName varchar(255) not null
        constraint PK_DatabaseCheckDBSetting primary key clustered,
    CheckTypeID  tinyint
        constraint FK_DatabaseCheckDBSettingType
        foreign key references Utility.DatabaseCheckDBSettingType (CheckTypeID)
);
go
